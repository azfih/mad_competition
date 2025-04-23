import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final String studentId; // Receiving studentId

  const StudentDashboard({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Course 1: Introduction to Flutter"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/courseDetail',
                arguments: {'courseId': 'courseId1'}, // Passing the course ID as argument
              );
            },
          ),
          ListTile(
            title: const Text("Course 2: Advanced Flutter"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/courseDetail',
                arguments: {'courseId': 'courseId2'}, // Passing the course ID as argument
              );
            },
          ),
        ],
      ),
    );
  }
}
