import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorDashboard extends StatelessWidget {
  final String tutorId;
  const TutorDashboard({super.key, required this.tutorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutor Dashboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where('tutorId', isEqualTo: tutorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final data = course.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: data['imageUrl'] != null
                      ? Image.network(data['imageUrl'], width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/createCourse',
                          arguments: {
                            'courseId': course.id,
                            'tutorId': tutorId,
                          },
                        );
                      } else if (value == 'delete') {
                        FirebaseFirestore.instance.collection('courses').doc(course.id).delete();
                      } else if (value == 'addLesson') {
                        Navigator.pushNamed(
                          context,
                          '/addLesson',
                          arguments: {
                            'courseId': course.id,
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/createCourse',
            arguments: {
              'tutorId': tutorId,
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
