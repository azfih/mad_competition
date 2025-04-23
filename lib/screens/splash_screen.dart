import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Logo delay

    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final doc = await _db.collection('users').doc(user.uid).get();
      final role = doc.data()?['role'];

      if (role == 'tutor') {
        Navigator.pushReplacementNamed(context, '/tutorDashboard', arguments: user.uid);
      } else {
        Navigator.pushReplacementNamed(context, '/studentDashboard', arguments: user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.jpg', width: 100), // Add your COMSATS logo here
      ),
    );
  }
}
