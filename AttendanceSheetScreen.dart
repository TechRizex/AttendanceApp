import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databse/Dbhelper.dart';

class Employee {
  final int id;
  final String name;
  final String position;
  List<bool> attendance;

  Employee({
    required this.id,
    required this.name,
    required this.position,
  }) : attendance =
  List.generate(31, (index) => false); // Assuming 31 days in a month

  // Convert database record to Employee object
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      position: map['position'],
    );
  }
}

class AttendanceSheetScreen extends StatefulWidget {
  @override
  _AttendanceSheetScreenState createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen> {
  ScrollController _horizontalController = ScrollController();
  ScrollController _verticalController = ScrollController();

  List<Employee> employees = [];
  List<String> months = [
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
    "December"
  ];
  String selectedMonth = "December"; // Default month

  bool isLoading = true; // Loading state flag

  // Fetch employees and attendance data
  Future<void> fetchEmployees() async {
    final dbHelper = DBHelper();
    try {
      List<Map<String, dynamic>> employeeData =
      await dbHelper.fetchAllEmployees();

      setState(() {
        employees = employeeData.map((e) => Employee.fromMap(e)).toList();
      });

      // Fetch attendance data after employees are loaded
      await loadAttendanceDataForMonth();
    } catch (e) {
      print("Error fetching employees or attendance: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching employee data!")));
    }
  }

  Future<void> loadAttendanceDataForMonth() async {
    final dbHelper = DBHelper();
    List<String> dates = getDatesForSelectedMonth(selectedMonth);

    // Fetch attendance data for each employee
    try {
      for (var employee in employees) {
        List<Map<String, dynamic>> attendanceData =
        await dbHelper.fetchAttendanceForEmployeeAndMonth(
          employee.id,
          selectedMonth,
          2024, // Assuming year 2024
        );

        // Mark attendance for each date based on the fetched data
        List<String> presentDates =
        attendanceData.map((e) => e['date'].toString()).toList();

        // Update the attendance for the checkboxes
        for (int i = 0; i < employee.attendance.length; i++) {
          String date = dates[i];
          employee.attendance[i] = presentDates.contains(date);
        }
      }
      setState(() {
        isLoading = false; // Set loading to false after data is loaded
      });
    } catch (e) {
      print("Error loading attendance data: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading attendance data!")));
    }
  }

  Future<String> getAttendanceStatuss(String employeeName, String date) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '$employeeName-$date';
    return prefs.getString(key) ?? 'Absent'; // Default to 'Absent' if not found
  }

  Future<void> storeAttendanceStatuss(
      String employeeName, String date, String status) async {
    final prefs = await SharedPreferences.getInstance();
    String key =
        '$employeeName-$date'; // Create a unique key for each employee and date
    await prefs.setString(key, status);
  }

  void saveAttendance() async {
    final dbHelper = DBHelper();
    try {
      for (var employee in employees) {
        for (int i = 0; i < employee.attendance.length; i++) {
          String date = getDatesForSelectedMonth(selectedMonth)[i];
          String status = employee.attendance[i] ? 'Present' : 'Absent';

          DateTime attendanceDate = DateTime.parse(date);

          // Update the attendance data in the database
          await dbHelper.insertAttendanceSheet(
            employee.id, // Store employee ID to associate the attendance data
            attendanceDate.toIso8601String(),
            employee.attendance[i] ? 1 : 0, // 1 for Present, 0 for Absent
          );

          print("Attendance status for ${employee.name} on $date: $status");
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Attendance saved successfully!")));
    } catch (e) {
      print("Error saving attendance: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving attendance!")));
    }
  }

  // Generate the dates for the selected month dynamically
  List<String> getDatesForSelectedMonth(String month) {
    DateTime firstDayOfMonth = DateFormat('MMMM').parse("$month 2024");
    int daysInMonth =
        DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      return DateFormat('yyyy-MM-dd')
          .format(DateTime(2024, firstDayOfMonth.month, index + 1));
    });
  }

  // Update employee attendance based on the selected month
  void updateEmployeeAttendanceForMonth() {
    List<String> dates = getDatesForSelectedMonth(selectedMonth);
    for (var employee in employees) {
      employee.attendance =
          List.generate(dates.length, (index) => false); // Reset attendance
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEmployees(); // Fetch employee data when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    List<String> dates = getDatesForSelectedMonth(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Sheet - $selectedMonth 2024'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Month selection dropdown
            DropdownButton<String>(
              value: selectedMonth,
              onChanged: (newValue) {
                setState(() {
                  selectedMonth = newValue!;
                  updateEmployeeAttendanceForMonth(); // Update attendance when month changes
                  isLoading = true;
                });
                loadAttendanceDataForMonth(); // Reload attendance data for the new month
              },
              items: months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(
                child:
                CircularProgressIndicator()) // Show loading indicator
                : Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Scrollbar(
                    controller: _verticalController,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 12,
                        headingRowHeight: 40,
                        dataRowHeight: 50,
                        border: TableBorder.all(color: Colors.purple),
                        columns: [
                          DataColumn(label: Text('Employee Name')),
                          DataColumn(label: Text('Employee Position')),
                          DataColumn(label: Text('Employee ID')),
                          for (var date in dates)
                            DataColumn(
                                label: Text(date,
                                    style: TextStyle(fontSize: 10))),
                        ],
                        rows: employees
                            .asMap()
                            .map((index, employee) {
                          return MapEntry(
                            index,
                            DataRow(cells: [
                              DataCell(Text(employee.name)),
                              DataCell(Text(employee.position)),
                              DataCell(Text(employee.id.toString())),
                              for (var i = 0; i < dates.length; i++)
                                DataCell(
                                  FutureBuilder<String?>( // Fetch attendance status
                                    future: getAttendanceStatuss(
                                        employee.name,
                                        dates[i]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasData) {
                                        bool isChecked = snapshot.data == 'Present';
                                        return Checkbox(
                                          value: isChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              employee.attendance[i] = value ?? false;
                                            });
                                            // Save attendance status when checkbox changes
                                            storeAttendanceStatuss(
                                                employee.name,
                                                dates[i],
                                                value == true ? 'Present' : 'Absent');
                                          },
                                        );
                                      } else {
                                        return Text('Error fetching status');
                                      }
                                    },
                                  ),
                                ),
                            ]),
                          );
                        })
                            .values
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Save attendance button

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveAttendance(); // Save attendance when the button is pressed
        },
        child: Text('Save',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
    );

  }
}
