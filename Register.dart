import 'package:attendanceofadmin/Auth/Login.dart';
import 'package:attendanceofadmin/Databse/Dbhelper.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  DBHelper dbHelper = DBHelper();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // Controller for phone number
  final _dateOfRegistrationController = TextEditingController(); // Controller for date of registration
  String _gender = 'Male'; // Default gender

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Here you can call the save function to insert data into the database
      print('Form Submitted');


      // Save data including new fields
      await dbHelper.saveRegistration({
        'name': _firstNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'Confirmpassword': _confirmPassword.text,
        'gender': _gender,
        'phone': _phoneController.text, // Save phone number
        'date_of_registration': _dateOfRegistrationController.text, // Save date of registration
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false, // This will remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Purple Overlay
          Positioned.fill(
            child: Container(
              color: Colors.purple.withOpacity(0.6), // Semi-transparent purple overlay
            ),
          ),
          // Centered Form
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double cardWidth = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.8;

                  return Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: cardWidth, // Responsive width for Card
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Sign Up', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Text('Gender:'),
                                  Radio<String>(
                                    value: 'Male',
                                    groupValue: _gender,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                  Text('Male'),
                                  Radio<String>(
                                    value: 'Female',
                                    groupValue: _gender,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                  Text('Female'),
                                ],
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _phoneController, // Phone number field
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () async {
                                  // Open the date picker
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(), // Set the initial date
                                    firstDate: DateTime(2000), // Earliest date selectable
                                    lastDate: DateTime(2100), // Latest date selectable
                                  );

                                  if (pickedDate != null) {
                                    // Format the selected date as 'dd/MM/yyyy'
                                    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                    setState(() {
                                      _dateOfRegistrationController.text = formattedDate; // Update the controller
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  // Prevent manual input
                                  child: TextFormField(
                                    controller: _dateOfRegistrationController,
                                    decoration: InputDecoration(
                                      labelText: 'Date of Registration',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please select the date of registration';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),


                              SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text('Sign Up'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to the login screen
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                        (Route<dynamic> route) => false, // This will remove all previous routes
                                  );
                                },
                                child: Text("Already have an account? Log in now."),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
