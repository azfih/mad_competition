import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonViewScreen extends StatefulWidget {
  final String lessonId;

  const LessonViewScreen({Key? key, required this.lessonId}) : super(key: key);

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _isCompleted = false;
  Map<String, dynamic> _lessonData = {};
  List<Map<String, dynamic>> _aiFlashcards = [];

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    try {
      final lessonSnapshot = await _databaseRef.child('lessons/${widget.lessonId}').get();
      if (lessonSnapshot.exists) {
        final data = lessonSnapshot.value as Map<dynamic, dynamic>;

        // Check if lesson is completed by current user
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          final completionSnapshot = await _databaseRef
              .child('userProgress/$userId/completedLessons/${widget.lessonId}')
              .get();

          setState(() {
            _isCompleted = completionSnapshot.exists && completionSnapshot.value == true;
          });
        }

        // Get AI-generated flashcards
        final flashcardsSnapshot = await _databaseRef
            .child('flashcards')
            .orderByChild('lessonId')
            .equalTo(widget.lessonId)
            .get();

        List<Map<String, dynamic>> flashcards = [];
        if (flashcardsSnapshot.exists) {
          final flashcardsData = flashcardsSnapshot.value as Map<dynamic, dynamic>;
          flashcardsData.forEach((key, value) {
            final flashcard = value as Map<dynamic, dynamic>;
            if (flashcard['isAiGenerated'] == true) {
              flashcards.add({
                'id': key,
                'front': flashcard['front'] ?? '',
                'back': flashcard['back'] ?? '',
              });
            }
          });
        }

        setState(() {
          _lessonData = {
            'id': widget.lessonId,
            'title': data['title'] ?? 'Untitled Lesson',
            'content': data['content'] ?? '',
            'type': data['type'] ?? 'text',
            'courseId': data['courseId'] ?? '',
            'aiGeneratedSummary': data['aiGeneratedSummary'] ?? '',
          };
          _aiFlashcards = flashcards;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson not found'))
        );
      }
    } catch (e) {
      print('Error loading lesson data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load lesson data'))
      );
    }
  }

  Future<void> _markLessonAsCompleted() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be signed in to track progress'))
      );
      return;
    }

    try {
      await _databaseRef
          .child('userProgress/$userId/completedLessons/${widget.lessonId}')
          .set(true);

      // Also update in course progress
      if (_lessonData['courseId'] != null) {
        await _databaseRef
            .child('userProgress/$userId/courseProgress/${_lessonData['courseId']}/${widget.lessonId}')
            .set(true);
      }

      setState(() {
        _isCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson marked as completed!'))
      );
    } catch (e) {
      print('Error marking lesson as completed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update progress'))
      );
    }
  }

  Widget _buildLessonContent() {
    switch (_lessonData['type']) {
      case 'pdf':
      // For PDF you would use a PDF viewer plugin
        return Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: const Text('PDF Viewer would be here'),
        );
      case 'image':
        return Image.network(
          _lessonData['content'],
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 100),
        );
      case 'video':
      // For video you would use a video player plugin
        return Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: const Text('Video Player would be here'),
        );
      case 'text':
      default:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_lessonData['content'] ?? 'No content available'),
        );
    }
  }

  Widget _buildAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lessonData['aiGeneratedSummary'] != null &&
            _lessonData['aiGeneratedSummary'].toString().isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'AI-Generated Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(_lessonData['aiGeneratedSummary']),
              ),
            ],
          ),

        if (_aiFlashcards.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'AI-Generated Flashcards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _aiFlashcards.length,
                  itemBuilder: (context, index) {
                    final flashcard = _aiFlashcards[index];
                    return _buildFlashcard(flashcard);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFlashcard(Map<String, dynamic> flashcard) {
    return GestureDetector(
      onTap: () {
        // Implement flip functionality
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flashcard['front'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Text(
              flashcard['back'],
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _lessonData['title'] ?? 'Lesson View'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          _buildLessonContent(),
          _buildAISection(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.question_answer),
                    label: const Text("Go to Q&A Wall"),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/qnaWall',
                        arguments: {'lessonId': widget.lessonId},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isCompleted
                ? ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Completed"),
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade800,
              ),
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Mark as Completed"),
              onPressed: _markLessonAsCompleted,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}