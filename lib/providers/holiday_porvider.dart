import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/models/holiday_data.dart';
import 'dart:math';

class HolidayState {
  final List<HolidayData> holidays;
  final bool isLoading;
  final String? error;

  const HolidayState({
    this.holidays = const [],
    this.isLoading = false,
    this.error,
  });

  HolidayState copyWith({
    List<HolidayData>? holidays,
    bool? isLoading,
    String? error,
  }) {
    return HolidayState(
      holidays: holidays ?? this.holidays,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HolidayNotifier extends StateNotifier<HolidayState> {
  HolidayNotifier() : super(const HolidayState(isLoading: true)) {
    loadHolidays();
  }
  Future<void> loadHolidays([int seconds = 1]) async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(Duration(seconds: seconds));
      final String jsonStr = await rootBundle.loadString(
        "assets/data/holidays.json",
      );

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      state = state.copyWith(
        holidays: jsonList.map((e) => HolidayData.fromJson(e)).toList(),
        isLoading: false,
      );
    } catch (e) {
      print('❌ Holiday load error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final holidayProvider = StateNotifierProvider<HolidayNotifier, HolidayState>(
  (ref) => HolidayNotifier(),
);
