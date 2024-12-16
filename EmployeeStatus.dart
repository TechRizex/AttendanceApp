import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Databse/Dbhelper.dart';

class EmployeeStatus extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<EmployeeStatus> {
  final DBHelper _dbHelper = DBHelper();

  List<Map<String, dynamic>> _employees = [];
  int? _selectedEmployeeId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  Map<String, dynamic>? _attendanceResult;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    List<Map<String, dynamic>> employees = await _dbHelper.fetchAllEmployees();
    setState(() {
      _employees = employees;
    });
  }

  Future<void> _fetchAttendance() async {
    if (_selectedEmployeeId == null) {
      _showError("Please select an employee.");
      return;
    }
    if (_selectedMonth == null) {
      _showError("Please select a month.");
      return;
    }
    if (_selectedYear == null) {
      _showError("Please select a year.");
      return;
    }

    // Fetch present days from the database
    Map<String, dynamic> presentResult = await _dbHelper.fetchAttendanceForMonthYear(
      _selectedEmployeeId!,
      _selectedMonth,
      _selectedYear,
    );

    // Calculate total days in the selected month
    int totalDaysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    // Get a list of present dates
    List<String> presentDates = [];
    if (presentResult['presentDates'] != null &&
        (presentResult['presentDates'] as String).isNotEmpty) {
      presentDates = (presentResult['presentDates'] as String).split(',');
    }

    // Calculate absent dates
    List<String> allDatesInMonth = List.generate(
      totalDaysInMonth,
          (index) => DateFormat('yyyy-MM-dd').format(
        DateTime(_selectedYear, _selectedMonth, index + 1),
      ),
    );

    List<String> absentDates = allDatesInMonth
        .where((date) => !presentDates.contains(date))
        .toList();

    setState(() {
      _attendanceResult = {
        'present': presentResult,
        'absent': {
          'totalDaysAbsent': absentDates.length,
          'absentDates': absentDates.join(','),
        },
      };
    });
  }



  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedEmployeeId,
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value;
                });
              },
              items: _employees.map((employee) {
                return DropdownMenuItem<int>(
                  value: employee['id'], // Replace with actual column name
                  child: Text(employee['name']), // Replace with actual column name
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Employee',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
              items: List.generate(12, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                );
              }),
              decoration: InputDecoration(
                labelText: 'Select Month',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
              items: List.generate(5, (index) {
                int year = DateTime.now().year - index;
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              decoration: InputDecoration(
                labelText: 'Select Year',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Fetch Attendance'),
            ),
            SizedBox(height: 16),
            if (_attendanceResult != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calculate and display the total number of present days or 0 if no dates are present
                        Text(
                          'Total Days Present: ${(_attendanceResult!['present']['presentDates'] != null && (_attendanceResult!['present']['presentDates'] as String).isNotEmpty) ? (_attendanceResult!['present']['presentDates'] as String).split(',').length : 0}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Display the list of dates present
                        if (_attendanceResult!['present']['presentDates'] != null &&
                            (_attendanceResult!['present']['presentDates'] as String).isNotEmpty)
                          Text(
                            'Dates Present:\n${(_attendanceResult!['present']['presentDates'] as String).split(',').join('\n')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        // If there are no dates, show a message
                        if (_attendanceResult!['present']['presentDates'] == null ||
                            (_attendanceResult!['present']['presentDates'] as String).isEmpty)
                          Text(
                            'No  present',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                      ],
                    ),
                  ),


                  SizedBox(width: 16), // Space between columns
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calculate and display the total number of absent days or 0 if no dates are absent
                        Text(
                          'Total Days Absent: ${(_attendanceResult!['absent']['absentDates'] != null && (_attendanceResult!['absent']['absentDates'] as String).isNotEmpty) ? (_attendanceResult!['absent']['absentDates'] as String).split(',').length : 0}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // Display the absent dates in a single line, separated by commas
                        if (_attendanceResult!['absent']['absentDates'] != null &&
                            (_attendanceResult!['absent']['absentDates'] as String).isNotEmpty)
                          Text(
                            'Dates Absent: ${(_attendanceResult!['absent']['absentDates'] as String).split(',').join(', ')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        // If there are no dates, show a message
                        if (_attendanceResult!['absent']['absentDates'] == null ||
                            (_attendanceResult!['absent']['absentDates'] as String).isEmpty)
                          Text(
                            'No dates absent',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                      ],
                    ),
                  )


                ],
              ),


          ],
        ),
      ),
    );
  }
}
