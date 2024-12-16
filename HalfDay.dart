import 'package:attendanceofadmin/Databse/Dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // To format the date

class HalfDayScreen extends StatefulWidget {
  @override
  _HalfDayScreenState createState() => _HalfDayScreenState();
}

class _HalfDayScreenState extends State<HalfDayScreen> {
  DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> employees = [];
  String? selectedEmployee;
  TextEditingController hoursLateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? selectedDateData;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  // Load all employees from the database
  Future<void> _loadEmployees() async {
    final employeeList = await dbHelper.fetchAllEmployees();  // Fetch employees from the database
    setState(() {
      employees = employeeList;
    });
  }

  // Method to fetch data for the selected date
  Future<void> _fetchDataForSelectedDate() async {
    final data = await dbHelper.fetchHalfDayDataForDate(DateFormat('yyyy-MM-dd').format(selectedDate));
    setState(() {
      selectedDateData = data.isNotEmpty ? data[0] : null;
    });
  }

  // Method to save data to the half_day table
  Future<void> _saveHalfDay() async {
    if (selectedEmployee == null || hoursLateController.text.isEmpty) {
      // Show an error if no employee is selected or hoursLate field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    final data = {
      'employeename': selectedEmployee,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'howmanyhoureslate': double.parse(hoursLateController.text),
    };

    // Save the data to the database
    await dbHelper.insertHalfDay(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );

    // After saving, fetch the updated data
    _fetchDataForSelectedDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Half Day Entry'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Dropdown
            DropdownButton<String>(
              value: selectedEmployee,
              hint: Text('Select Employee'),
              isExpanded: true,
              items: employees.map((employee) {
                return DropdownMenuItem<String>(
                  value: employee['id'].toString(),
                  child: Text(employee['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedEmployee = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Date Picker
            Text('Select Date:'),
            Row(
              children: [
                Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                      _fetchDataForSelectedDate();  // Fetch data when date is selected
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Hours Late Text Field
            TextField(
              controller: hoursLateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'How many hours late?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Save Button
            ElevatedButton(
              onPressed: _saveHalfDay,
              child: Text('Save'),
            ),
            SizedBox(height: 36),
            // Display selected employee name, date, and late hours if available
            if (selectedDateData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee: ${selectedDateData!['employeename']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Late Hours: ${selectedDateData!['howmanyhoureslate']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),


          ],
        ),
      ),
    );
  }
}
