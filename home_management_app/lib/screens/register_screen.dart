import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_screen.dart';
import 'package:home_management_app/models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("users");

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        // Check if email already exists
        final snapshot = await _dbRef.get();
        if (snapshot.exists) {
          final users = snapshot.value as Map<dynamic, dynamic>;
          bool emailExists = users.values
              .any((user) => user["email"] == _emailController.text);

          if (emailExists) {
            _showError("Email already exists. Please use a different one.");
            return;
          }
        }

        // Create new user
        DatabaseReference newUserRef = _dbRef.push();
        String userId = newUserRef.key!;

        User newUser = User(
          id: userId,
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: 'user',
          groupId: '', // No group assigned initially
        );

        await newUserRef.set({
          "id": newUser.id,
          "name": newUser.name,
          "email": newUser.email,
          "password": newUser.password,
          "role": newUser.role,
          "groupId": newUser.groupId,
        });

        // Navigate back to login screen
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Registration successful! You can now log in.")),
        );
      } catch (e) {
        _showError("An error occurred. Please try again.");
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // 🏠 Home Icon
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Register",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: "Name", border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Please enter your name";
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: "Email", border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Please enter your email";
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: "Password", border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Please enter your password";
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Register",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
