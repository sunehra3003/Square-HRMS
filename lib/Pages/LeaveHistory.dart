import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/models/leave_history_data.dart';
import 'package:new_app/providers/leave_provider.dart';
import 'package:new_app/widget/common_appbar.dart';

class LeaveHistoryPage extends ConsumerStatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  ConsumerState<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends ConsumerState<LeaveHistoryPage> {
  // ── Data ──

  // ── Filter variables ──
  String searchQuery = "";
  String selectedStatus = "All Status";
  String selectedMonth = "All Months";

  // ── Filtered list ──
  List<LeaveHistoryData> _filterLeaves(List<LeaveHistoryData> leaves) {
    return leaves.where((leave) {
      final matchSearch = (leave.type ?? "").toLowerCase().contains(
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
            ],
          ),
        ),
      ),
    );
  }
}
