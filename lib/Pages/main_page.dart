import "package:flutter/material.dart";
import 'package:new_app/Pages/attendence_page.dart';
import 'package:new_app/Pages/dashboard.dart';
import 'package:new_app/Pages/leavePage.dart';
import 'package:new_app/Pages/profile.dart';
import 'package:new_app/Pages/LeaveHistory.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    DashboardPage(onTabSwitch: _switchTab),
    AttendancePage(),
    LeaveHistoryPage(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF1B2E5E),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.fingerprint),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Leave",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
