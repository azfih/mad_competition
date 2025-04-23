import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Detail: $courseId')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Micro-lessons for this course',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text("Lesson 1: Widgets Basics"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/lessonView',
                arguments: {'lessonId': 'lesson1'},
              );
            },
          ),
          ListTile(
            title: const Text("Lesson 2: State Management"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/lessonView',
                arguments: {'lessonId': 'lesson2'},
              );
            },
          ),
        ],
      ),
    );
  }
}
