import 'package:author/author/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupInfo(
                    groupName: groupName,
                    groupId: groupChatId,
                  ),
                ),
              ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                        snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                        return messageTile(size, chatMap);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => CreatePollDialog(
                                    groupChatId: groupChatId,
                                    firestore: _firestore,
                                    auth: _auth,
                                  ),
                                );
                              },
                              icon: Icon(Icons.poll),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    Text(
                      chatMap['sendBy'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: size.height / 200,
                    ),
                    Text(
                      chatMap['message'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ))
        );
      } else if (chatMap['type'] == "poll") {
        return Card(
          color: Colors.blue,
          elevation: 3.0,
          child: Container(
            //width: size.width *0.8, // Adjust width to reduce the displayed poll size

            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${chatMap['sendBy']} created a poll:", // Display the user who created the poll
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.black),
                ),
                SizedBox(height: 5),
                Text(
                  chatMap['question'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // ...chatMap['options'].map<Widget>((option) {
                //   return ListTile(
                //     title: Text(option['option']),
                //     trailing: Text("Votes: ${option['votes']}"),
                //     onTap: () async {
                //       int index = chatMap['options'].indexOf(option);
                //       chatMap['options'][index]['votes'] += 1;
                ...chatMap['options'].asMap().entries.map<Widget>((entry) {
                  int index = entry.key;
                  Map<String, dynamic> option = entry.value;

                  return ListTile(
                    title: Text(option['option']),
                    trailing: Text("Votes: ${option['votes']}"),
                    onTap: () async {
                      String userId = _auth.currentUser!.uid;

                      // Check if the user has already voted
                      Map<String, dynamic> votes = chatMap['votes'] ?? {};
                      if (votes.containsKey(userId)) {
                        int previousIndex = votes[userId];
                        if (previousIndex != index) {
                          // Decrease vote count of the previous option
                          chatMap['options'][previousIndex]['votes'] -= 1;
                        }
                      }

                      // Increase vote count of the selected option
                      chatMap['options'][index]['votes'] += 1;

                      // Update the user's vote in the votes map
                      votes[userId] = index;


                      await _firestore
                          .collection('groups')
                          .doc(groupChatId)
                          .collection('chats')
                          .doc(chatMap['id']) // Use the correct document ID here
                          .update({"options": chatMap['options'],
                        "votes": votes,});
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
      else {
        return SizedBox();
      }
    });
  }
}

class CreatePollDialog extends StatefulWidget {
  final String groupChatId;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const CreatePollDialog({
    required this.groupChatId,
    required this.firestore,
    required this.auth,
    Key? key,
  }) : super(key: key);

  @override
  _CreatePollDialogState createState() => _CreatePollDialogState();
}

class _CreatePollDialogState extends State<CreatePollDialog> {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void addOptionField() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }


  void createPoll() async {
    if (questionController.text.isNotEmpty &&
        optionControllers.every((controller) => controller.text.isNotEmpty)) {
      List<Map<String, dynamic>> options = optionControllers.map((controller) {
        return {"option": controller.text, "votes": 0};
      }).toList();

      DocumentReference pollDoc = widget.firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc();

      Map<String, dynamic> pollData = {
        "id": pollDoc.id, // Store the document ID in the poll data
        "sendBy": widget.auth.currentUser!.displayName,
        "type": "poll",
        "question": questionController.text,
        "options": options,
        "time": FieldValue.serverTimestamp(),
      };

      await pollDoc.set(pollData); // Use set() instead of add() to include the ID

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Poll"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(hintText: "Enter poll question"),
            ),
            SizedBox(height: 10),
            ...optionControllers.map((controller) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter option"),
                ),
              );
            }).toList(),
            TextButton(
              onPressed: addOptionField,
              child: Text("Add Option"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: createPoll,
          child: Text("Create"),
        ),
      ],
    );
  }
}
