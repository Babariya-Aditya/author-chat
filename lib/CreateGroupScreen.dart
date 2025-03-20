import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<String> selectedUserIds;

  CreateGroupScreen({required this.selectedUserIds});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a group name.')),
      );
      return;
    }

    try {
      // Add the group to Firestore under 'groups' collection
      final groupRef = FirebaseFirestore.instance.collection('groups').doc();

      await groupRef.set({
        'name': _groupNameController.text,
        'members': widget.selectedUserIds,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate back to the chat screen
      Navigator.pop(context);
    } catch (e) {
      print("Error creating group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Group name input field
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF3D9571),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            // Display the selected users
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedUserIds.length,
                itemBuilder: (ctx, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.selectedUserIds[index])
                        .get(),
                    builder: (ctx, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (userSnapshot.hasError || !userSnapshot.hasData) {
                        return ListTile(
                          title: Text('User not found', style: TextStyle(color: Colors.white)),
                        );
                      }

                      final user = userSnapshot.data!;
                      return ListTile(
                        title: Text(
                          user['name'] ?? 'User',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Create group button
            ElevatedButton(
              onPressed: _createGroup,
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF3D9571),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: Text(
                'Create Group',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
