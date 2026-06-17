import "package:flutter/material.dart";
import 'package:new_app/models/leave_history_data.dart';

class LeaveHistoryPage extends StatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage> {
  // ── Data ──
  final List<LeaveHistoryData> leaves = [
    LeaveHistoryData(
      type: "Annual Leave",
      applied: "Oct 12, 2023",
      from: "Oct 20",
      to: "Oct 25",
      days: "6 Days",
      supervisor: "Dr. Sarah Rahman",
      status: "Approved",
    ),
    LeaveHistoryData(
      type: "Sick Leave",
      applied: "Oct 28, 2023",
      from: "Oct 28",
      to: "Oct 29",
      days: "2 Days",
      supervisor: "Dr. Sarah Rahman",
      status: "Pending",
    ),
    LeaveHistoryData(
      type: "Casual Leave",
      applied: "Sep 15, 2023",
      from: "Sep 18",
      to: "Sep 18",
      days: "1 Day",
      supervisor: "Dr. Sarah Rahman",
      status: "Rejected",
      reason: "Operational requirements during audit week.",
    ),
  ];

  // ── Filter variables ──
  String searchQuery = "";
  String selectedStatus = "All Status";
  String selectedMonth = "All Months";

  // ── Filtered list ──
  List<LeaveHistoryData> get filteredLeaves {
    return leaves.where((leave) {
      final matchSearch = leave.type!.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchStatus =
          selectedStatus == "All Status" || leave.status == selectedStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  // ── Status color ──
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

  // ── Status icon ──
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
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 1,
        leadingWidth: 200,
        leading: Row(
          children: [
            SizedBox(width: 10),
            CircleAvatar(backgroundImage: AssetImage("assets/download.jpg")),
            SizedBox(width: 5),
            Text(
              "Square HRMS",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E5E),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            iconSize: 30,
            onPressed: () {},
          ),
          SizedBox(width: 5),
        ],
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              Text(
                "Leave History",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E5E),
                ),
              ),
              Text(
                "Track and manage your leave applications",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),

              // ── Search ──
              Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search by Type",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Annual, Sick, Casual...",
                          prefixIcon: Icon(Icons.search),
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
              SizedBox(height: 10),

              // ── Filters ──
              Row(
                children: [
                  // Month dropdown
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Month",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
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
                  SizedBox(width: 10),
                  // Status dropdown
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
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
              SizedBox(height: 10),

              // ── Leave List ──
              ...filteredLeaves
                  .map(
                    (leave) => Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Status Icon ──
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
                          SizedBox(width: 10),

                          // ── Leave Card ──
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title + Status badge
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          leave.type ?? "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B2E5E),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              leave.status,
                                            ).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            leave.status ?? "",
                                            style: TextStyle(
                                              color: _statusColor(leave.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Applied on ${leave.applied ?? ""}",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(height: 10),
                                    Divider(),
                                    SizedBox(height: 5),

                                    // Duration + Days
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Duration",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                "${leave.from ?? ""} - ${leave.to ?? ""}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                                              Text(
                                                "Total Days",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                leave.days ?? "",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      leave.status == "Rejected"
                                                      ? Colors.red
                                                      : Color(0xFF1B2E5E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Reason if rejected
                                    if (leave.status == "Rejected" &&
                                        leave.reason != null) ...[
                                      SizedBox(height: 8),
                                      Text(
                                        "Reason: ${leave.reason}",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],

                                    SizedBox(height: 8),
                                    // Supervisor
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Supervisor: ${leave.supervisor ?? ""}",
                                          style: TextStyle(color: Colors.grey),
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
                    ),
                  )
                  .toList(),

              // ── Empty state ──
              if (filteredLeaves.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      "No leave records found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
