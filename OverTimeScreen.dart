import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Databse/Dbhelper.dart';

class OvertimeScreen extends StatefulWidget {
  @override
  _OvertimeScreenState createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> employees = [];
  String? selectedEmployeeId;
  DateTime? selectedDate;
  TextEditingController overtimeController = TextEditingController();
  List<Map<String, dynamic>> overtimeDetails = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  // Fetch employees from the database
  Future<void> fetchEmployees() async {
    final employeeData = await _dbHelper.fetchAllEmployees();
    setState(() {
      employees = employeeData;
    });
  }

  // Fetch overtime details for the selected date
  Future<void> fetchOvertimeDetails() async {
    if (selectedDate == null) return;
    final overtimeData = await _dbHelper.fetchOvertimeByDate(
      DateFormat('yyyy-MM-dd').format(selectedDate!),
    );
    setState(() {
      overtimeDetails = overtimeData;
    });
  }

  // Save overtime data into the database
  Future<void> saveOvertime() async {
    if (selectedEmployeeId == null || selectedDate == null || overtimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    // Find the employee name based on the selected ID
    String? employeeName = employees.firstWhere(
          (employee) => employee['id'].toString() == selectedEmployeeId,
      orElse: () => {'name': null},
    )['name'];

    if (employeeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee not found.')),
      );
      return;
    }

    Map<String, dynamic> overtimeData = {
      'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'overtimeinhours': overtimeController.text,
      'employeename': employeeName,
    };

    int result = await _dbHelper.saveOvertimeByEmployeeId(
      int.parse(selectedEmployeeId!),
      overtimeData,
    );

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Overtime saved successfully.')),
      );
      clearFields();
      fetchOvertimeDetails(); // Refresh overtime data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save overtime.')),
      );
    }
  }

  // Clear all fields after saving
  void clearFields() {
    setState(() {
      selectedEmployeeId = null;
      selectedDate = null;
      overtimeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overtime Entry'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Employee', style: TextStyle(fontSize: 16)),
            DropdownButtonFormField<String>(
              value: selectedEmployeeId,
              onChanged: (value) {
                setState(() {
                  selectedEmployeeId = value;
                });
              },
              items: employees.map((employee) {
                return DropdownMenuItem<String>(
                  value: employee['id'].toString(),
                  child: Text(employee['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Employee',
              ),
            ),
            SizedBox(height: 16),
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
                  fetchOvertimeDetails(); // Fetch overtime details after date selection
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                      : 'Tap to select date',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: overtimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Over Time (minutes or hours)',
                hintText: 'Enter hours/minutes',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveOvertime,
              child: Text('Save Overtime'),
            ),
            SizedBox(height: 30),
            Text('Overtime Details', style: TextStyle(fontSize: 16 ,color: Colors.purple)),
            if (overtimeDetails.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: overtimeDetails.length,
                itemBuilder: (context, index) {
                  var overtime = overtimeDetails[index];
                  return ListTile(
                    title: Text(overtime['employeename']),
                    subtitle: Text('Overtime Hours: ${overtime['overtimeinhours']}'),
                    trailing: Text(overtime['date']),
                  );
                },
              )
            else
              Text('No overtime data for selected date.'),
          ],
        ),
      ),
    );
  }
}
