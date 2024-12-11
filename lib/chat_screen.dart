// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'message_screen.dart';
//
// class ChatScreen extends StatelessWidget {
//   void _logout() async {
//     await FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat App'),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: _logout),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
//           if (!userSnapshot.hasData) return CircularProgressIndicator();
//           final users = userSnapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (ctx, index) {
//               final user = users[index];
//               return ListTile(
//                 title: Text(user['name']),
//                 subtitle: Text(user['email']),
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => MessageScreen(
//                         otherUserId: user.id,
//                         otherUserName: user['name'],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart';

class ChatScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Redirect to the login screen after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Chat App',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          ),
        ],
        elevation: 5,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No users available.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final users = userSnapshot.data!.docs;
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              final user = users[index];
              if (user.id == currentUserId) return SizedBox(); // Hide self from the list

              return Card(
                color: Color(0xFF1E1E1E),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.greenAccent,
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    user['email'],
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  trailing: Icon(
                    Icons.chat,
                    color: Colors.greenAccent,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MessageScreen(
                          otherUserId: user.id,
                          otherUserName: user['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
