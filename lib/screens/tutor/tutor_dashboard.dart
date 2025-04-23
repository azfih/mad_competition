import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TutorDashboard extends StatefulWidget {
  final String tutorId;
  const TutorDashboard({super.key, required this.tutorId});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool isLoading = true;
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => isLoading = true);

    // Create a listener for real-time updates
    _database.child('courses').orderByChild('tutorId').equalTo(widget.tutorId).onValue.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        courses = [];
        isLoading = false;

        if (data != null) {
          final coursesData = data as Map<dynamic, dynamic>;
          coursesData.forEach((key, value) {
            final course = value as Map<dynamic, dynamic>;
            courses.add({
              'id': key,
              'title': course['title'] ?? '',
              'description': course['description'] ?? '',
              'imageUrl': course['imageUrl'] ?? '',
              'tutorId': course['tutorId'] ?? '',
              'timestamp': course['timestamp'] ?? 0,
            });
          });

          // Sort courses by timestamp (newest first)
          courses.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
        }
      });
    }, onError: (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $error')),
      );
    });
  }

  // Analytics data for dashboard
  Widget _buildAnalyticsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnalyticItem(
                  Icons.book,
                  'Courses',
                  courses.length.toString(),
                  Colors.blue,
                ),
                _buildAnalyticItem(
                  Icons.people,
                  'Students',
                  '${courses.length * 5}', // Simulated data
                  Colors.green,
                ),
                _buildAnalyticItem(
                  Icons.question_answer,
                  'Questions',
                  '${courses.length * 8}', // Simulated data
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildAnalyticsSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Micro-Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: courses.isEmpty
                ? const Center(
              child: Text('No courses yet. Create your first course!'),
            )
                : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (course['imageUrl'] != null && course['imageUrl'].isNotEmpty)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(course['imageUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    course['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        '/createCourse',
                                        arguments: {
                                          'courseId': course['id'],
                                          'tutorId': widget.tutorId,
                                        },
                                      );
                                    } else if (value == 'delete') {
                                      // Show confirmation dialog
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Course'),
                                          content: const Text(
                                              'Are you sure you want to delete this course?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldDelete == true) {
                                        await _database.child('courses/${course['id']}').remove();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Course deleted')),
                                        );
                                      }
                                    } else if (value == 'addLesson') {
                                      Navigator.pushNamed(
                                        context,
                                        '/addLesson',
                                        arguments: {
                                          'courseId': course['id'],
                                        },
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Update')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    const PopupMenuItem(value: 'addLesson', child: Text('Add Lesson')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course['description'] ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/viewLessons',
                                      arguments: {
                                        'courseId': course['id'],
                                        'courseTitle': course['title'],
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.menu_book),
                                  label: const Text('View Lessons'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/addLesson',
                                      arguments: {
                                        'courseId': course['id'],
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Lesson'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/createCourse',
            arguments: {
              'tutorId': widget.tutorId,
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Course'),
      ),
    );
  }
}