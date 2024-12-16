import 'package:attendanceofadmin/ManagementScreens/AttendanceSheetScreen.dart';
import 'package:attendanceofadmin/ManagementScreens/EmployeeStatus.dart';
import 'package:attendanceofadmin/ManagementScreens/HalfDay.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Auth/Login.dart';
import 'Main/Dashboard.dart';
import 'Main/EmployeeSection.dart';



import 'ManagementScreens/AttendanceScreen.dart';
import 'ManagementScreens/EmployeeFullInformation.dart';
import 'ManagementScreens/LateTimeScreen.dart';
import 'ManagementScreens/LeaveScreen.dart';
import 'ManagementScreens/OverTimeScreen.dart';
import 'ManagementScreens/MakeAttendance.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isSidebarOpen = true;
  String _loggedInEmail = '';


  void _loadLoggedInEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInEmail = prefs.getString('loggedInEmail') ?? 'No Email';
    });
  }
  // Updated titles and screens list
  final List<String> _titles = [
    "Dashboard",
    "Employees",
    "Employee's Full Info",
    "Employee's Status",
    "Make Attendance",
    "Attendance Sheet",
    "Attendance",
    "Late Time",
    "Leave",
    "Over Time",
    "Half Day"
  ];


  final List<Widget> _screens = [
    DashboardScreen(),
    EmployeeListScreen(),
    EmployeeDataScreen(),
    EmployeeStatus(),
    MarkAttendanceScreen(),
    AttendanceSheetScreen(),
    AttendanceScreens(),
    LateTimeScreen(),
    LeaveScreen(),
    OvertimeScreen(),
    HalfDayScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLoggedInEmail();
  }

  void getdialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to logout'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: ()async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('loggedInEmail'); // Remove the logged-in email

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false, // This will remove all previous routes
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSidebarOpen = !_isSidebarOpen;
            });
          },
        ),
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.notifications, color: Colors.black),
              SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  // Define the action when the person icon is clicked
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Profile'),
                        content: Text('Logged in as: $_loggedInEmail'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  children: [

                    Icon(Icons.person, color: Colors.black,  ),




                  ],
                ),
              ),
              SizedBox(width: 8),
              IconButton(onPressed: (){getdialog();}, icon: Icon(Icons.logout)),
              SizedBox(width: 8),
            ],
          )

        ],
      ),

      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSidebarOpen ? 250 : 60, // Adjust width dynamically
            height: MediaQuery.of(context).size.height, // Fullscreen height
            color: Color(0xFF2C2E43),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10), // Top margin adjustment
                if (_isSidebarOpen )
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "MAIN",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildSidebarItem(Icons.dashboard, "Dashboard", 0),
                _buildSidebarItem(Icons.person, "Employees", 1),
                _buildSidebarItem(Icons.person, "Employee's Full Info", 2),
                _buildSidebarItem(Icons.people_alt, "Employee's Status", 3),
                SizedBox(height: 10), // Reduced spacing
                if (_isSidebarOpen)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "MANAGEMENT",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildSidebarItem(Icons.schedule, "Make Attendance", 4),
                _buildSidebarItem(Icons.list_alt, "Attendance Sheet", 5),
                _buildSidebarItem(Icons.check_circle, "Attendance", 6),
                _buildSidebarItem(Icons.warning, "Late Time", 7),
                _buildSidebarItem(Icons.exit_to_app, "Leave", 8),
                _buildSidebarItem(Icons.access_time, "Over Time", 9),
                _buildSidebarItem(Icons.calendar_view_day, "Half Day", 10),
                Spacer(), // Push sidebar content to the top
                // if (_isSidebarOpen)
                //   Padding(
                //     padding: EdgeInsets.all(16.0),
                //     child: Text(
                //       "Footer",
                //       style: TextStyle(
                //         color: Colors.grey[500],
                //         fontSize: 12,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ensure the content always fits within the remaining space
                if (constraints.maxWidth < 200) {
                  return Center(
                    child: Text(
                      "Not enough space for the content.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return AnimatedPadding(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _screens[_currentIndex],
                );
              },
            ),
          ),
        ],
      ),

    );
  }


  Widget _buildSidebarItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        color: isSelected ? Color(0xFF41476A) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (_isSidebarOpen) ...[
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
