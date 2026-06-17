import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

final supabase = Supabase.instance.client;

final leaveTypesProvider = FutureProvider<List<LeaveType>>((ref) async {
  final response = await supabase.from('leave_type').select().order('id');
  return (response as List)
      .map((e) => LeaveType.fromMap(e as Map<String, dynamic>))
      .toList();
});

final leaveBalanceProvider = FutureProvider<LeaveBalance>((ref) async {
  final userId = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('leave_stats')
      .select()
      .eq('user_id', userId)
      .single();

  return LeaveBalance(
    totalRemaining: response['leave_balance'] ?? 0,
    casualUsed: response['casual_used'] ?? 0,
    casualTotal: response['casual_total'] ?? 10,
    sickUsed: response['sick_used'] ?? 0,
    sickTotal: response['sick_total'] ?? 14,
  );
});

class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  final Ref ref;

  LeaveFormNotifier(this.ref)
    : super(LeaveFormState(fromDate: DateTime.now(), toDate: DateTime.now())) {
    // re-runs whenever leaveTypesProvider data changes, and tries to pick a
    // default as long as nothing is selected yet
    ref.listen<AsyncValue<List<LeaveType>>>(leaveTypesProvider, (
      previous,
      next,
    ) {
      next.whenData(_trySelectDefault);
    }, fireImmediately: true);
  }

  void _trySelectDefault(List<LeaveType> types) {
    if (types.isEmpty || state.leaveTypeId != null) return;
    final balance = ref.read(leaveBalanceProvider).asData?.value;
    final firstAvailable = types.firstWhere(
      (t) => !isLeaveExhausted(t, balance),
      orElse: () => types.first,
    );
    state = state.copyWith(leaveTypeId: firstAvailable.id);
  }

  void setLeaveType(int id) => state = state.copyWith(leaveTypeId: id);
  void setFromDate(DateTime d) => state = state.copyWith(fromDate: d);
  void setToDate(DateTime d) => state = state.copyWith(toDate: d);
  void setReason(String r) => state = state.copyWith(reason: r);
  void setAttachmentPath(String path) =>
      state = state.copyWith(attachmentPath: path);

  void resetForm() {
    state = LeaveFormState(fromDate: DateTime.now(), toDate: DateTime.now());
    // leaveTypeId is null again after reset — try to re-select a default
    final types = ref.read(leaveTypesProvider).asData?.value;
    if (types != null) _trySelectDefault(types);
  }

  Future<String?> _uploadAttachment(String employeeId, String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final extension = filePath.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };

    final fileName =
        '${employeeId}_leave_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = 'applications/$fileName';

    await supabase.storage
        .from('employees')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return supabase.storage.from('employees').getPublicUrl(storagePath);
  }

  Future<void> submit(VoidCallback onSuccess) async {
    if (state.leaveTypeId == null) {
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final userId = supabase.auth.currentUser!.id;
      final empResponse = await supabase
          .from("employees")
          .select("id")
          .eq("user_id", userId)
          .single();
      final employeeId = empResponse['id'];
      String? attachmentUrl;
      if (state.attachmentPath != null) {
        attachmentUrl = await _uploadAttachment(
          employeeId,
          state.attachmentPath!,
        );
      }
      await supabase.from('leave_applications').insert({
        'user_id': userId,
        'employee_id': employeeId,
        'leave_id': state.leaveTypeId,
        'from_date': state.fromDate.toIso8601String().split('T')[0],
        'to_date': state.toDate.toIso8601String().split('T')[0],
        'total_days': state.totalDays,
        'reason': state.reason,
        'attachment_url': attachmentUrl ?? '',
        'status': 'Pending',
      });

      resetForm();
      ref.invalidate(
        leaveBalanceProvider,
      ); // refresh banner counts after submit
      onSuccess();
    } catch (e) {
      print("Error  $e");
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final leaveFormProvider =
    StateNotifierProvider<LeaveFormNotifier, LeaveFormState>(
      (ref) => LeaveFormNotifier(ref),
    );
