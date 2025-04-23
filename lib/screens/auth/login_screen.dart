import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void loginUser() async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      final role = doc.data()?['role'];

      if (role == 'tutor') {
        Navigator.pushReplacementNamed(context, '/tutorDashboard', arguments: cred.user!.uid);
      } else {
        Navigator.pushReplacementNamed(context, '/studentDashboard', arguments: cred.user!.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loginUser, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
              child: const Text("Don't have an account? Register"),
            )
          ],
        ),
      ),
    );
  }
}
