import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;
  const AddLessonScreen({super.key, required this.courseId});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final lessonTitleController = TextEditingController();
  final lessonContentController = TextEditingController();

  void addLesson() async {
    final lesson = {
      'title': lessonTitleController.text,
      'content': lessonContentController.text,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('lessons')
        .add(lesson);

    lessonTitleController.clear();
    lessonContentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Lesson")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: lessonTitleController, decoration: const InputDecoration(labelText: "Lesson Title")),
            TextField(controller: lessonContentController, decoration: const InputDecoration(labelText: "Content")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: addLesson, child: const Text("Add Lesson")),
          ],
        ),
      ),
    );
  }
}
