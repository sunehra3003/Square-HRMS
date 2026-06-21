import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendence_provider.dart';
import 'package:new_app/widget/common_appbar.dart';

const kNavy = Color(0xFF1B2E5E);

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  DateTime _focusedMonth = DateTime.now();

  Color _statusColor(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.grey;
      case 'Absent':
        return Colors.red;
      case 'Weekend':
        return Colors.grey.shade400;
      default:
        return Colors.transparent;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$m $period';
  }

  String _formatDuration(DateTime? punchIn, DateTime? punchOut) {
    if (punchIn == null) return '00.0h';
    final end = punchOut ?? DateTime.now();
    final diff = end.difference(punchIn);
    final hours = diff.inMinutes / 60;
    return '${hours.toStringAsFixed(1)}h';
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayAttendanceProvider);
    final summaryAsync = ref.watch(attendanceSummaryProvider);
    final monthlyAsync = ref.watch(monthlyAttendanceProvider(_focusedMonth));
    final punchState = ref.watch(punchProvider);
    final punchNotifier = ref.read(punchProvider.notifier);
    final locationAsync = ref.watch(attendanceLocationsProvider);

    final today = todayAsync.asData?.value;
    final summary = summaryAsync.asData?.value;
    final isPunchedIn = today?.punchIn != null;
    final isPunchedOut = today?.punchOut != null;
    final isLoading = punchState is AsyncLoading;

    // build calendar status map from monthly records
    final Map<int, String> calendarStatus = {};
    if (monthlyAsync.asData?.value != null) {
      for (final record in monthlyAsync.asData!.value) {
        calendarStatus[record.date.day] = record.status;
      }
    }

    final locationName = locationAsync.asData?.value.isNotEmpty == true
        ? locationAsync.asData!.value.first.name
        : 'Loading...';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CommonAppBar(),
      body: RefreshIndicator(
        color: kNavy,
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(attendanceSummaryProvider);
          ref.invalidate(monthlyAttendanceProvider(_focusedMonth));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Active Shift Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTIVE SHIFT',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(today?.punchIn, today?.punchOut),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: kNavy,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isPunchedIn && !isPunchedOut
                                      ? Colors.green
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPunchedIn && !isPunchedOut
                                    ? 'In Progress • ${_monthName(_focusedMonth.month).substring(0, 3)} ${DateTime.now().day}'
                                    : isPunchedOut
                                    ? 'Completed'
                                    : 'Not Started',
                                style: TextStyle(
                                  color: isPunchedIn && !isPunchedOut
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In: ${_formatTime(today?.punchIn)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Out: ${_formatTime(today?.punchOut)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Stats Row ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Present',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary?.presentDays ?? 0} DAYS',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(width: 1, height: 50, color: Colors.red.shade200),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Late Count',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(summary?.lateCount ?? 0).toString().padLeft(2, '0')} TIMES',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Punch Button ──
              GestureDetector(
                onLongPress: isLoading || isPunchedOut
                    ? null
                    : () {
                        punchNotifier.punch(
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isPunchedIn
                                      ? '✅ Punched out successfully!'
                                      : '✅ Punched in successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        );
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: isPunchedOut ? Colors.grey.shade400 : kNavy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPunchedOut
                                ? Colors.grey.shade300
                                : Colors.green,
                            width: 4,
                          ),
                          color: Colors.white,
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                Icons.fingerprint,
                                size: 50,
                                color: isPunchedOut ? Colors.grey : kNavy,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPunchedOut
                            ? 'Attendance Recorded'
                            : isPunchedIn
                            ? 'Punch Out'
                            : 'Punch In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPunchedOut
                            ? 'See you tomorrow!'
                            : 'Tap and hold to record attendance',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Location Card ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: kNavy,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locationName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'Authorized Network Area',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      child: Container(
                        height: 120,
                        color: Colors.blueGrey.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Calendar ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kNavy,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month - 1,
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month + 1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
                          .map(
                            (d) => SizedBox(
                              width: 36,
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final daysInMonth = DateUtils.getDaysInMonth(
                          _focusedMonth.year,
                          _focusedMonth.month,
                        );
                        final firstWeekday =
                            DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month,
                              1,
                            ).weekday %
                            7;
                        final now = DateTime.now();

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1,
                              ),
                          itemCount: firstWeekday + daysInMonth,
                          itemBuilder: (context, index) {
                            if (index < firstWeekday) return const SizedBox();
                            final day = index - firstWeekday + 1;
                            final isToday =
                                now.year == _focusedMonth.year &&
                                now.month == _focusedMonth.month &&
                                now.day == day;
                            final status = calendarStatus[day];
                            final dotColor = _statusColor(status);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isToday ? kNavy : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isToday
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                if (status != null)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(Colors.green, 'Present'),
                        const SizedBox(width: 12),
                        _legendDot(Colors.red, 'Absent'),
                        const SizedBox(width: 12),
                        _legendDot(Colors.grey, 'Late'),
                        const SizedBox(width: 12),
                        _legendDot(Colors.grey.shade400, 'Weekend'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Daily Activity ──
              const Text(
                'Daily Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kNavy,
                ),
              ),
              const SizedBox(height: 12),
              if (today == null)
                const Text(
                  'No activity recorded today.',
                  style: TextStyle(color: Colors.grey),
                )
              else ...[
                _activityItem(
                  icon: Icons.login,
                  title: 'Check In',
                  subtitle:
                      '${_formatTime(today.punchIn)} • ${today.locationName ?? ''}',
                  color: kNavy,
                ),
                if (today.punchOut != null)
                  _activityItem(
                    icon: Icons.logout,
                    title: 'Check Out',
                    subtitle:
                        '${_formatTime(today.punchOut)} • ${today.locationName ?? ''}',
                    color: Colors.green,
                  )
                else
                  _activityItem(
                    icon: Icons.logout,
                    title: 'Pending Check Out',
                    subtitle: 'Estimated: 06:00 PM',
                    color: Colors.grey,
                  ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
