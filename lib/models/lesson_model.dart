import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String contentType; // 'text', 'image', 'pdf'
  final String contentUrl;
  final String summary;
  final List<String> flashcards;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.contentType,
    required this.contentUrl,
    required this.summary,
    required this.flashcards,
  });

  factory Lesson.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      courseId: data['courseId'],
      title: data['title'],
      contentType: data['contentType'],
      contentUrl: data['contentUrl'],
      summary: data['summary'],
      flashcards: List<String>.from(data['flashcards'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'contentType': contentType,
      'contentUrl': contentUrl,
      'summary': summary,
      'flashcards': flashcards,
    };
  }
}
