import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/models/employee_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ── State ──
class EmployeeState {
  final EmployeeData? data;
  final bool isLoading;
  final String? error;

  const EmployeeState({this.data, this.isLoading = false, this.error});

  EmployeeState copyWith({EmployeeData? data, bool? isLoading, String? error}) {
    return EmployeeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  EmployeeNotifier() : super(const EmployeeState(isLoading: true)) {
    loadEmployee();
  }

  Future<void> loadEmployee() async {
    try {
      state = state.copyWith(isLoading: true);
      print("Connecting to supabase");

      final userId = supabase.auth.currentUser!.id;

      // ✅ Fetch all 3 tables in parallel
      final results = await Future.wait([
        supabase.from('employees').select().eq('user_id', userId).single(),
        supabase
            .from('attendance_summary')
            .select()
            .eq('user_id', userId)
            .single(),
        supabase.from('leave_stats').select().eq('user_id', userId).single(),
      ]);

      print('✅ Employee: ${results[0]}');
      print('✅ Attendance: ${results[1]}');
      print('✅ Leave: ${results[2]}');

      // ✅ Merge all 3 into one flat map
      final merged = {
        ...results[0] as Map<String, dynamic>,
        ...results[1] as Map<String, dynamic>,
        ...results[2] as Map<String, dynamic>,
      };

      print('✅ Merged: $merged');

      state = state.copyWith(
        data: EmployeeData.fromJson(merged),
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>(
  (ref) => EmployeeNotifier(),
);
