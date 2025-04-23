import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  final String? courseId;
  const CreateCourseScreen({super.key, this.courseId});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      FirebaseFirestore.instance.collection('courses').doc(widget.courseId).get().then((doc) {
        final data = doc.data();
        if (data != null) {
          titleController.text = data['title'];
          descController.text = data['description'];
        }
      });
    }
  }

  void saveCourse() async {
    final course = {
      'title': titleController.text,
      'description': descController.text,
      'timestamp': Timestamp.now(),
    };

    if (widget.courseId == null) {
      await FirebaseFirestore.instance.collection('courses').add(course);
    } else {
      await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).update(course);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseId == null ? "Create Course" : "Edit Course")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Course Title")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveCourse,
              child: Text(widget.courseId == null ? "Create" : "Update"),
            ),
          ],
        ),
      ),
    );
  }
}
