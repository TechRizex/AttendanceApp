import 'package:attendanceofadmin/Auth/Login.dart';
import 'package:attendanceofadmin/Mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'Main/Dashboard.dart';
import 'Main/EmployeeSection.dart';
import 'WidgetsLearn/Statelesswidget.dart';



void main() {
  // Initialize the database factory for sqflite_common_ffi
  // Initialize the FFI database factory
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      // home: CustomTextWidget(message: 'Hello Rahul',),
      home: LoginScreen(),
    );
  }

}

