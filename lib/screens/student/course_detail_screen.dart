import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Detail: $courseId'),
      ),
      body: Center(
        child: Text('Details of course: $courseId'),
      ),
    );
  }
}
