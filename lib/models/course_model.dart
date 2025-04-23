import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String tutorId;
  final List<String> enrolledStudentIds;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.tutorId,
    required this.enrolledStudentIds,
  });

  factory Course.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      coverImage: data['coverImage'] ?? '',
      tutorId: data['tutorId'],
      enrolledStudentIds: List<String>.from(data['enrolledStudentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coverImage': coverImage,
      'tutorId': tutorId,
      'enrolledStudentIds': enrolledStudentIds,
    };
  }
}
