import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  bool isLoading = false;

  String? courseId;
  late String tutorId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    courseId = args['courseId'];
    tutorId = args['tutorId'];
    if (courseId != null) loadCourseData();
  }

  Future<void> loadCourseData() async {
    setState(() => isLoading = true);
    final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
    if (doc.exists) {
      final data = doc.data()!;
      titleController.text = data['title'] ?? '';
      descController.text = data['description'] ?? '';
      imageUrlController.text = data['imageUrl'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> saveCourse() async {
    final title = titleController.text.trim();
    final description = descController.text.trim();
    final imageUrl = imageUrlController.text.trim();

    if (title.isEmpty || description.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final courseData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'tutorId': tutorId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() => isLoading = true);

    if (courseId == null) {
      await FirebaseFirestore.instance.collection('courses').add(courseData);
    } else {
      await FirebaseFirestore.instance.collection('courses').doc(courseId).update(courseData);
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseId == null ? "Create Course" : "Edit Course"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveCourse,
                child: Text(courseId == null ? "Create" : "Update"),
              ),
              const SizedBox(height: 12),
              if (courseId != null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/addLesson',
                      arguments: {'courseId': courseId},
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Lesson"),
                )
            ],
          ),
        ),
      ),
    );
  }
}
