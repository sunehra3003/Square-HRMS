import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendence_model.dart';
import '../models/employee_data.dart';
import 'employee_provider.dart';

final supabase = Supabase.instance.client;

// ── Fetch today's attendance record ──
final todayAttendanceProvider = FutureProvider<AttendanceRecord?>((ref) async {
  final userId = supabase.auth.currentUser!.id;
  final empResponse = await supabase
      .from('employees')
      .select('id')
      .eq('user_id', userId)
      .single();
  final employeeId = empResponse['id'] as String;
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final response = await supabase
      .from('attendance_records')
      .select()
      .eq('employee_id', employeeId)
      .eq('date', dateStr)
      .maybeSingle();

  if (response == null) return null;
  return AttendanceRecord.fromJson(response);
});

// ── Fetch monthly attendance records for calendar ──
final monthlyAttendanceProvider =
    FutureProvider.family<List<AttendanceRecord>, DateTime>((ref, month) async {
      final userId = supabase.auth.currentUser!.id;
      final empResponse = await supabase
          .from('employees')
          .select('id')
          .eq('user_id', userId)
          .single();
      final employeeId = empResponse['id'] as String;

      final firstDay =
          '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final lastDayStr =
          '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

      final response = await supabase
          .from('attendance_records')
          .select()
          .eq('employee_id', employeeId)
          .gte('date', firstDay)
          .lte('date', lastDayStr);

      return (response as List)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    });

// ── Fetch attendance summary ──
final attendanceSummaryProvider = FutureProvider<AttendanceSummary>((
  ref,
) async {
  final userId = supabase.auth.currentUser!.id;
  final response = await supabase
      .from('attendance_summary')
      .select()
      .eq('user_id', userId)
      .single();
  return AttendanceSummary.fromJson(response);
});

// ── Fetch authorized locations ──
final attendanceLocationsProvider = FutureProvider<List<AttendanceLocation>>((
  ref,
) async {
  final response = await supabase.from('attendance_location').select();
  return (response as List)
      .map((e) => AttendanceLocation.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ── Fetch employee's shift info ──
final shiftInfoProvider = FutureProvider<ShiftInfo?>((ref) async {
  final userId = supabase.auth.currentUser!.id;
  final empResponse = await supabase
      .from('employees')
      .select('id')
      .eq('user_id', userId)
      .single();
  final employeeId = empResponse['id'] as String;

  final response = await supabase
      .from('attendance_group_detail')
      .select(
        'group_id, attendance_group_master(group_name, shift_start, shift_end)',
      )
      .eq('employee_id', employeeId)
      .maybeSingle();

  if (response == null) return null;
  final master = response['attendance_group_master'] as Map<String, dynamic>;
  return ShiftInfo.fromJson(master);
});

// ── Punch notifier ──
class PunchNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  PunchNotifier(this.ref) : super(const AsyncData(null));

  Future<void> punch(VoidCallback onSuccess, Function(String) onError) async {
    state = const AsyncLoading();

    try {
      // 1. Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        state = const AsyncData(null);
        onError('Location permission denied. Please enable it in settings.');
        return;
      }

      // 2. Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Check against authorized locations
      final locations =
          ref.read(attendanceLocationsProvider).asData?.value ?? [];
      AttendanceLocation? nearestLocation;
      for (final loc in locations) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          loc.latitude,
          loc.longitude,
        );
        if (distance <= loc.radiusMeters) {
          nearestLocation = loc;
          break;
        }
      }

      if (nearestLocation == null) {
        state = const AsyncData(null);
        onError(
          'You are not in an authorized area. Please be at the office to punch in.',
        );
        return;
      }

      // 4. Get employee info
      final userId = supabase.auth.currentUser!.id;
      final empResponse = await supabase
          .from('employees')
          .select('id')
          .eq('user_id', userId)
          .single();
      final employeeId = empResponse['id'] as String;

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // 5. Check if already punched in today
      final existing = await supabase
          .from('attendance_records')
          .select()
          .eq('employee_id', employeeId)
          .eq('date', dateStr)
          .maybeSingle();

      if (existing == null) {
        // ── PUNCH IN ──
        final shiftInfo = ref.read(shiftInfoProvider).asData?.value;
        String status = 'Present';

        if (shiftInfo != null) {
          final shiftStart = DateTime(
            today.year,
            today.month,
            today.day,
            shiftInfo.startHour,
            shiftInfo.startMinute,
          );
          if (today.isAfter(shiftStart)) {
            status = 'Late';
          }
        }

        // check if today is weekend (Saturday=6, Sunday=7)
        if (today.weekday == DateTime.friday ||
            today.weekday == DateTime.saturday) {
          status = 'Weekend';
        }

        await supabase.from('attendance_records').insert({
          'employee_id': employeeId,
          'date': dateStr,
          'punch_in': today.toUtc().toIso8601String(),
          'status': status,
          'location_name': nearestLocation.name,
        });
      } else {
        // ── PUNCH OUT ──
        final punchIn = DateTime.parse(
          existing['punch_in'] as String,
        ).toLocal();
        final durationMinutes = today.difference(punchIn).inMinutes;

        await supabase
            .from('attendance_records')
            .update({
              'punch_out': today.toUtc().toIso8601String(),
              'duration_minutes': durationMinutes,
            })
            .eq('id', existing['id']);
      }

      // 6. Invalidate providers to refresh UI
      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(attendanceSummaryProvider);
      ref.invalidate(monthlyAttendanceProvider);
      ref.invalidate(employeeProvider);

      state = const AsyncData(null);
      onSuccess();
    } catch (e) {
      print('Punch error: $e');
      state = const AsyncData(null);
      onError('Something went wrong: $e');
    }
  }
}

final punchProvider = StateNotifierProvider<PunchNotifier, AsyncValue<void>>(
  (ref) => PunchNotifier(ref),
);
