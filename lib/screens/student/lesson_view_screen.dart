import 'package:flutter/material.dart';

class LessonViewScreen extends StatelessWidget {
  final String lessonId;

  const LessonViewScreen({Key? key, required this.lessonId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lesson View")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Lesson ID: $lessonId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Lesson content goes here. Show video/text/slides."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/qnaWall', arguments: {'lessonId': lessonId});
              },
              child: const Text("Go to Q&A Wall"),
            ),
            ElevatedButton(
              onPressed: () {
                // Mark lesson as completed logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lesson marked as completed!')),
                );
              },
              child: const Text("Mark as Completed"),
            ),
          ],
        ),
      ),
    );
  }
}
