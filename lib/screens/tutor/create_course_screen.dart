// CreateCourseScreen.dart
import 'package:firebase_database/firebase_database.dart';
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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

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

    try {
      final snapshot = await _database.child('courses/$courseId').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        titleController.text = data['title'] ?? '';
        descController.text = data['description'] ?? '';
        imageUrlController.text = data['imageUrl'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading course data: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> saveCourse() async {
    final title = titleController.text.trim();
    final description = descController.text.trim();
    final imageUrl = imageUrlController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and description fields')),
      );
      return;
    }

    final courseData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'tutorId': tutorId,
      'timestamp': ServerValue.timestamp,
    };

    setState(() => isLoading = true);

    try {
      if (courseId == null) {
        // Create new course
        final newCourseRef = _database.child('courses').push();
        await newCourseRef.set(courseData);

        // After creating course, create initial metadata for AI-generated content
        await _database.child('courseMetadata/${newCourseRef.key}').set({
          'hasAiSummary': false,
          'hasFlashcards': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully')),
        );
      } else {
        // Update existing course
        await _database.child('courses/$courseId').update(courseData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving course: $e')),
      );
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseId == null ? "Create Micro-Course" : "Edit Micro-Course"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Cover Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              if (imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('Invalid image URL'),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  courseId == null ? "Create Course" : "Update Course",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (courseId != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Course Lessons',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/addLesson',
                      arguments: {'courseId': courseId},
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Lesson"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/viewLessons',
                      arguments: {
                        'courseId': courseId,
                        'courseTitle': titleController.text,
                      },
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text("View All Lessons"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
