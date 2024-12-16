import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Registration table
final String registrationTable = 'registration';
final String columnRegId = 'id';
final String columnRegName = 'name';
final String columnRegEmail = 'email';
final String columnRegPassword = 'password';
final String columnRegConfirmPassword = 'Confirmpassword';
final String columnRegPhone = 'phone';
final String columnRegGender= 'gender';
final String columnRegDateOfRegistration = 'date_of_registration';



// Employee table
final String employeeTable = 'employee';
final String columnId = 'id';
final String columnName = 'name';
final String columnPosition = 'position';
final String columnEmail = 'email';
final String columnSalary = 'salary';
final String columnMobile = 'mobile';
final String columnDateOfJoin = 'dateofjoin';

// Attendance table
final String attendanceTable = 'attendance';
final String columnAttendanceId = 'attendanceid';
final String columnAttendanceEmployeeName='employeename';
final String columnDateOfAttendance = 'dateofattendance';
final String columnStatus = 'status';  // 'present', 'absent'
final String columnTimeIn = 'timein';
final String columnTimeOut = 'timeout';
final String columnStatusOfAttendance='attendancestatus';


// Latetime table
final String lateTimeTableName = 'latetimetable';
final String columnLateTimeId = 'latetimetableid';
final String columnLateTimeEmployeeName = 'employeename';
final String columnLateTimeDate = 'date';
final String columnLateTimeinMinuteorhours = 'latetimeinhoursOrMinute';


// Overtime table
final String overtimeTable = 'overtime';
// Add employeename column to the overtime table
final String columnOverTimeEmployeeName = 'employeename';
final String columnOvertimeId = 'overtimetableid';
final String columnOvertimeDate = 'date';
final String columnOvertimeInHours = 'overtimeinhours';

// Leave table
final String leaveTable = 'leave';
final String columnLeaveId = 'leavetableid';
final String columnLeaveEmployename = 'employeename';
final String columnLeaveDate = 'date';
// Half Day table
final String HalfTableName = 'half_day';
final String columnHalfId= 'id';
final String columnHalfEmploeyeeName = 'employeename';
final String columnHalfDate = 'date';
final String columnHalfhoureshalfdya='howmanyhoureslate';


class DBHelper {
  static Database? _database;

  // Open the database and create tables if they don't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }




  _initDB() async {
    String path = join(await getDatabasesPath(), 'company.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate,readOnly: false);
  }

  // Creating tables
  _onCreate(Database db, int version) async {

    // Create Registration Table
    await db.execute('''
      CREATE TABLE $registrationTable (
        $columnRegId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRegName TEXT,
        $columnRegEmail TEXT,
        $columnRegPassword TEXT,
        $columnRegPhone TEXT,
        $columnRegDateOfRegistration TEXT,
        $columnRegConfirmPassword TEXT,
        $columnRegGender TEXT
      )
    ''');
    // Create Employee Table
    await db.execute('''
      CREATE TABLE $employeeTable(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT,
        $columnPosition TEXT,
        $columnEmail TEXT,
        $columnSalary INTEGER,
        $columnMobile TEXT,
        $columnDateOfJoin TEXT
      )
    ''');
    //Creating attendance Table

    await db.execute(''' 
  CREATE TABLE $attendanceTable(
    $columnAttendanceId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnDateOfAttendance TEXT,
    $columnAttendanceEmployeeName TEXT,
    $columnStatus TEXT,
    $columnTimeIn TEXT,
    $columnTimeOut TEXT,
    $columnId INTEGER,
    $columnStatusOfAttendance INTEGER DEFAULT 0, -- 0 for false, 1 for true
    FOREIGN KEY($columnId) REFERENCES $employeeTable($columnId)
  )
''');

    //Create late time Table

    await db.execute(''' 
  CREATE TABLE $lateTimeTableName (
    $columnLateTimeId INTEGER PRIMARY KEY, 
    $columnLateTimeEmployeeName TEXT, 
    $columnLateTimeDate TEXT, 
    $columnLateTimeinMinuteorhours TEXT, 
    FOREIGN KEY ($columnLateTimeId) REFERENCES $employeeTable ($columnId)
  )
''');



    // Create Overtime Table
    await db.execute('''
      CREATE TABLE $overtimeTable(
        $columnOvertimeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnOvertimeDate TEXT,
        $columnOverTimeEmployeeName TEXT,
        $columnOvertimeInHours INTEGER,
        $columnId INTEGER,
        FOREIGN KEY($columnId) REFERENCES $employeeTable($columnId)
      )
    ''');

    // Create Leave Table
    await db.execute('''
      CREATE TABLE $leaveTable(
        $columnLeaveId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnLeaveDate TEXT,
        $columnLeaveEmployename TEXT,
        $columnId INTEGER,
        FOREIGN KEY($columnId) REFERENCES $employeeTable($columnId)
      )
    ''');


    // Create Half_Day Table
    await db.execute('''
      CREATE TABLE $HalfTableName(
        $columnHalfId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnHalfEmploeyeeName TEXT,
        $columnHalfDate TEXT,
        $columnHalfhoureshalfdya TEXT,
        FOREIGN KEY($columnId) REFERENCES $employeeTable($columnId)
      )
    ''');


    //Create AttendanceSheet Table
    await db.execute(''' 
    CREATE TABLE   attendanceSheet(
      id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Primary key for attendanceSheet
      employeeId INTEGER,  -- Foreign key column to link to employee table
      date TEXT,
      status BOOLEAN,
      FOREIGN KEY ($columnId) REFERENCES $employeeTable($columnId)  -- Foreign key constraint
    );
  ''');

  }
  Future<void> createRegistrationTable() async {
    final db = await database;  // Get the database instance

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $registrationTable (
       $columnRegId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRegName TEXT,
        $columnRegEmail TEXT,
        $columnRegPassword TEXT,
        $columnRegPhone TEXT,
        $columnRegDateOfRegistration TEXT,
        $columnRegConfirmPassword TEXT,
        $columnRegGender TEXT
    );
  ''');

    // Log a message to the console once the table is created
    print("$registrationTable table created or already exists.");
  }


  // Method to save new registration
  Future<int> saveRegistration(Map<String, dynamic> registrationData) async {
    final db = await database;
    return await db.insert(registrationTable, registrationData);
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;

    var result = await db.query(
      registrationTable,
      where: '$columnRegEmail = ? AND $columnRegPassword = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }



  // Method to fetch all relevant employee data for a selected date
  Future<List<Map<String, dynamic>>> fetchEmployeeDataForDate(String date) async {
    final db = await database;

    // Perform a complex query to join multiple tables based on date
    final query = '''
      SELECT e.name AS employee_name, 
             e.position, 
             e.email, 
             e.salary, 
             e.mobile, 
             e.dateofjoin, 
             hd.howmanyhoureslate, 
             a.status, 
             a.timein, 
             a.timeout, 
             lt.latetimeinhoursOrMinute,
             ot.overtimeinhours, 
             l.date AS leave_date
      FROM $employeeTable e
      LEFT JOIN $attendanceTable a ON e.name = a.employeename AND a.dateofattendance = ?
      LEFT JOIN half_day hd ON e.name = hd.employeename AND hd.date = ?
      LEFT JOIN $lateTimeTableName lt ON e.name = lt.employeename AND lt.date = ?
      LEFT JOIN $overtimeTable ot ON e.name = ot.employeename AND ot.date = ?
      LEFT JOIN $leaveTable l ON e.id = l.employeename AND l.date = ?
      ORDER BY e.name;
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query, [date, date, date, date, date]);

    return result;
  }


  // Fetch all employees
  Future<List<Map<String, dynamic>>> fechALLAttendance() async {
    final db = await database;
    return await db.query(leaveTable);
  }


  // Fetch all employees
  Future<List<Map<String, dynamic>>> fetchAllEmployees() async {
    final db = await database;
    return await db.query(employeeTable);
  }

  // Save new employee
  Future<int> saveEmployee(Map<String, dynamic> employeeData) async {
    final db = await database;
    return await db.insert(employeeTable, employeeData);
  }

  // Fetch overtime details by date
  Future<List<Map<String, dynamic>>> fetchOvertimeByDate(String date) async {
    final db = await database;
    return await db.query(
      'overtime',
      where: 'date = ?',
      whereArgs: [date],
    );
  }


  Future<void> insertLateTime(Map<String, dynamic> lateTimeData) async {
    final db = await database;
    await db.insert(
      lateTimeTableName,
      lateTimeData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  // Fetching employees who are late on a specific date
  Future<List<Map<String, dynamic>>> fetchLateEmployeesByDate(String date) async {
    final db = await database;

    // Query the database to get employees who are late on the selected date
    final result = await db.query(
    lateTimeTableName,
      where: '$columnLateTimeDate = ?',
      whereArgs: [date],
    );

    return result;
  }


  // Update employee by ID
  Future<int> updateEmployeeById(int id, Map<String, dynamic> employeeData) async {
    final db = await database;
    return await db.update(employeeTable, employeeData,
        where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete employee by ID
  Future<int> deleteEmployeeById(int id) async {
    final db = await database;
    // Delete employee from attendance, overtime, and leave tables
    await db.delete(attendanceTable, where: '$columnId = ?', whereArgs: [id]);
    await db.delete(overtimeTable, where: '$columnId = ?', whereArgs: [id]);
    await db.delete(leaveTable, where: '$columnId = ?', whereArgs: [id]);
    return await db.delete(employeeTable, where: '$columnId = ?', whereArgs: [id]);
  }



  // Save overtime for employee by ID
  Future<int> saveOvertimeByEmployeeId(int employeeId, Map<String, dynamic> overtimeData) async {
    final db = await database;
    overtimeData[columnId] = employeeId;
    return await db.insert(overtimeTable, overtimeData);
  }

  // Save leave for employee by ID
  Future<int> saveLeaveByEmployeeId(int employeeId, Map<String, dynamic> leaveData) async {
    final db = await database;
    leaveData[columnId] = employeeId;
    return await db.insert(leaveTable, leaveData);
  }

  Future<List<Map<String, dynamic>>> fetchEmployeeWithAttendance() async {
    final db = await database;
    // Using INNER JOIN to combine employee and attendance tables
    String query = '''
    SELECT 
      $employeeTable.*, 
      $attendanceTable.$columnAttendanceId, 
      $attendanceTable.$columnDateOfAttendance, 
      $attendanceTable.$columnStatus, 
      $attendanceTable.$columnTimeIn, 
      $attendanceTable.$columnTimeOut 
    FROM $employeeTable
    INNER JOIN $attendanceTable ON $employeeTable.$columnId = $attendanceTable.$columnId
  ''';
    return await db.rawQuery(query);
  }


  Future<List<Map<String, dynamic>>> fetchEmployeeWithOvertimeAndLeave() async {
    final db = await database;
    // Query to join employee with overtime and leave
    String query = '''
    SELECT 
      $employeeTable.$columnId, 
      $employeeTable.$columnName, 
      $employeeTable.$columnPosition, 
      $employeeTable.$columnEmail, 
      $employeeTable.$columnSalary, 
      $employeeTable.$columnMobile, 
      $employeeTable.$columnDateOfJoin, 
      SUM($overtimeTable.$columnOvertimeInHours) AS totalOvertimeHours,
      GROUP_CONCAT($leaveTable.$columnLeaveDate) AS leaveDates
    FROM $employeeTable
    LEFT JOIN $overtimeTable ON $employeeTable.$columnId = $overtimeTable.$columnId
    LEFT JOIN $leaveTable ON $employeeTable.$columnId = $leaveTable.$columnId
    GROUP BY $employeeTable.$columnId
  ''';

    return await db.rawQuery(query);
  }



  // Method to get the total count of employees
  Future<int> getTotalEmployeesCount() async {
    final db = await database;
    // Querying the employee table and using COUNT(*) to get the number of employees
    var result = await db.rawQuery('SELECT COUNT(*) FROM $employeeTable');
    // Returning the count from the result (first row, first column)
    return Sqflite.firstIntValue(result) ?? 0;
  }




  // Method to count the number of employees who have taken leave
  Future<int> getNumberOfEmployeesOnLeave() async {
    final db = await database;

    // Query to count distinct employees who have taken leave
    String query = '''
    SELECT COUNT(DISTINCT $columnId) 
    FROM $leaveTable
  ''';

    // Execute the query and return the count
    var result = await db.rawQuery(query);

    // Returning the count (first row, first column)
    return Sqflite.firstIntValue(result) ?? 0;
  }



  Future<List<Map<String, dynamic>>> fetchEmployeesOnLeave() async {
    final db = await database;

    // Query to join employee with leave and count the leave days, filtering only those on leave
    String query = '''
    SELECT 
      $employeeTable.$columnName, 
      GROUP_CONCAT($leaveTable.$columnLeaveDate) AS leaveDates,
      COUNT($leaveTable.$columnLeaveDate) AS leaveCount
    FROM $employeeTable
    LEFT JOIN $leaveTable ON $employeeTable.$columnId = $leaveTable.$columnId
    WHERE $leaveTable.$columnLeaveDate IS NOT NULL
    GROUP BY $employeeTable.$columnId
  ''';

    // Execute the query and return the results
    return await db.rawQuery(query);
  }

  // Fetch attendance for a specific date (with INNER JOIN)
  Future<List<Map<String, dynamic>>> fetchEmployeeAttendance(String date) async {
    final db = await database;
    // Using INNER JOIN to combine employee and attendance tables, and filtering by date
    String query = '''
      SELECT 
     $employeeTable.$columnId,
        $employeeTable.$columnName, 
        $employeeTable.$columnMobile, 
        $employeeTable.$columnId, 
        $attendanceTable.$columnDateOfAttendance, 
        $attendanceTable.$columnStatus,
         $attendanceTable.$columnAttendanceId,
        $attendanceTable.$columnTimeIn, 
        $attendanceTable.$columnTimeOut 
      FROM $employeeTable
      INNER JOIN $attendanceTable 
        ON $employeeTable.$columnId = $attendanceTable.$columnId
      WHERE $attendanceTable.$columnDateOfAttendance = ?
    ''';

    return await db.rawQuery(query, [date]);
  }

  Future<Map<String, dynamic>> fetchAttendanceForMonthYear(int employeeId, int month, int year) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      attendanceTable,
      where: '$columnId = ? AND strftime("%m", $columnDateOfAttendance) = ? AND strftime("%Y", $columnDateOfAttendance) = ?',
      whereArgs: [employeeId, month.toString().padLeft(2, '0'), year.toString()],
    );

    // Extract present dates from result
    List<String> presentDates = result.map((row) => row[columnDateOfAttendance].toString()).toList();

    return {'presentDates': presentDates.join(',')};
  }

  Future<int> saveAttendanceByEmployeeId(int employeeId, Map<String, dynamic> attendanceData) async {
    final db = await database;
    int result = await db.insert(
      attendanceTable,
      {
        'attendanceid': null,
        'id': employeeId,
        'dateofattendance': attendanceData['dateOfAttendance'],
        'employeename':attendanceData['employeename'],
        'status': attendanceData['status'],
        'timein': attendanceData['timeIn'],
        'timeout': attendanceData['timeOut'],
        'attendancestatus': 1, // Mark attendance status as true
      },
    );
    return result;
  }

  Future<bool> isAttendanceMarked(int employeeId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, dynamic>> result = await db.query(
      attendanceTable,
      where: '$columnId = ? AND dateofattendance = ?',
      whereArgs: [employeeId, formattedDate],
    );
    return result.isNotEmpty && result.first['attendancestatus'] == 1;
  }



  Future<void> updateAttendance(int employeeId, DateTime attendanceDate, String status) async {
    final db = await database;
    await db.update(
      'attendance',
      {'status': status},
      where: 'id = ? AND dateofattendance = ?',
      whereArgs: [employeeId, attendanceDate.toIso8601String()],
    );
  }

  Future<void> insertAttendance(int employeeId, DateTime attendanceDate, String status) async {
    final db = await database;
    await db.insert(
      'attendance',
      {
        'id': employeeId,
        'dateofattendance': attendanceDate.toIso8601String(),
        'status': status,
      },
    );
  }



  // Additional helper methods (optional)
  Future<int> insertHalfDay(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('half_day', data);
  }

  Future<List<Map<String, dynamic>>> fetchHalfDays() async {
    final db = await database;
    return await db.query('half_day');
  }





  // Fetch half-day data for a specific date
  Future<List<Map<String, dynamic>>> fetchHalfDayDataForDate(String date) async {
    final db = await database;

    // Query the database for the data based on the selected date
    final List<Map<String, dynamic>> result = await db.query(
      'half_day',
      where: 'date = ?',
      whereArgs: [date],
    );

    return result;
  }
// Inside DBHelper class

// Fetch attendance for a specific employee and month
  Future<List<Map<String, dynamic>>> fetchAttendanceForEmployeeAndMonth(int employeeId, String month, int year) async {
    final db = await database;
    String monthFormatted = DateFormat('MM').format(DateFormat('MMMM').parse(month));
    String yearFormatted = year.toString();
    return await db.query(
      'attendanceSheet',
      where: 'employeeId = ? AND strftime("%m", date) = ? AND strftime("%Y", date) = ?',
      whereArgs: [employeeId, monthFormatted, yearFormatted],
    );
  }

// Insert attendance record into the database
  Future<void> insertAttendanceSheet(int employeeId, String date, int status) async {
    final db = await database;
    await db.insert(
      'attendanceSheet',
      {
        'employeeId': employeeId,
        'date': date,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace the existing record if any
    );
  }




// Method to truncate the attendance table (delete all records)
  Future<void> truncateAttendance() async {
    final db = await database; // Get the database instance

    try {
      // Perform the DELETE operation on the attendance table
      await db.delete('$HalfTableName');  // This deletes all rows in the table
      print('Attendance table truncated successfully.');
    } catch (e) {
      print('Error truncating attendance table: $e');
    }
  }

  // Delete attendance by ID
  Future<int> deleteAttendanceById(int attendanceId) async {
    final db = await database;
    return await db.delete(attendanceTable, where: '$columnAttendanceId = ?', whereArgs: [attendanceId]);
  }

// Update attendance by ID
  Future<int> updateAttendanceById(int attendanceId, Map<String, dynamic> updatedData) async {
    final db = await database;
    return await db.update(attendanceTable, updatedData, where: '$columnAttendanceId = ?', whereArgs: [attendanceId]);
  }
// Add a column to a table dynamically if it doesn't already exist
  Future<void> addColumnToTable(String tableName, String columnName, String columnType) async {
    final db = await database;

    // Check if the column already exists in the table
    var result = await db.rawQuery('PRAGMA table_info($tableName)');
    bool columnExists = false;

    for (var column in result) {
      if (column['name'] == columnName) {
        columnExists = true;
        break;
      }
    }

    if (!columnExists) {
      // Add the column if it doesn't exist
      await db.execute('''
      ALTER TABLE $tableName
      ADD COLUMN $columnName $columnType
    ''');
      print('Column "$columnName" of type "$columnType" added to the table "$tableName"');
    } else {
      print('Column "$columnName" already exists in the table "$tableName"');
    }
  }




  Future<void> dropTable(String tableName) async {
    final db = await database;  // Get the database instance

    // Execute the DROP TABLE SQL command
    await db.execute('''
    DROP TABLE IF EXISTS $tableName;
  ''');

    // Log a message to the console once the table is dropped
    print("Table $tableName has been dropped.");
  }


}
