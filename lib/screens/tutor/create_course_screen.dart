// create_course_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  final String? courseId;
  final String tutorId;

  const CreateCourseScreen({
    super.key,
    this.courseId,
    required this.tutorId,
  });

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      loadCourseData();
    }
  }

  Future<void> loadCourseData() async {
    setState(() => isLoading = true);
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      titleController.text = data['title'] ?? '';
      descController.text = data['description'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> saveCourse() async {
    final title = titleController.text.trim();
    final description = descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    final courseData = {
      'title': title,
      'description': description,
      'tutorId': widget.tutorId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() => isLoading = true);

    if (widget.courseId == null) {
      await FirebaseFirestore.instance.collection('courses').add(courseData);
    } else {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update(courseData);
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId == null ? "Create Course" : "Edit Course"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Course Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
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