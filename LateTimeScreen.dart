import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../Databse/Dbhelper.dart';






class LateTimeScreen extends StatefulWidget {
  @override
  _LateTimeScreenState createState() => _LateTimeScreenState();
}


class _LateTimeScreenState extends State<LateTimeScreen> {
  List<String> employees = [];
  String? selectedEmployee;
  DateTime selectedDate = DateTime.now(); // Initialize with the current date
  final TextEditingController lateTimeController = TextEditingController();
  List<String> lateEmployees = []; // List to hold late employees for the selected date
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    loadEmployees();
    _fetchLateEmployees();  // Fetch late employees when the screen loads
  }

  @override
  void dispose() {
    lateTimeController.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  Future<void> loadEmployees() async {
    try {
      final List<Map<String, dynamic>> result = await dbHelper.fetchAllEmployees();

      // Extract the employee names
      final List<String> employeeNames = result.map((e) => e['name'].toString()).toList();

      setState(() {
        employees = employeeNames;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchLateEmployees(); // Fetch late employees when the date is changed
    }
  }

  Future<void> _fetchLateEmployees() async {
    try {
      final List<Map<String, dynamic>> result = await dbHelper.fetchLateEmployeesByDate(
        DateFormat('yyyy-MM-dd').format(selectedDate),
      );

      // Extract the late employees' names
      final List<String> lateEmployeesList = result.map((e) => e['employeename'].toString()).toList();

      setState(() {
        lateEmployees = lateEmployeesList;
      });
    } catch (e) {
      print('Error fetching late employees: $e');
    }
  }

  void _saveLateTime() {
    if (selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an employee.')),
      );
      return;
    }

    if (lateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter late time.')),
      );
      return;
    }

    final lateTimeData = {
      'employeename': selectedEmployee,
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'latetimeinhoursOrMinute': lateTimeController.text,
    };

    dbHelper.insertLateTime(lateTimeData).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Late time saved successfully!')),
      );
      lateTimeController.clear(); // Clear the input field
      _fetchLateEmployees(); // Fetch updated late employees list
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save late time.')),
      );
      print('Error saving late time: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Late Time Entry'),backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            employees.isEmpty
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Employee',
                border: OutlineInputBorder(),
              ),
              value: selectedEmployee,
              items: employees
                  .map((employee)=> DropdownMenuItem(
                value: employee,
                child: Text(employee),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedEmployee = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Select Date', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () async {
                DateTime initialDate = selectedDate ?? DateTime.now();
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                  _fetchLateEmployees(); // Fetch overtime details after date selection
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child:   Text(
                    selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : 'Tap to select date',  // Default text when no date is selected
                    style: TextStyle(color: Colors.blue),
                  )

              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: lateTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Late Time (minutes or hours)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveLateTime,
                child: Text('Save Late Time'),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Employees Late on ${DateFormat('yyyy-MM-dd').format(selectedDate)}:',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.purple),
            ),
            SizedBox(height: 8),
            lateEmployees.isEmpty
                ? Center(child: Text('No late employees for this date.'))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: lateEmployees.length,
              itemBuilder: (context, index){
                return ListTile(
                  title: Text(lateEmployees[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
