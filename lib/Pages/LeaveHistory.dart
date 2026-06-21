import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/models/leave_history_data.dart';
import 'package:new_app/providers/leave_provider.dart';
import 'package:new_app/widget/common_appbar.dart'; // adjust path if different

class LeaveHistoryPage extends ConsumerStatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  ConsumerState<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends ConsumerState<LeaveHistoryPage> {
  String searchQuery = "";
  String selectedStatus = "All Status";
  String selectedMonth = "All Months";

  List<LeaveHistoryData> _filterLeaves(List<LeaveHistoryData> leaves) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return leaves.where((leave) {
      final matchSearch = (leave.type ?? "").toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchStatus =
          selectedStatus == "All Status" || leave.status == selectedStatus;

      bool matchMonth = true;
      if (selectedMonth != "All Months" && leave.applied != null) {
        final shortMonth = leave.applied!.substring(0, 3);
        final fullMonth = monthNames.firstWhere(
          (m) => m.startsWith(shortMonth),
          orElse: () => "",
        );
        matchMonth = fullMonth == selectedMonth;
      }

      return matchSearch && matchStatus && matchMonth;
    }).toList();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Pending":
        return Colors.grey;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case "Approved":
        return Icons.check_circle;
      case "Pending":
        return Icons.pending;
      case "Rejected":
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(leaveHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CommonAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(leaveHistoryProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Leave History",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E5E),
                  ),
                ),
                const Text(
                  "Track and manage your leave applications",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Search by Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Annual, Sick, Casual...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Month",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: selectedMonth,
                                items:
                                    [
                                          "All Months",
                                          "January",
                                          "February",
                                          "March",
                                          "April",
                                          "May",
                                          "June",
                                          "July",
                                          "August",
                                          "September",
                                          "October",
                                          "November",
                                          "December",
                                        ]
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMonth = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: selectedStatus,
                                items:
                                    [
                                          "All Status",
                                          "Approved",
                                          "Pending",
                                          "Rejected",
                                        ]
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStatus = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                historyAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, __) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Failed to load leave history',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ),
                  ),
                  data: (allLeaves) {
                    final filteredLeaves = _filterLeaves(allLeaves);

                    if (filteredLeaves.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            "No leave records found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: filteredLeaves.map((leave) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    leave.status,
                                  ).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _statusIcon(leave.status),
                                  color: _statusColor(leave.status),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              leave.type ?? "",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1B2E5E),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  leave.status,
                                                ).withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                leave.status ?? "",
                                                style: TextStyle(
                                                  color: _statusColor(
                                                    leave.status,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Applied on ${leave.applied ?? ""}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Duration",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${leave.from ?? ""} - ${leave.to ?? ""}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Total Days",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    leave.days ?? "",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          leave.status ==
                                                              "Rejected"
                                                          ? Colors.red
                                                          : const Color(
                                                              0xFF1B2E5E,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (leave.status == "Rejected" &&
                                            leave.reason != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            "Reason: ${leave.reason}",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Supervisor: ${leave.supervisor ?? "Not assigned"}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
