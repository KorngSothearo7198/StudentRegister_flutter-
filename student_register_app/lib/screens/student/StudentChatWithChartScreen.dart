import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentChatWithChartScreen extends StatefulWidget {
  final String studentchartId; // student ID
  final String adminId;
  final String adminName;
  final String adminPhoto;

  const StudentChatWithChartScreen({
    super.key,
    required this.studentchartId,
    required this.adminId,
    required this.adminName,
    required this.adminPhoto,
  });

  @override
  State<StudentChatWithChartScreen> createState() =>
      _StudentChatWithChartScreenState();
}

class _StudentChatWithChartScreenState
    extends State<StudentChatWithChartScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.studentchartId)
        .collection('messages')
        .add({
      'text': text,
      'sender': widget.studentchartId,
      'receiver': widget.adminId,
      'time': Timestamp.now(),
      'isRead': false,
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.adminPhoto.isNotEmpty ? NetworkImage(widget.adminPhoto) : null,
              child: widget.adminPhoto.isEmpty
                  ? Text(widget.adminName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.adminName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.studentchartId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>? ?? {};
                    final text = data['text'] ?? '';
                    final sender = data['sender'] ?? 'Unknown';

                    return ListTile(
                      title: Align(
                        alignment: sender == widget.studentchartId
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sender == widget.studentchartId
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: sender == widget.studentchartId
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
