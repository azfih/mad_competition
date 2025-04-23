import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String _courseTitle = "";
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    try {
      // Get course data
      final courseSnapshot = await _databaseRef.child('courses/${widget.courseId}').get();
      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _courseTitle = courseData['title'] ?? 'Course Details';
        });

        // Get lessons for this course
        final lessonsSnapshot = await _databaseRef.child('lessons').orderByChild('courseId').equalTo(widget.courseId).get();
        if (lessonsSnapshot.exists) {
          final lessonsData = lessonsSnapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> lessonsList = [];

          lessonsData.forEach((key, value) {
            final lesson = value as Map<dynamic, dynamic>;
            lessonsList.add({
              'id': key,
              'title': lesson['title'] ?? 'Untitled Lesson',
              'order': lesson['order'] ?? 0,
            });
          });

          // Sort lessons by order
          lessonsList.sort((a, b) => a['order'].compareTo(b['order']));

          setState(() {
            _lessons = lessonsList;
          });
        }
      }
    } catch (e) {
      print('Error loading course details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load course details'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_courseTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Micro-lessons for this course',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _lessons.isEmpty
                ? const Center(child: Text('No lessons available for this course'))
                : ListView.builder(
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(lesson['title']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/lessonView',
                      arguments: {'lessonId': lesson['id']},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}