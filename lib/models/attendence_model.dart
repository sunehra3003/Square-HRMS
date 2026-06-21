class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? punchIn;
  final DateTime? punchOut;
  final String status; // Present, Late, Absent, Weekend
  final String? locationName;
  final int? durationMinutes;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.punchIn,
    this.punchOut,
    required this.status,
    this.locationName,
    this.durationMinutes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'].toString(),
      employeeId: json['employee_id'] as String,
      date: DateTime.parse(json['date'] as String),
      punchIn: json['punch_in'] != null
          ? DateTime.parse(json['punch_in'] as String).toLocal()
          : null,
      punchOut: json['punch_out'] != null
          ? DateTime.parse(json['punch_out'] as String).toLocal()
          : null,
      status: json['status'] as String,
      locationName: json['location_name'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
    );
  }
}

class AttendanceLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const AttendanceLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radius_meters'] as num).toDouble(),
    );
  }
}

class ShiftInfo {
  final String groupName;
  final String shiftStart; // "09:00:00"
  final String shiftEnd; // "18:00:00"

  const ShiftInfo({
    required this.groupName,
    required this.shiftStart,
    required this.shiftEnd,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      groupName: json['group_name'] as String,
      shiftStart: json['shift_start'] as String,
      shiftEnd: json['shift_end'] as String,
    );
  }

  // parse shift_start into hour and minute
  int get startHour => int.parse(shiftStart.split(':')[0]);
  int get startMinute => int.parse(shiftStart.split(':')[1]);
}

class AttendanceSummary {
  final int presentDays;
  final int totalDays;
  final int lateCount;
  final double attendancePercent;

  const AttendanceSummary({
    required this.presentDays,
    required this.totalDays,
    required this.lateCount,
    required this.attendancePercent,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      presentDays: json['present_days'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      lateCount: json['late_count'] ?? 0,
      attendancePercent:
          (json['attendance_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
