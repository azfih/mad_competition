// AddLessonScreen.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class AddLessonScreen extends StatefulWidget {
const AddLessonScreen({super.key});

@override
State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
final lessonTitleController = TextEditingController();
final lessonContentController = TextEditingController();
final pdfUrlController = TextEditingController();
final imageUrlController = TextEditingController();

late String courseId;
bool isLoading = false;
bool isGeneratingAi = false;

final DatabaseReference _database = FirebaseDatabase.instance.ref();

@override
void didChangeDependencies() {
super.didChangeDependencies();
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
courseId = args['courseId'];
}

Future<void> addLesson() async {
final title = lessonTitleController.text.trim();
final content = lessonContentController.text.trim();
final pdfUrl = pdfUrlController.text.trim();
final imageUrl = imageUrlController.text.trim();

if (title.isEmpty || (content.isEmpty && pdfUrl.isEmpty && imageUrl.isEmpty)) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Please provide a title and at least one type of content')),
);
return;
}

setState(() => isLoading = true);

try {
// Create lesson data
final lesson = {
'title': title,
'content': content,
'pdfUrl': pdfUrl,
'imageUrl': imageUrl,
'timestamp': ServerValue.timestamp,
};

// Add lesson to the database
final newLessonRef = _database.child('lessons/$courseId').push();
await newLessonRef.set(lesson);

// Generate AI content (summaries & flashcards)
await generateAiContent(title, content, newLessonRef.key!);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Lesson added successfully')),
);

// Clear the form
lessonTitleController.clear();
lessonContentController.clear();
pdfUrlController.clear();
imageUrlController.clear();

// Navigate back after adding if user wants to
final shouldReturn = await showDialog<bool>(
context: context,
builder: (context) => AlertDialog(
title: const Text('Lesson Added'),
content: const Text('Do you want to return to the course?'),
actions: [
TextButton(
onPressed: () => Navigator.of(context).pop(false),
child: const Text('Add Another Lesson'),
),
TextButton(
onPressed: () => Navigator.of(context).pop(true),
child: const Text('Return to Course'),
),
],
),
);

if (shouldReturn == true) {
Navigator.of(context).pop();
}
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error adding lesson: $e')),
);
}

setState(() => isLoading = false);
}

Future<void> generateAiContent(String title, String content, String lessonId) async {
if (content.isEmpty) return;

setState(() => isGeneratingAi = true);

try {
// Simulate AI content generation (in a real app, this would call an API)
await Future.delayed(const Duration(seconds: 1));

// Generate summary (about 20% of the original content length)
final summary = "AI-generated summary for: $title - ${content.length > 50 ? content.substring(0, 50) + '...' : content}";

// Generate flashcards (simple simulation)
final List<Map<String, String>> flashcards = [
{
'question': 'What is the main topic of $title?',
'answer': 'The main topic is related to the content provided in the lesson.',
},
{
'question': 'Key concept from $title?',
'answer': 'A key concept extracted from the lesson material.',
},
];

// Save generated content to database
await _database.child('aiContent/$courseId/$lessonId').set({
'summary': summary,
'flashcards': json.encode(flashcards),
'generatedAt': ServerValue.timestamp,
});
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error generating AI content: $e')),
);
}

setState(() => isGeneratingAi = false);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Add Micro-Lesson")),
body: isLoading
? const Center(child: CircularProgressIndicator())
    : Padding(
padding: const EdgeInsets.all(16.0),
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
TextField(
controller: lessonTitleController,
decoration: const InputDecoration(
labelText: "Lesson Title",
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16),
TextField(
controller: lessonContentController,
decoration: const InputDecoration(
labelText: "Text Content",
border: OutlineInputBorder(),
alignLabelWithHint: true,
),
maxLines: 5,
),
const SizedBox(height: 16),
TextField(
controller: pdfUrlController,
decoration: const InputDecoration(
labelText: "PDF URL (optional)",
border: OutlineInputBorder(),
hintText: 'https://example.com/document.pdf',
),
),
const SizedBox(height: 16),
TextField(
controller: imageUrlController,
decoration: const InputDecoration(
labelText: "Image URL (optional)",
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
const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 16),
Text(
"AI Enhancements",
style: Theme.of(context).textTheme.titleMedium,
),
const SizedBox(height: 8),
const Text(
"Summaries and flashcards will be auto-generated when you add content.",
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: isGeneratingAi ? null : addLesson,
style: ElevatedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 16),
),
child: isGeneratingAi
? const Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(strokeWidth: 2),
),
SizedBox(width: 12),
Text("Generating AI Content..."),
],
)
    : const Text(
"Add Lesson",
style: TextStyle(fontSize: 16),
),
),
],
),
),
),
);
}
}