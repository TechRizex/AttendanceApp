import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../Databse/Dbhelper.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> employees = []; // List of employee data (ID, Name, Mobile)

  // To track the current status, time in, time out, and selected date of each employee
  Map<int, String> statusMap = {};
  Map<int,String> employeeNameMap={};
  Map<int, TimeOfDay> timeInMap = {};
  Map<int, TimeOfDay> timeOutMap = {};
  Map<int, DateTime> dateMap = {}; // To store selected date for each employee
  Map<String, bool> attendanceMarkedMap = {}; // Tracks attendance marking by key

  @override
  void initState() {
    super.initState();
    loadEmployees();
  }

  // Load employee data from the database
  Future<void> loadEmployees() async {
    final employeeData = await _dbHelper.fetchAllEmployees(); // Fetch employees from DB
    setState(() {
      employees = employeeData;
    });

    for (var employee in employees) {
      int employeeId = employee['id'];
      DateTime selectedDate = dateMap[employeeId] ?? DateTime.now();
      String attendanceKey = _generateAttendanceKey(employeeId, selectedDate);

      bool isAttendanceMarked =
      await _dbHelper.isAttendanceMarked(employeeId, selectedDate);
      if (isAttendanceMarked) {
        setState(() {
          attendanceMarkedMap[attendanceKey] = true;
        });
      }
    }
  }

  // Generate a unique attendance key for each employee and date
  String _generateAttendanceKey(int employeeId, DateTime date) {
    return '$employeeId-${DateFormat('yyyy-MM-dd').format(date)}';
  }

  // Adjust time by minutes
  TimeOfDay adjustTime(TimeOfDay time, int adjustment) {
    int totalMinutes = time.hour * 60 + time.minute + adjustment;
    int hours = (totalMinutes ~/ 60) % 24;
    int minutes = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  Future<void> selectDate(int employeeId) async {
    DateTime initialDate = dateMap[employeeId] ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateMap[employeeId] = pickedDate;
      });
    }
  }

  Future<void> saveAttendance(int employeeId) async {
    DateTime selectedDate = dateMap[employeeId] ?? DateTime.now();
    String attendanceKey = _generateAttendanceKey(employeeId, selectedDate);

    if (attendanceMarkedMap[attendanceKey] == true) {
      _showDialog(
        title: 'Attendance Already Marked',
        content:
        'Attendance for this employee on ${DateFormat('yyyy-MM-dd').format(selectedDate)} is already marked.',
      );
    } else {
      // Fetch the employee name from the list
      String? employee = employees.firstWhere(
            (emp) => emp['id'] == employeeId,
        orElse: () => {'name': null},
      )['name'];

      if (employee == null || employee.isEmpty) {
        _showDialog(
          title: 'Error',
          content: 'Employee name could not be found.',
        );
        return;
      }

      String status = statusMap[employeeId] ?? 'Present';
      TimeOfDay timeIn = timeInMap[employeeId] ?? TimeOfDay(hour: 10, minute: 0);
      TimeOfDay timeOut = timeOutMap[employeeId] ?? TimeOfDay(hour: 19, minute: 0);

      Map<String, dynamic> attendanceData = {
        'dateOfAttendance': DateFormat('yyyy-MM-dd').format(selectedDate),
        'status': status,
        'employeename': employee,
        'timeIn':
        '${timeIn.hour.toString().padLeft(2, '0')}:${timeIn.minute.toString().padLeft(2, '0')}',
        'timeOut':
        '${timeOut.hour.toString().padLeft(2, '0')}:${timeOut.minute.toString().padLeft(2, '0')}',
        'attendanceStatus': 1,
      };

      int result = await _dbHelper.saveAttendanceByEmployeeId(employeeId, attendanceData);

      if (result > 0) {
        setState(() {
          attendanceMarkedMap[attendanceKey] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance saved for employee ID: $employeeId')),
        );
      } else {
        _showDialog(
          title: 'Error',
          content: 'Failed to save attendance.',
        );
      }
    }
  }



  void _showDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
        title: Text('Mark Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: employees.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 40,
          dataRowHeight: 70,
          border: TableBorder.all(color: Colors.grey),
          columns: [
            DataColumn(label: Text('Employee Name')),
            DataColumn(label: Text('Mobile No')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Time In')),
            DataColumn(label: Text('Time Out')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Action')),
          ],
          rows: employees.map((employee) {
            int employeeId = employee['id'];
            DateTime selectedDate = dateMap[employeeId] ?? DateTime.now();
            String attendanceKey = _generateAttendanceKey(employeeId, selectedDate);

            return DataRow(cells: [
              DataCell(Text(employee['name'])),
              DataCell(Text(employee['mobile'])),
              DataCell(DropdownButton<String>(
                value: statusMap[employeeId] ?? 'Present',
                onChanged: (value) {
                  setState(() {
                    statusMap[employeeId] = value!;
                  });
                },
                items: ['Present', 'Absent'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        timeInMap[employeeId] =
                            adjustTime(timeInMap[employeeId] ?? TimeOfDay(hour: 10, minute: 0), -5);
                      });
                    },
                  ),
                  Text(
                    '${(timeInMap[employeeId]?.hour ?? 10).toString().padLeft(2, '0')}:${(timeInMap[employeeId]?.minute ?? 0).toString().padLeft(2, '0')}',
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        timeInMap[employeeId] =
                            adjustTime(timeInMap[employeeId] ?? TimeOfDay(hour: 10, minute: 0), 5);
                      });
                    },
                  ),
                ],
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        timeOutMap[employeeId] =
                            adjustTime(timeOutMap[employeeId] ?? TimeOfDay(hour: 19, minute: 0), -5);
                      });
                    },
                  ),
                  Text(
                    '${(timeOutMap[employeeId]?.hour ?? 19).toString().padLeft(2, '0')}:${(timeOutMap[employeeId]?.minute ?? 0).toString().padLeft(2, '0')}',
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        timeOutMap[employeeId] =
                            adjustTime(timeOutMap[employeeId] ?? TimeOfDay(hour: 19, minute: 0), 5);
                      });
                    },
                  ),
                ],
              )),
              DataCell(
                GestureDetector(
                  onTap: () => selectDate(employeeId),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              DataCell(
                attendanceMarkedMap[attendanceKey] == true
                    ? Icon(Icons.check_box, color: Colors.green)
                    : ElevatedButton(
                  onPressed: () {
                    saveAttendance(employeeId);
                  },
                  child: Text('Mark Attendance'),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}