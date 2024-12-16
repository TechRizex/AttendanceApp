import 'package:attendanceofadmin/ExtraHelperclass.dart';
import 'package:flutter/material.dart';
import '../Databse/Dbhelper.dart';

class AttendanceScreens extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreens> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> attendanceData = [];
  int lateCount = 0;  // Variable to store the count of late employees
  int onTime=0;

  // Function to show DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fetchAttendanceForSelectedDate(); // Fetch data for the selected date
      });
    }
  }

  // Fetch attendance for the selected date
  Future<void> _fetchAttendanceForSelectedDate() async {
    final dbHelper = DBHelper();

    // Formatting date to YYYY-MM-DD format for the query
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    // Fetch attendance data for the selected date
    List<Map<String, dynamic>> data = await dbHelper.fetchEmployeeAttendance(formattedDate);

    // Count the number of late attendances
    lateCount = 0;
    for (var item in data) {
      String timeIn = item['timein'] ?? '';
      if (_getTimeStatus(timeIn) == 'Late') {
        lateCount++;

      }
    }
    Helper.lateemployees=lateCount;
    print('${Helper.lateemployees}');



    onTime= 0;
    for (var item in data) {
      String timeIn = item['timein'] ?? '';
      if (_getTimeStatus(timeIn) == 'On Time') {
        onTime++;

      }
    }
    Helper.ontiememployees=onTime;
    print('${Helper.ontiememployees}');


    // Update the state with fetched data and the late count
    setState(() {
      attendanceData = data;
    });
  }

  // Function to determine the time status
  String _getTimeStatus(String timeIn) {
    if (timeIn.isEmpty) return 'No Time In';

    // Define the comparison time: 10:00 AM
    final DateTime referenceTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 10, 0, 0);

    // Convert the timeIn string to DateTime for comparison
    final List<String> timeParts = timeIn.split(':');
    final DateTime timeInDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));

    // Compare times
    if (timeInDateTime.isAfter(referenceTime)) {
      return 'Late';
    } else if (timeInDateTime.isBefore(referenceTime)) {
      return 'Before Time';
    } else {
      return 'On Time';
    }
  }


  Future<void> _updateAttendance(int attendanceId, Map<String, dynamic> updatedData) async {
    final dbHelper = DBHelper();
    await dbHelper.updateAttendanceById(attendanceId, updatedData);
    setState(() {
      _fetchAttendanceForSelectedDate();  // Refresh data after update
    });
  }



  Future<void> _deleteAttendance(int attendanceId) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteAttendanceById(attendanceId);
    setState(() {
      _fetchAttendanceForSelectedDate();  // Refresh data after deletion
    });
  }




  void _showUpdateDialog(BuildContext context, Map<String, dynamic> data) {
    final TextEditingController timeInController = TextEditingController(text: data['timein']);
    final TextEditingController timeOutController = TextEditingController(text: data['timeout']);
    final TextEditingController statusController = TextEditingController(text: data['status']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeInController,
                decoration: InputDecoration(labelText: 'Time In'),
              ),
              TextField(
                controller: timeOutController,
                decoration: InputDecoration(labelText: 'Time Out'),
              ),
              DropdownButtonFormField<String>(
                value: statusController.text.isEmpty ? null : statusController.text,
                decoration: InputDecoration(labelText: 'Status'),
                items: <String>['Present', 'Absent']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Update the controller's text when a new value is selected
                  statusController.text = newValue!;
                },
              ),

              // Exclude status from update
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedData = {
                  'timein': timeInController.text,
                  'timeout': timeOutController.text,
                  'status': statusController.text,  // Optional, based on your logic
                };

                // Call update function
                _updateAttendance(data['attendanceid'], updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchAttendanceForSelectedDate(); // Initial data fetch for today's date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Attendance"),
        actions: [
          // Display the late count in the AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Late: $lateCount", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DatePicker Button
            Row(
              children: [
                // Format the selected date to only show the date (yyyy-MM-dd)
                Text("Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),

            // DataTable to display the attendance
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: attendanceData.isEmpty
                    ? Center(child: Text('No attendance records available.'))
                    : DataTable(
                  columnSpacing: 25,
                  columns: [
                    DataColumn(label: Text('Employee Name')),
                    DataColumn(label: Text('Mobile')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time In')),
                    DataColumn(label: Text('Time Out')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Attendance Status')),
                    DataColumn(label: Text('Actions')),  // New column for buttons
                  ],
                  rows: attendanceData.map((data) {
                    String timeIn = data['timein'] ?? '';
                    String status = _getTimeStatus(timeIn);
                    Color statusColor = Colors.green;
                    if (status == 'Late') statusColor = Colors.red;
                    if (status == 'Before Time') statusColor = Colors.blue;

                    return DataRow(cells: [
                      DataCell(Text(data['name'] ?? '')),
                      DataCell(Text(data['mobile'] ?? '')),
                      DataCell(Text(data['dateofattendance'] ?? '')),
                      DataCell(Text(timeIn)),
                      DataCell(Text(data['timeout'] ?? '')),
                      DataCell(Text(status, style: TextStyle(color: statusColor))),
                      DataCell(Text(data['status'] ?? '')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showUpdateDialog(context, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Show a confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Are you sure?'),
                                      content: Text('Do you really want to delete this attendance?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog without doing anything
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Call the delete function if confirmed
                                            _deleteAttendance(data['attendanceid']);
                                            print('Id is: ${data['attendanceid']}');
                                            print(data);
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
