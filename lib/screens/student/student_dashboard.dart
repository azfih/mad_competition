import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final String studentId;

  const StudentDashboard({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Introduction to Flutter"),
            subtitle: const Text("By Tutor A"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/courseDetail',
                arguments: {'courseId': 'courseId1'},
              );
            },
          ),
          ListTile(
            title: const Text("Advanced Flutter"),
            subtitle: const Text("By Tutor B"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/courseDetail',
                arguments: {'courseId': 'courseId2'},
              );
            },
          ),
        ],
      ),
    );
  }
}
