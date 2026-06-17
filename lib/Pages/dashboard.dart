import "package:flutter/material.dart";
import "package:new_app/providers/employee_provider.dart";
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/Pages/leavePage.dart';
import 'package:new_app/providers/holiday_porvider.dart';
import 'dart:math';

const kNavy = Color(0xFF1B2E5E);
const kBg = Color(0xFFF5F5F5);

// ── Action Button ──
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isPressed ? Color(0xFF1B2E5E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: _isPressed
                      ? Colors.white
                      : Color.fromARGB(255, 23, 44, 87),
                ),
                SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isPressed
                        ? Colors.white
                        : Color.fromARGB(255, 23, 22, 81),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color borderColor;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends ConsumerWidget {
  final Function(int)? onTabSwitch;
  const DashboardPage({super.key, this.onTabSwitch});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empState = ref.watch(employeeProvider);
    final holidayState = ref.watch(holidayProvider);
    final emp = empState.data;
    final loading = empState.isLoading;
    final holidays = holidayState.holidays;

    return Scaffold(
      backgroundColor: kBg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 222, 232, 249),
        leadingWidth: 200,
        leading: Row(
          children: [
            SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: (emp?.image != null && emp!.image!.isNotEmpty)
                  ? NetworkImage(emp.image!) as ImageProvider
                  : const AssetImage('assets/download.jpg'),
            ),
            const SizedBox(width: 6),
            const Text(
              'Square HRMS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kNavy,
              ),
            ),
            SizedBox(width: 6),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: 30,
            onPressed: () {},
          ),
        ],
        bottom: loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(kNavy),
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        color: kNavy,
        onRefresh: () async {
          final seconds = 1 + Random().nextInt(1);
          await Future.wait([
            ref.read(employeeProvider.notifier).loadEmployee(),
            ref.read(holidayProvider.notifier).loadHolidays(seconds),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileCard(loading: loading, emp: emp),
              _AttendanceCard(loading: loading, emp: emp),
              // ── Stat Cards Row 1 ───────────────────
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    _StatCard(
                      title: 'Present Days',
                      value: loading
                          ? '0'
                          : '${emp?.attendance?.presentDays ?? 0}',
                      unit: loading
                          ? ''
                          : '/${emp?.attendance?.totalDays ?? 0}',
                      borderColor: kNavy,
                      valueColor: kNavy,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      title: 'Leave Balance',
                      value: loading ? '0' : '${emp?.stats?.leaveBalance ?? 0}',
                      unit: 'Days',
                      borderColor: const Color(0xFF265728),
                      valueColor: const Color(0xFF275629),
                    ),
                  ],
                ),
              ),

              // ── Stat Cards Row 2 ───────────────────
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    _StatCard(
                      title: 'Late Count',
                      value: loading ? '0' : '${emp?.stats?.lateCount ?? 0}',
                      unit: ' ',
                      borderColor: const Color(0xFF9D2C24),
                      valueColor: const Color(0xFFA12C23),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      title: 'Pending Approval',
                      value: loading
                          ? '0'
                          : '${emp?.stats?.pendingApproval ?? 0}',
                      unit: 'Items',
                      borderColor: Colors.black,
                      valueColor: Colors.black,
                    ),
                  ],
                ),
              ),

              // ── Quick Actions ──────────────────────
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ActionButton(
                        label: 'Apply\nLeave',
                        icon: Icons.calendar_today,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LeavePage()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        label: 'Attendance',
                        icon: Icons.fingerprint,
                        onTap: () => onTabSwitch?.call(1),
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        label: 'Leave\nHistory',
                        icon: Icons.history,
                        onTap: () => onTabSwitch?.call(2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _HolidayCard(
                isLoading: holidayState.isLoading,
                holidays: holidays,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _HolidayItem extends StatelessWidget {
  final dynamic holiday;
  const _HolidayItem({required this.holiday});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  holiday.month,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),

                Text(
                  holiday.day,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  holiday.type,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final bool loading;
  final dynamic emp;
  const _ProfileCard({required this.loading, required this.emp});

  Widget _buildProfileImage(bool loading, dynamic emp) {
    final imageUrl = loading ? null : emp?.image as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        "assets/profile.png",
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/profile.png",
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Image.asset(
          "assets/profile.png",
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: _buildProfileImage(loading, emp),
            ),
            const SizedBox(height: 10),
            Text(
              loading ? 'User Name' : emp?.name ?? 'User Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kNavy,
              ),
            ),
            Text(loading ? 'Role' : emp?.role ?? 'Role'),
            Text(
              loading
                  ? 'Department: —'
                  : 'Department: ${emp?.department ?? ""}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _StatusBadge(loading: loading, emp: emp),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool loading;
  final dynamic emp;

  const _StatusBadge({required this.loading, required this.emp});

  @override
  Widget build(BuildContext context) {
    final color = loading ? Colors.red : Colors.green;
    final bgColor = loading ? Colors.red.shade100 : Colors.green.shade100;
    final label = loading ? 'Off Duty' : (emp?.status ?? 'Off Duty');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final bool loading;
  final dynamic emp;

  const _AttendanceCard({required this.loading, required this.emp});

  @override
  Widget build(BuildContext context) {
    final percent = loading ? 0.0 : (emp?.attendance?.percent ?? 0.0) as double;
    final percentInt = (percent * 100).toInt();
    final remaining = loading ? 0 : (emp?.attendance?.remainingDays ?? 0);

    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Attendance Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: CircularPercentIndicator(
                radius: 80,
                lineWidth: 10,
                percent: percent,
                progressColor: const Color.fromARGB(255, 39, 92, 41),
                backgroundColor: const Color(0xFFE0E0E0),
                animation: false,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$percentInt%', style: const TextStyle(fontSize: 40)),
                    const Text(
                      'Target met',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                '$remaining days remaining',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _HolidayCard extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> holidays;

  const _HolidayCard({required this.isLoading, required this.holidays});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Holiday',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Calendar'),
                ),
              ],
            ),
            const Divider(),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: kNavy,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (holidays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No upcoming holidays',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: holidays
                    .map((h) => _HolidayItem(holiday: h))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
