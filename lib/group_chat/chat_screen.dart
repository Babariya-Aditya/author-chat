// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'group_creation_screen.dart';
// import 'individual_chat_screen.dart';
// import 'group_chat_screen.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final _searchController = TextEditingController();
//   List<DocumentSnapshot> _users = [];
//   List<DocumentSnapshot> _filteredUsers = [];
//   List<DocumentSnapshot> _groups = [];
//   String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUsersAndGroups();
//   }
//
//   Future<void> _fetchUsersAndGroups() async {
//     QuerySnapshot userSnapshot =
//     await FirebaseFirestore.instance.collection('users').get();
//     QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
//         .collection('chats')
//         .where('isGroup', isEqualTo: true)
//         .where('members', arrayContains: _currentUserId)
//         .get();
//
//     setState(() {
//       _users = userSnapshot.docs
//           .where((user) => user['uid'] != _currentUserId)
//           .toList();
//       _filteredUsers = _users;
//       _groups = groupSnapshot.docs;
//     });
//   }
//
//   void _searchUsers(String query) {
//     setState(() {
//       _filteredUsers = _users
//           .where((user) =>
//           user['name'].toString().toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chats'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.group_add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => GroupCreationScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search Users',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: _searchUsers,
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 ..._groups.map((group) => ListTile(
//                   title: Text(group['name']),
//                   leading: Icon(Icons.group),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             GroupChatScreen(groupId: group.id),
//                       ),
//                     );
//                   },
//                 )),
//                 ..._filteredUsers.map((user) => ListTile(
//                   title: Text(user['name']),
//                   leading: Icon(Icons.person),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => IndividualChatScreen(
//                           receiverId: user['uid'],
//                           receiverName: user['name'],
//                         ),
//                       ),
//                     );
//                   },
//                 )),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'group_creation_screen.dart';
// import 'individual_chat_screen.dart';
// import 'group_chat_screen.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final _searchController = TextEditingController();
//   List<DocumentSnapshot> _users = [];
//   List<DocumentSnapshot> _filteredUsers = [];
//   List<DocumentSnapshot> _groups = [];
//   String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUsersAndGroups();
//   }
//
//   Future<void> _fetchUsersAndGroups() async {
//     try {
//       // Fetch users using email instead of uid
//       QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
//
//       // Ensure you're accessing the correct field name for email
//       QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
//           .collection('chats')
//           .where('isGroup', isEqualTo: true)
//           .where('members', arrayContains: _currentUserId)
//           .get();
//
//       setState(() {
//         _users = userSnapshot.docs
//             .where((user) => user['email'] != FirebaseAuth.instance.currentUser!.email)
//             .toList();
//         _filteredUsers = _users;
//         _groups = groupSnapshot.docs;
//       });
//     } catch (e) {
//       print("Error fetching users and groups: $e");
//     }
//   }
//
//   void _searchUsers(String query) {
//     setState(() {
//       _filteredUsers = _users
//           .where((user) =>
//           user['name'].toString().toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chats'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.group_add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => GroupCreationScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search Users',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: _searchUsers,
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 // Display Groups
//                 if (_groups.isNotEmpty) ...[
//                   Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text('Groups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   ..._groups.map((group) => ListTile(
//                     title: Text(group['name']),
//                     leading: Icon(Icons.group),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GroupChatScreen(groupId: group.id),
//                         ),
//                       );
//                     },
//                   )),
//                 ],
//
//                 // Display Users
//                 if (_filteredUsers.isNotEmpty) ...[
//                   Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   ..._filteredUsers.map((user) {
//                     final userEmail = user['email']; // Accessing the user's email
//                     return ListTile(
//                       title: Text(user['name']),
//                       leading: Icon(Icons.person),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => IndividualChatScreen(
//                               receiverId: userEmail,  // Send email ID as receiverId
//                               receiverName: user['name'],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }).toList(),
//                 ],
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
import 'group_creation_screen.dart';
import 'individual_chat_screen.dart';
import 'group_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  List<DocumentSnapshot> _users = [];
  List<DocumentSnapshot> _filteredUsers = [];
  List<DocumentSnapshot> _groups = [];
  String _currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _fetchUsersAndGroups();
  }

  Future<void> _fetchUsersAndGroups() async {
    // Fetching users
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    // Fetching groups where the user is a member or the creator
    QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: _currentUserEmail) // Filtering groups where the user is a member
        .get();

    // Fetching groups where the user is the creator
    QuerySnapshot createdGroupSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('createdBy', isEqualTo: _currentUserEmail) // Filtering groups where the user is the creator
        .get();

    setState(() {
      _users = userSnapshot.docs
          .where((user) => user['email'] != _currentUserEmail)
          .toList();
      _filteredUsers = _users;
      // Combine both groups (member and creator groups)
      _groups = [...groupSnapshot.docs, ...createdGroupSnapshot.docs];
    });
  }

  void _searchUsers(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
          user['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupCreationScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // Display groups
                ..._groups.map((group) => ListTile(
                  title: Text(group['name']),
                  leading: Icon(Icons.group),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupChatScreen(groupId: group.id),
                      ),
                    );
                  },
                )),
                // Display filtered users
                ..._filteredUsers.map((user) => ListTile(
                  title: Text(user['name']),
                  leading: Icon(Icons.person),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IndividualChatScreen(
                          receiverId: user['email'], // Pass email instead of uid
                          receiverName: user['name'],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
