import 'package:flutter/material.dart';

class QnAWall extends StatefulWidget {
  final String lessonId;
  final String studentId;

  const QnAWall({Key? key, required this.lessonId, required this.studentId}) : super(key: key);

  @override
  _QnAWallState createState() => _QnAWallState();
}

class _QnAWallState extends State<QnAWall> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  List<Map<String, dynamic>> questions = [];

  void _postQuestion() {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      questions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'question': _questionController.text.trim(),
        'postedBy': widget.studentId,
        'replies': [],
      });
      _questionController.clear();
    });
  }

  void _addReply(String questionId, String reply) {
    if (reply.trim().isEmpty) return;

    setState(() {
      final index = questions.indexWhere((q) => q['id'] == questionId);
      if (index != -1) {
        questions[index]['replies'].add({
          'reply': reply.trim(),
          'repliedBy': widget.studentId,
          'timestamp': DateTime.now().toString(),
        });
      }
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Q&A Wall - Lesson ${widget.lessonId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Post a question
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Ask a question',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _postQuestion,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: questions.isEmpty
                  ? Center(child: Text('No questions yet. Be the first to ask!'))
                  : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['question'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          ...q['replies'].map<Widget>((reply) => Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.reply, size: 16),
                                SizedBox(width: 6),
                                Expanded(child: Text(reply['reply'])),
                              ],
                            ),
                          )),
                          TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              labelText: 'Reply...',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () => _addReply(q['id'], _replyController.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
