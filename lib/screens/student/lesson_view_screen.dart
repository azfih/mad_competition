// lib/screens/student/lesson_view_screen.dart

import 'package:flutter/material.dart';

class LessonViewScreen extends StatelessWidget {
  final String lessonId;

  LessonViewScreen({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lesson View"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lesson ID: $lessonId",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Lesson content goes here. You can display videos, slides, or other media related to the lesson.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Example of navigating back to course details
                Navigator.pop(context);
              },
              child: Text("Back to Course Details"),
            ),
          ],
        ),
      ),
    );
  }
}
