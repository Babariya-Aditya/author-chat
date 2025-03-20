//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../Authenticate/Methods.dart';
// import '../group_chats/group_chat_screen.dart';
// import 'ChatRoom.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   Map<String, dynamic>? userMap;
//   bool isLoading = false;
//   final TextEditingController _search = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     setStatus("Online");
//   }
//
//   void setStatus(String status) async {
//     await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
//       "status": status,
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // online
//       setStatus("Online");
//     } else {
//       // offline
//       setStatus("Offline");
//     }
//   }
//
//   String chatRoomId(String user1, String user2) {
//     if (user1[0].toLowerCase().codeUnits[0] >
//         user2.toLowerCase().codeUnits[0]) {
//       return "$user1$user2";
//     } else {
//       return "$user2$user1";
//     }
//   }
//
//   void onSearch() async {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     await _firestore
//         .collection('users')
//         .where("email", isEqualTo: _search.text)
//         .get()
//         .then((value) {
//       setState(() {
//         userMap = value.docs[0].data();
//         isLoading = false;
//       });
//       print(userMap);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Home Screen"),
//         actions: [
//           IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
//         ],
//       ),
//       body: isLoading
//           ? Center(
//         child: Container(
//           height: size.height / 20,
//           width: size.height / 20,
//           child: CircularProgressIndicator(),
//         ),
//       )
//           : Column(
//         children: [
//           SizedBox(
//             height: size.height / 20,
//           ),
//           Container(
//             height: size.height / 14,
//             width: size.width,
//             alignment: Alignment.center,
//             child: Container(
//               height: size.height / 14,
//               width: size.width / 1.15,
//               child: TextField(
//                 controller: _search,
//                 decoration: InputDecoration(
//                   hintText: "Search",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: size.height / 50,
//           ),
//           ElevatedButton(
//             onPressed: onSearch,
//             child: Text("Search"),
//           ),
//           SizedBox(
//             height: size.height / 30,
//           ),
//           userMap != null
//               ? ListTile(
//             onTap: () {
//               String roomId = chatRoomId(
//                   _auth.currentUser!.displayName!,
//                   userMap!['name']);
//
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ChatRoom(
//                     chatRoomId: roomId,
//                     userMap: userMap!,
//                   ),
//                 ),
//               );
//             },
//             leading: Icon(Icons.account_box, color: Colors.white),
//             title: Text(
//               userMap!['name'],
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             //subtitle: Text(userMap!['role']),
//             subtitle: Text('${userMap!['role'][0].toUpperCase()}${userMap!['role'].substring(1)} | ${userMap!['email']}'),
//             trailing: Icon(Icons.chat, color: Colors.white),
//           )
//               : Container(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.group),
//         onPressed: () => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => GroupChatHomeScreen(),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Authenticate/Methods.dart';
import '../group_chats/group_chat_screen.dart';
import 'ChatRoom.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> chatList = []; // Stores the list of users who have messaged the current user.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    fetchChatList(); // Fetch chat list on init.
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
    });
  }

  // Fetch the chat list for the current user
  void fetchChatList() async {
    final currentUser = _auth.currentUser!;
    final chatsSnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .get();

    setState(() {
      chatList = chatsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Update the chat list for both users
  // Future<void> updateChatList(Map<String, dynamic> otherUser) async {
  //   final currentUser = _auth.currentUser!;
  //   final otherUserId = otherUser['uid'];
  //
  //   // Fetch role for the current user if it exists
  //   final currentUserDoc = await _firestore.collection('users').doc(currentUser.uid).get();
  //   final currentUserRole = currentUserDoc.data()?['role'] ?? 'User';
  //
  //   // Add other user to current user's chat list
  //   // await _firestore
  //   //     .collection('users')
  //   //     .doc(currentUser.uid)
  //   //     .collection('chats')
  //   //     .doc(otherUserId)
  //   //     .set(otherUser);
  //   await _firestore
  //       .collection('users')
  //       .doc(currentUser.uid)
  //       .collection('chats')
  //       .doc(otherUserId)
  //       .set({
  //     'uid': otherUser['uid'],
  //     'name': otherUser['name'],
  //     'email': otherUser['email'],
  //     'role': otherUser['role'] ?? 'User', // Default role if not set
  //   });
  //
  //   // Add current user to other user's chat list
  //   final currentUserData = {
  //     'uid': currentUser.uid,
  //     'name': currentUser.displayName,
  //     'email': currentUser.email,
  //     'role':  currentUserRole,
  //
  //   };
  //   await _firestore
  //       .collection('users')
  //       .doc(otherUserId)
  //       .collection('chats')
  //       .doc(currentUser.uid)
  //       .set({
  //     'uid': currentUser.uid,
  //     'name': currentUser.displayName,
  //     'email': currentUser.email,
  //     'role': currentUserRole, // Include role for current user
  //   });
  // }
  //   await _firestore
  //       .collection('users')
  //       .doc(otherUserId)
  //       .collection('chats')
  //       .doc(currentUser.uid)
  //       .set(currentUserData);
  // }
  Future<void> updateChatList(Map<String, dynamic> otherUser) async {
    final currentUser = _auth.currentUser!;
    final otherUserId = otherUser['uid'];

    final currentUserDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final currentUserRole = currentUserDoc.data()?['role'] ?? 'User';

    await _firestore.collection('users').doc(currentUser.uid).collection('chats').doc(otherUserId).set({
      'uid': otherUser['uid'],
      'name': otherUser['name'],
      'email': otherUser['email'],
      'role': otherUser['role'] ?? 'User',
      'unread': false, // Mark as read for sender
    });

    await _firestore.collection('users').doc(otherUserId).collection('chats').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'name': currentUser.displayName,
      'email': currentUser.email,
      'role': currentUserRole,
      'unread': true, // Mark as unread for receiver
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logOut(context))
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          SizedBox(height: size.height / 20),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height / 50),
          ElevatedButton(
            onPressed: onSearch,
            child: Text("Search"),
          ),
          SizedBox(height: size.height / 30),
          userMap != null
              ? ListTile(
            onTap: () async {
              String roomId = chatRoomId(
                  _auth.currentUser!.displayName!,
                  userMap!['name']);

              await updateChatList(userMap!);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoom(
                    chatRoomId: roomId,
                    userMap: userMap!,
                  ),
                ),
              );
            },
            leading: Icon(Icons.account_box, color: Colors.white),
            title: Text(
              userMap!['name'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text("${userMap!['role']} | ${userMap!['email']}"),

            //subtitle: Text(userMap!['email']),
            trailing: Icon(Icons.chat, color: Colors.white),
          )
              : Container(),
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatList.length,
//               itemBuilder: (context, index) {
//                 final chatUser = chatList[index];
//                 return ListTile(
//                   onTap: () {
//                     String roomId = chatRoomId(
//                         _auth.currentUser!.displayName!,
//                         chatUser['name']);
//
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => ChatRoom(
//                           chatRoomId: roomId,
//                           userMap: chatUser,
//                         ),
//                       ),
//                     );
//                   },
//                   leading: Icon(Icons.account_circle),
//                   title: Text(chatUser['name']),
//                   subtitle: Text("${chatUser['role']} | ${chatUser['email']}"),
// //             subtitle: Text('${userMap!['role'][0].toUpperCase()}${userMap!['role'].substring(1)} | ${userMap!['email']}'),
//
//
//                 );
//               },
//             ),
//           ),
          Expanded(
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final chatUser = chatList[index];
                return ListTile(
                  onTap: () async {
                    String roomId = chatRoomId(
                        _auth.currentUser!.displayName!,
                        chatUser['name']);

                    // Mark messages as read when opening chat
                    await _firestore.collection('users')
                        .doc(_auth.currentUser!.uid)
                        .collection('chats')
                        .doc(chatUser['uid'])
                        .update({'unread': false});

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoom(
                          chatRoomId: roomId,
                          userMap: chatUser,
                        ),
                      ),
                    );
                  },
                  leading: Stack(
                    children: [
                      Icon(Icons.account_circle, size: 40),
                      if (chatUser['unread'] == true)  // Show red dot for unread messages
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.greenAccent,
                          ),
                        ),
                    ],
                  ),
                  title: Text(chatUser['name']),
                  subtitle: Text("${chatUser['role']} | ${chatUser['email']}"),
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}