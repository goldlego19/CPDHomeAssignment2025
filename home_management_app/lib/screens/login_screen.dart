import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:home_management_app/models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://cpd-nestease-denzelbaldacchino-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref("users");

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }
      try {
        // Retrieve all users from Firebase
        final snapshot = await _dbRef.get();
        if (!snapshot.exists) {
          _showError("No users found.");
          return;
        }

        final users = snapshot.value as Map<dynamic, dynamic>;
        User? loggedInUser;

        users.forEach((key, userData) {
          if (userData["email"] == _emailController.text &&
              userData["password"] == _passwordController.text) {
            loggedInUser = User(
              id: key,
              name: userData["name"],
              email: userData["email"],
              password: userData["password"],
              role: userData["role"],
              groupId: userData["groupId"],
            );
          }
        });

        if (loggedInUser != null) {
          // Navigate to HomeScreen with user data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(userId: loggedInUser!.id)),
          );
        } else {
          _showError("Invalid email or password.");
        }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple.shade700,
        automaticallyImplyLeading: false,
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
                    Text("Login",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
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
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Login",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                      },
                      child: Text("Don't have an account? Register"),
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
