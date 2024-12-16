import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../Databse/Dbhelper.dart';

// Assuming DBHelper is already defined as per your provided code

class LeaveScreen extends StatefulWidget {
  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _employees = [];
  String? _selectedEmployee;
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  // Method to fetch all employees from the database
  Future<void> _fetchEmployees() async {
    final List<Map<String, dynamic>> employees = await _dbHelper.fetchAllEmployees();
    setState(() {
      _employees = employees;
    });
  }




  // Method to save the leave entry to the database
  Future<void> _saveLeave() async {
    if (_selectedEmployee == null) {
      // Show an error if no employee is selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an employee')));
      return;
    }

    // Check if date is selected
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a date')));
      return;
    }


    // Prepare leave data
    Map<String, dynamic> leaveData = {
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'employeename':_selectedEmployee,
      'id': _selectedEmployee,
    };

    // Save leave data to the database
    await _dbHelper.saveLeaveByEmployeeId(int.parse(_selectedEmployee!), leaveData);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave saved successfully')));
  }



  // Method to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ) ?? _selectedDate;

    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate); // Update the text field
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _dateController.text = ''; // Set initial text to empty, prompting the user to select a date
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Screen'),backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select employee
            DropdownButton<String>(
              hint: Text('Select Employee'),
              value: _selectedEmployee,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmployee = newValue;
                });
              },
              items: _employees.map<DropdownMenuItem<String>>((Map<String, dynamic> employee) {
                return DropdownMenuItem<String>(
                  value: employee['id'].toString(),
                  child: Text(employee['name']),
                );
              }).toList(),
            ),

            SizedBox(height: 16),

            // Date picker to select the leave date
            GestureDetector(
              onTap: () => _selectDate(context),
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Select Date of Today',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today), // Calendar icon
                    onPressed: () => _selectDate(context), // Open date picker
                  ),
                ),
                readOnly: true, // Prevent manual editing
              ),
            ),

            SizedBox(height: 16),

            // Save button to save the leave entry
            ElevatedButton(
              onPressed: _saveLeave,
              child: Text('Save Leave'),
            ),
          ],
        ),
      ),
    );
  }
}
