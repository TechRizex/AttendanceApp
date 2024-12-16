import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Databse/Dbhelper.dart';


class EmployeeDataScreen extends StatefulWidget {
  @override
  _EmployeeDataScreenState createState() => _EmployeeDataScreenState();
}

class _EmployeeDataScreenState extends State<EmployeeDataScreen> {


  final DBHelper dbHelper = DBHelper();
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> employeeData = [];
  late ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEmployeeDataForDate();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Method to load employee data for the selected date
  Future<void> _loadEmployeeDataForDate() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final data = await dbHelper.fetchEmployeeDataForDate(dateStr);
    setState(() {
      employeeData = data;
    });
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadEmployeeDataForDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Data for ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            Row(
              children: [
                Text('Select Date:'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
              ],
            ),
            SizedBox(height: 16),
            // Table displaying employee data
            employeeData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: Scrollbar(
                thumbVisibility: true, // Make the scrollbar always visible
                trackVisibility: true, // Optional: show track visibility
                controller: _scrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Position')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Salary')),
                      DataColumn(label: Text('Mobile')),
                      DataColumn(label: Text('Date of Join')),
                      DataColumn(label: Text('Late Hours')),
                      DataColumn(label: Text('Attendance Status')),
                      DataColumn(label: Text('Time In')),
                      DataColumn(label: Text('Time Out')),
                      DataColumn(label: Text('Late Time')),
                      DataColumn(label: Text('Overtime Hours')),

                    ],
                    rows: employeeData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['employee_name'] ?? '')),
                        DataCell(Text(data['position'] ?? '')),
                        DataCell(Text(data['email'] ?? '')),
                        DataCell(Text(data['salary'].toString())),
                        DataCell(Text(data['mobile']?.toString() ?? '')),
                        DataCell(Text(data['dateofjoin']?.toString() ?? '')),
                        DataCell(Text(data['howmanyhoureslate']?.toString() ?? '')),
                        DataCell(Text(data['status'] ?? '')),
                        DataCell(Text(data['timein']?.toString() ?? '')),
                        DataCell(Text(data['timeout']?.toString() ?? '')),
                        DataCell(Text(data['latetimeinhoursOrMinute']?.toString() ?? '')),
                        DataCell(Text(data['overtimeinhours']?.toString() ?? '')),


                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
