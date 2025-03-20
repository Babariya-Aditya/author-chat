import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupMessageScreen extends StatefulWidget {
  final String groupId;

  GroupMessageScreen({required this.groupId});

  @override
  _GroupMessageScreenState createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('messages').add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      });

      _messageController.clear();
    }
  }

  void _addPoll(String question) {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).collection('polls').add({
      'question': question,
      'options': ['Option 1', 'Option 2', 'Option 3'], // Hardcoded options
      'votes': [0, 0, 0],
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                if (messageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messageSnapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    final message = messageSnapshot.data!.docs[index];
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text('Sent by: ${message['senderId']}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Type a message',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _addPoll('What\'s your favorite color?'), // Add poll
            child: const Text('Add Poll'),
          ),
        ],
      ),
    );
  }
}
