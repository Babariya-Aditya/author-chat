// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'message_screen.dart';
//
// class ChatScreen extends StatelessWidget {
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pop(); // Redirect to the login screen after logout
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF121212), // Dark background
//       appBar: AppBar(
//         backgroundColor: Color(0xFF1E1E1E),
//         title: Text(
//           'Chat App',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.redAccent),
//             onPressed: () => _logout(context),
//           ),
//         ],
//         elevation: 5,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
//           if (userSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(color: Colors.greenAccent),
//             );
//           }
//
//           if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Text(
//                 'No users available.',
//                 style: TextStyle(color: Colors.white70, fontSize: 18),
//               ),
//             );
//           }
//
//           final users = userSnapshot.data!.docs;
//           final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//
//           return ListView.builder(
//             padding: EdgeInsets.all(10),
//             itemCount: users.length,
//             itemBuilder: (ctx, index) {
//               final user = users[index];
//               if (user.id == currentUserId) return SizedBox(); // Hide self from the list
//
//               return Card(
//                 color: Color(0xFF1E1E1E),
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 5,
//                 child: ListTile(
//                   contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                   leading: CircleAvatar(
//                     radius: 25,
//                     backgroundColor: Colors.greenAccent,
//                     child: Text(
//                       user['name'][0].toUpperCase(),
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     user['name'],
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   subtitle: Text(
//                     user['email'],
//                     style: TextStyle(color: Colors.grey, fontSize: 15),
//                   ),
//                   trailing: Icon(
//                     Icons.chat,
//                     color: Colors.greenAccent,
//                   ),
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => MessageScreen(
//                           otherUserId: user.id,
//                           otherUserName: user['name'],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'message_screen.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   String _searchQuery = ''; // Variable to store the search query
//
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pop(); // Redirect to the login screen after logout
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212), // Dark background
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Text(
//           'Chat App',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.redAccent),
//             onPressed: () => _logout(context),
//           ),
//         ],
//         elevation: 5,
//       ),
//       body: Column(
//         children: [
//           // Search Field
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: const Color(0xFF1E1E1E),
//                 hintText: 'Search users...',
//                 hintStyle: const TextStyle(color: Colors.white70),
//                 prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               style: const TextStyle(color: Colors.white),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value.toLowerCase();
//                 });
//               },
//             ),
//           ),
//           // User List
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance.collection('users').snapshots(),
//               builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
//                 if (userSnapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.greenAccent),
//                   );
//                 }
//
//                 if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users available.',
//                       style: TextStyle(color: Colors.white70, fontSize: 18),
//                     ),
//                   );
//                 }
//
//                 final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//                 final users = userSnapshot.data!.docs.where((user) {
//                   final name = user['name'].toLowerCase();
//                   final email = user['email'].toLowerCase();
//                   return (name.contains(_searchQuery) ||
//                       email.contains(_searchQuery)) &&
//                       user.id != currentUserId; // Exclude current user
//                 }).toList();
//
//                 if (users.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users found.',
//                       style: TextStyle(color: Colors.white70, fontSize: 18),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(10),
//                   itemCount: users.length,
//                   itemBuilder: (ctx, index) {
//                     final user = users[index];
//
//                     return Card(
//                       color: const Color(0xFF1E1E1E),
//                       margin: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       elevation: 5,
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 15),
//                         leading: CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.greenAccent,
//                           child: Text(
//                             user['name'][0].toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           user['name'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         subtitle: Text(
//                           user['email'],
//                           style:
//                           const TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         trailing: const Icon(
//                           Icons.chat,
//                           color: Colors.greenAccent,
//                         ),
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => MessageScreen(
//                                 otherUserId: user.id,
//                                 otherUserName: user['name'],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'message_screen.dart';
// import 'group_message_screen.dart'; // Import the group message screen
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   String _searchQuery = ''; // Variable to store the search query
//   List<String> _selectedUsers = []; // To store the selected user IDs
//
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pop(); // Redirect to the login screen after logout
//   }
//
//   void _createGroup() async {
//     if (_selectedUsers.isNotEmpty) {
//       // Add the current user to the group
//       _selectedUsers.add(FirebaseAuth.instance.currentUser!.uid);
//
//       // Create a new group document in Firestore
//       await FirebaseFirestore.instance.collection('groups').add({
//         'members': _selectedUsers,
//         'admin': FirebaseAuth.instance.currentUser!.uid,
//         'created_at': Timestamp.now(),
//       });
//
//       // Clear the selected users list
//       setState(() {
//         _selectedUsers.clear();
//       });
//
//       // Show a message and redirect to the group chat screen
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Group created successfully!')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212), // Dark background
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Text(
//           'Chat App',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.redAccent),
//             onPressed: () => _logout(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.group_add, color: Colors.greenAccent),
//             onPressed: _createGroup, // Button to create a group
//           ),
//         ],
//         elevation: 5,
//       ),
//       body: Column(
//         children: [
//           // Search Field
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: const Color(0xFF1E1E1E),
//                 hintText: 'Search users...',
//                 hintStyle: const TextStyle(color: Colors.white70),
//                 prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               style: const TextStyle(color: Colors.white),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value.toLowerCase();
//                 });
//               },
//             ),
//           ),
//           // User List
//           Expanded(
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance.collection('users').snapshots(),
//               builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
//                 if (userSnapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.greenAccent),
//                   );
//                 }
//
//                 if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users available.',
//                       style: TextStyle(color: Colors.white70, fontSize: 18),
//                     ),
//                   );
//                 }
//
//                 final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//                 final users = userSnapshot.data!.docs.where((user) {
//                   final name = user['name'].toLowerCase();
//                   final email = user['email'].toLowerCase();
//                   return (name.contains(_searchQuery) ||
//                       email.contains(_searchQuery)) &&
//                       user.id != currentUserId; // Exclude current user
//                 }).toList();
//
//                 if (users.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No users found.',
//                       style: TextStyle(color: Colors.white70, fontSize: 18),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(10),
//                   itemCount: users.length,
//                   itemBuilder: (ctx, index) {
//                     final user = users[index];
//
//                     return Card(
//                       color: const Color(0xFF1E1E1E),
//                       margin: const EdgeInsets.symmetric(
//                           vertical: 8, horizontal: 5),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       elevation: 5,
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 15),
//                         leading: CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.greenAccent,
//                           child: Text(
//                             user['name'][0].toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           user['name'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         subtitle: Text(
//                           user['email'],
//                           style:
//                           const TextStyle(color: Colors.grey, fontSize: 15),
//                         ),
//                         trailing: const Icon(
//                           Icons.chat,
//                           color: Colors.greenAccent,
//                         ),
//                         onTap: () {
//                           if (_selectedUsers.contains(user.id)) {
//                             setState(() {
//                               _selectedUsers.remove(user.id); // Deselect user
//                             });
//                           } else {
//                             setState(() {
//                               _selectedUsers.add(user.id); // Select user
//                             });
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart';
import 'group_message_screen.dart'; // Import the group message screen

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _searchQuery = ''; // Variable to store the search query
  List<String> _selectedUsers = []; // To store the selected user IDs

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Redirect to the login screen after logout
  }

  void _createGroup() async {
    if (_selectedUsers.isNotEmpty) {
      // Add the current user to the group
      _selectedUsers.add(FirebaseAuth.instance.currentUser!.uid);

      // Create a new group document in Firestore and get the document reference
      DocumentReference groupRef = await FirebaseFirestore.instance.collection('groups').add({
        'members': _selectedUsers,
        'admin': FirebaseAuth.instance.currentUser!.uid,
        'created_at': Timestamp.now(),
      });

      // Clear the selected users list
      setState(() {
        _selectedUsers.clear();
      });

      // Show a message and redirect to the group chat screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group created successfully!')),
      );

      // Navigate to the group message screen with the actual group ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupMessageScreen(
            groupId: groupRef.id, // Use the actual group ID here
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Chat App',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.greenAccent),
            onPressed: _createGroup, // Button to create a group
          ),
        ],
        elevation: 5,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                hintText: 'Search users...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // User List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  );
                }

                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users available.',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                final users = userSnapshot.data!.docs.where((user) {
                  final name = user['name'].toLowerCase();
                  final email = user['email'].toLowerCase();
                  return (name.contains(_searchQuery) ||
                      email.contains(_searchQuery)) &&
                      user.id != currentUserId; // Exclude current user
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: users.length,
                  itemBuilder: (ctx, index) {
                    final user = users[index];

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.greenAccent,
                          child: Text(
                            user['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          user['email'],
                          style:
                          const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        trailing: const Icon(
                          Icons.chat,
                          color: Colors.greenAccent,
                        ),
                        onTap: () {
                          if (_selectedUsers.contains(user.id)) {
                            setState(() {
                              _selectedUsers.remove(user.id); // Deselect user
                            });
                          } else {
                            setState(() {
                              _selectedUsers.add(user.id); // Select user
                            });
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
