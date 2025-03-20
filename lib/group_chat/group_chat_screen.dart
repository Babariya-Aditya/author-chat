// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class GroupChatScreen extends StatefulWidget {
//   final String groupId;
//
//   GroupChatScreen({required this.groupId});
//
//   @override
//   _GroupChatScreenState createState() => _GroupChatScreenState();
// }
//
// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final _messageController = TextEditingController();
//   final _pollQuestionController = TextEditingController();
//   final _pollOptionController = TextEditingController();
//   String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   List<String> _pollOptions = [];
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;
//
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.groupId)
//         .collection('messages')
//         .add({
//       'type': 'text',
//       'text': _messageController.text.trim(),
//       'senderId': _currentUserId,
//       'timestamp': Timestamp.now(),
//     });
//
//     _messageController.clear();
//   }
//
//   Future<void> _createPoll() async {
//     if (_pollQuestionController.text.trim().isEmpty || _pollOptions.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Poll question and options are required")),
//       );
//       return;
//     }
//
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.groupId)
//         .collection('messages')
//         .add({
//       'type': 'poll',
//       'question': _pollQuestionController.text.trim(),
//       'options': _pollOptions.map((option) => {'text': option, 'votes': 0}).toList(),
//       'timestamp': Timestamp.now(),
//     });
//
//     _pollQuestionController.clear();
//     _pollOptions.clear();
//     Navigator.pop(context);
//   }
//
//   Future<void> _voteOnPoll(String messageId, int optionIndex) async {
//     DocumentReference pollRef = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.groupId)
//         .collection('messages')
//         .doc(messageId);
//
//     DocumentSnapshot pollSnapshot = await pollRef.get();
//     if (pollSnapshot.exists) {
//       List options = pollSnapshot['options'];
//       options[optionIndex]['votes']++;
//
//       await pollRef.update({'options': options});
//     }
//   }
//
//   void _showCreatePollDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Create Poll'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _pollQuestionController,
//               decoration: InputDecoration(labelText: 'Poll Question'),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _pollOptions.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(_pollOptions[index]),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     setState(() {
//                       _pollOptions.removeAt(index);
//                     });
//                   },
//                 ),
//               ),
//             ),
//             TextField(
//               controller: _pollOptionController,
//               decoration: InputDecoration(labelText: 'Add Poll Option'),
//               onSubmitted: (value) {
//                 if (value.trim().isNotEmpty) {
//                   setState(() {
//                     _pollOptions.add(value.trim());
//                   });
//                   _pollOptionController.clear();
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: _createPoll,
//             child: Text('Create Poll'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Group Chat'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.poll),
//             onPressed: _showCreatePollDialog,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(widget.groupId)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 final messages = snapshot.data!.docs;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     if (message['type'] == 'text') {
//                       bool isMe = message['senderId'] == _currentUserId;
//                       return Align(
//                         alignment:
//                         isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.all(8.0),
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.green : Colors.grey[800],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             message['text'],
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       );
//                     } else if (message['type'] == 'poll') {
//                       return Card(
//                         margin: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 "Poll: ${message['question']}",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                             ...List.generate(
//                               message['options'].length,
//                                   (optionIndex) => ListTile(
//                                 title: Text(message['options'][optionIndex]['text']),
//                                 trailing: Text(
//                                     "${message['options'][optionIndex]['votes']} votes"),
//                                 onTap: () => _voteOnPoll(message.id, optionIndex),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return SizedBox.shrink();
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  GroupChatScreen({required this.groupId});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController _pollQuestionController = TextEditingController();
  TextEditingController _pollOptionController = TextEditingController();
  List<String> _pollOptions = [];

  // This function will be used to send messages
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'type': 'text',
      'text': _messageController.text.trim(),
      'senderId': _currentUserId,
      'timestamp': Timestamp.now(),
    });

    _messageController.clear();
  }

  // This function creates a poll using the flutter_poll library
  void _createPoll() {
    showDialog(
      context: context,
      builder: (context) => PollDialog(
        onPollCreated: (question, options) async {
          if (question.isEmpty || options.isEmpty) {
            return; // Poll data must be valid before saving
          }

          // Save the poll data to Firestore
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.groupId)
              .collection('messages')
              .add({
            'type': 'poll',
            'question': question,
            'options': options.map((option) => {'text': option, 'votes': 0}).toList(),
            'timestamp': Timestamp.now(),
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.poll),
            onPressed: _createPoll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    if (message['type'] == 'text') {
                      bool isMe = message['senderId'] == _currentUserId;
                      return Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    } else if (message['type'] == 'poll') {
                      return PollMessageWidget(message: message);
                    }
                    return SizedBox.shrink();
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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

// PollMessageWidget to display polls in the chat
class PollMessageWidget extends StatelessWidget {
  final DocumentSnapshot message;

  PollMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Poll: ${message['question']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ...List.generate(
            message['options'].length,
                (optionIndex) => ListTile(
              title: Text(message['options'][optionIndex]['text']),
              trailing: Text(
                  "${message['options'][optionIndex]['votes']} votes"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// Poll Dialog Widget to create a poll
class PollDialog extends StatefulWidget {
  final Function(String question, List<String> options) onPollCreated;

  PollDialog({required this.onPollCreated});

  @override
  _PollDialogState createState() => _PollDialogState();
}

class _PollDialogState extends State<PollDialog> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController = TextEditingController();
  List<String> _options = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Poll"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _questionController,
            decoration: InputDecoration(labelText: "Poll Question"),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _optionController,
            decoration: InputDecoration(labelText: "Poll Option"),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() {
                  _options.add(value.trim());
                });
                _optionController.clear();
              }
            },
          ),
          SizedBox(height: 10),
          Column(
            children: _options.map((option) => Text(option)).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.isNotEmpty && _options.isNotEmpty) {
              widget.onPollCreated(_questionController.text, _options);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please fill the question and options")),
              );
            }
          },
          child: Text("Create Poll"),
        ),
      ],
    );
  }
}
