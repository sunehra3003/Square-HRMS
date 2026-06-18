class LeaveType {
  final int id;
  final String name;

  const LeaveType({required this.id, required this.name});

  factory LeaveType.fromMap(Map<String, dynamic> map) =>
      LeaveType(id: map['id'] as int, name: map['name'] as String);
}

class LeaveBalance {
  final int totalRemaining;
  final int casualUsed;
  final int casualTotal;
  final int sickUsed;
  final int sickTotal;

  const LeaveBalance({
    required this.totalRemaining,
    required this.casualUsed,
    required this.casualTotal,
    required this.sickUsed,
    required this.sickTotal,
  });
}

class LeaveFormState {
  final int? leaveTypeId;
  final DateTime fromDate;
  final String? approverId;
  final DateTime toDate;
  final String reason;
  final bool isSubmitting;
  final String? attachmentPath;

  const LeaveFormState({
    this.leaveTypeId,
    this.approverId,
    required this.fromDate,
    required this.toDate,
    this.reason = '',
    this.isSubmitting = false,
    this.attachmentPath,
  });

  int get totalDays => toDate.difference(fromDate).inDays + 1;

  LeaveFormState copyWith({
    int? leaveTypeId,
    DateTime? fromDate,
    String? approverId,
    DateTime? toDate,
    String? reason,
    bool? isSubmitting,
    String? attachmentPath,
  }) {
    return LeaveFormState(
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      approverId: approverId ?? this.approverId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }
}

bool isLeaveExhausted(LeaveType type, LeaveBalance? balance) {
  if (balance == null) return false;
  final name = type.name.trim().toLowerCase();
  if (name == 'casual leave') return balance.casualUsed >= balance.casualTotal;
  if (name == 'sick leave') return balance.sickUsed >= balance.sickTotal;
  return false;
}
