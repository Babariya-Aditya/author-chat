// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class GroupCreationScreen extends StatefulWidget {
//   @override
//   _GroupCreationScreenState createState() => _GroupCreationScreenState();
// }
//
// class _GroupCreationScreenState extends State<GroupCreationScreen> {
//   final TextEditingController _groupNameController = TextEditingController();
//   List<DocumentSnapshot> _users = [];
//   List<String> _selectedUsers = [];
//   String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
//   }
//
//   Future<void> _fetchUsers() async {
//     QuerySnapshot snapshot =
//     await FirebaseFirestore.instance.collection('users').get();
//     setState(() {
//       _users = snapshot.docs
//           .where((user) => user['uid'] != _currentUserId)
//           .toList();
//     });
//   }
//
//   Future<void> _createGroup() async {
//     if (_groupNameController.text.trim().isEmpty || _selectedUsers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Group name and members are required")),
//       );
//       return;
//     }
//
//     List<String> members = [..._selectedUsers, _currentUserId];
//
//     DocumentReference groupRef =
//     FirebaseFirestore.instance.collection('chats').doc();
//
//     await groupRef.set({
//       'name': _groupNameController.text.trim(),
//       'isGroup': true,
//       'members': members,
//       'createdBy': _currentUserId,
//       'createdAt': Timestamp.now(),
//     });
//
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Group'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _groupNameController,
//               decoration: InputDecoration(
//                 labelText: 'Group Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _users.length,
//                 itemBuilder: (context, index) {
//                   final user = _users[index];
//                   final userId = user['uid'];
//                   return CheckboxListTile(
//                     title: Text(user['name']),
//                     value: _selectedUsers.contains(userId),
//                     onChanged: (bool? selected) {
//                       setState(() {
//                         if (selected == true) {
//                           _selectedUsers.add(userId);
//                         } else {
//                           _selectedUsers.remove(userId);
//                         }
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _createGroup,
//               child: Text('Create Group'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupCreationScreen extends StatefulWidget {
  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<DocumentSnapshot> _users = [];
  List<String> _selectedUsers = [];
  String _currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs
          .where((user) => user['email'] != _currentUserEmail)
          .toList();
    });
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty || _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Group name and members are required")),
      );
      return;
    }

    // Add the current user's email to the group members list
    List<String> members = [..._selectedUsers, _currentUserEmail];

    DocumentReference groupRef = FirebaseFirestore.instance.collection('chats').doc();

    await groupRef.set({
      'name': _groupNameController.text.trim(),
      'isGroup': true,
      'members': members,
      'createdBy': _currentUserEmail, // Store the current user's email
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final userEmail = user['email'];
                  return CheckboxListTile(
                    title: Text(user['name']),
                    value: _selectedUsers.contains(userEmail),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedUsers.add(userEmail);
                        } else {
                          _selectedUsers.remove(userEmail);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
