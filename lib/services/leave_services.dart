import 'package:new_app/models/leave_model.dart';

class LeaveService {
  /// Simulates a 1-second network fetch for leave balance
  Future<LeaveBalance> fetchLeaveBalance() async {
    await Future.delayed(const Duration(seconds: 1));
    return const LeaveBalance(
      totalRemaining: 18,
      casualUsed: 6,
      casualTotal: 10,
      sickUsed: 8,
      sickTotal: 14,
    );
  }

  /// Simulates a 2-second submit call
  Future<bool> submitLeave(LeaveFormState form) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
