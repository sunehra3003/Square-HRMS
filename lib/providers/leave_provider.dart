import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import '../models/employee_data.dart';
import 'employee_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import "../models/leave_history_data.dart";

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

final supervisorProvider = FutureProvider<EmployeeData?>((ref) async {
  final employeeState = ref.watch(employeeProvider);
  final supervisorId = employeeState.data?.supervisorId;
  if (supervisorId == null) return null;

  final response = await supabase
      .from('employees')
      .select()
      .eq('id', supervisorId)
      .single();

  return EmployeeData.fromJson(response);
});

final leaveHistoryProvider = FutureProvider<List<LeaveHistoryData>>((
  ref,
) async {
  final userId = supabase.auth.currentUser!.id;
  final results = await Future.wait([
    supabase
        .from('leave_applications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false),
    supabase.from('leave_type').select(),
    supabase.from('employees').select('id, name'),
  ]);
  final applications = results[0] as List;
  final leaveTypes = results[1] as List;
  final employees = results[2] as List;
  final typeNameById = <int, String>{
    for (final t in leaveTypes) t['id'] as int: t["name"] as String,
  };
  final nameById = <String, String>{
    for (final e in employees) e["id"] as String: e["name"] as String,
  };
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String formatDate(DateTime d) => '${months[d.month - 1]} ${d.day}, ${d.year}';
  String formatShortDate(DateTime d) => '${months[d.month - 1]} ${d.day}';
  return applications.map((row) {
    final map = row as Map<String, dynamic>;
    final leaveId = map['leave_id'] as int?;
    final approverId = map['approver_id'] as String?;
    final fromDate = DateTime.parse(map['from_date'] as String);
    final toDate = DateTime.parse(map['to_date'] as String);
    final createdAt = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null;
    final totalDays = map['total_days'] as int? ?? 0;
    return LeaveHistoryData(
      type: leaveId != null ? typeNameById[leaveId] : null,
      applied: createdAt != null ? formatDate(createdAt) : null,
      from: formatShortDate(fromDate),
      to: formatShortDate(toDate),
      days: '$totalDays ${totalDays == 1 ? "Day" : "Days"}',
      supervisor: approverId != null ? nameById[approverId] : null,
      status: map['status'] as String?,
      reason: map['reason'] as String?,
    );
  }).toList();
});

// viewmodel
class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  final Ref ref;

  LeaveFormNotifier(this.ref)
    : super(LeaveFormState(fromDate: DateTime.now(), toDate: DateTime.now())) {
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
          .select("id, supervisor_id")
          .eq("user_id", userId)
          .single();
      final employeeId = empResponse['id'];
      final supervisorId = empResponse['supervisor_id'];

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
        'approver_id': supervisorId,
        'from_date': state.fromDate.toIso8601String().split('T')[0],
        'to_date': state.toDate.toIso8601String().split('T')[0],
        'total_days': state.totalDays,
        'reason': state.reason,
        'attachment_url': attachmentUrl ?? '',
        'status': 'Pending',
      });

      resetForm();
      ref.invalidate(leaveBalanceProvider);
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
