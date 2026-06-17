class EmployeeData {
  String? name;
  String? role;
  String? department;
  String? status;
  String? image;
  Attendance? attendance;
  Stats? stats;

  EmployeeData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    role = json['role'];
    department = json['department'];
    status = json['status'];
    image = json['image'] as String?;
    attendance = Attendance(
      percent: (json['attendance_percent'] as num?)?.toDouble(),
      presentDays: json['present_days'],
      totalDays: json['total_days'],
      remainingDays: json['remaining_days'],
    );

    stats = Stats(
      leaveBalance: json['leave_balance'],
      lateCount: json['late_count'],
      pendingApproval: json['pending_approval'],
    );
  }
}

class Attendance {
  double? percent;
  int? presentDays;
  int? totalDays;
  int? remainingDays;

  Attendance({
    this.percent,
    this.presentDays,
    this.totalDays,
    this.remainingDays,
  });
}

class Stats {
  int? leaveBalance;
  int? lateCount;
  int? pendingApproval;

  Stats({this.leaveBalance, this.lateCount, this.pendingApproval});
}
