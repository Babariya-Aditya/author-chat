//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class IndividualChatScreen extends StatefulWidget {
//   final String receiverId;
//   final String receiverName;
//
//   IndividualChatScreen({required this.receiverId, required this.receiverName});
//
//   @override
//   _IndividualChatScreenState createState() => _IndividualChatScreenState();
// }
//
// class _IndividualChatScreenState extends State<IndividualChatScreen> {
//   final _messageController = TextEditingController();
//   String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;
//
//     String chatId = _currentUserId.compareTo(widget.receiverId) < 0
//         ? '$_currentUserId-${widget.receiverId}'
//         : '${widget.receiverId}-$_currentUserId';
//
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'text': _messageController.text.trim(),
//       'senderId': _currentUserId,
//       'timestamp': Timestamp.now(),
//     });
//
//     _messageController.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String chatId = _currentUserId.compareTo(widget.receiverId) < 0
//         ? '$_currentUserId-${widget.receiverId}'
//         : '${widget.receiverId}-$_currentUserId';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.receiverName),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(chatId)
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
//                     bool isMe = message['senderId'] == _currentUserId;
//                     return Align(
//                       alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(8.0),
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 4.0, horizontal: 8.0),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.green : Colors.grey[800],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           message['text'],
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     );
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

class IndividualChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  IndividualChatScreen({required this.receiverId, required this.receiverName});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Generate a unique chat ID based on the current user and receiver
  String get _chatId => _currentUserId.compareTo(widget.receiverId) < 0
      ? '$_currentUserId-${widget.receiverId}'
      : '${widget.receiverId}-$_currentUserId';

  // Send a message and store it in Firestore
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'text': _messageController.text.trim(),
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': Timestamp.now(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false) // Oldest at the top
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isMe = message['senderId'] == _currentUserId;
                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input Field
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
