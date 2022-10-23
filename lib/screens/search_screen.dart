import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';

import '../double_icons.dart';
import '../theme/theme.dart';
import 'messages_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestore = FirebaseFirestore.instance;
  final String myId = FirebaseAuth.instance.currentUser!.uid;
  String _entredMessage = "";
  final _controller = TextEditingController();

  void setSeen(String hisId) async {
    await _firestore
        .collection('users/$myId/chatUsers')
        .doc(hisId)
        .set({'seen': true}, SetOptions(merge: true));
  }

  currentUserNameFn() async {
    final currentUserData =
        await FirebaseFirestore.instance.collection('users').doc(myId).get();
    return currentUserData['username'];
  }

  currentImageFn() async {
    final currentUserData =
        await FirebaseFirestore.instance.collection('users').doc(myId).get();
    return currentUserData['image_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0.8,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: textClr),
        title: Material(
          type: MaterialType.transparency,
          child: Container(
            // margin: const EdgeInsets.only(
            //     right: 20, left: 16, top: 18, bottom: 5),
            // margin: const EdgeInsets.only(
            //                     right: 15, left: 16, top: 16, bottom: 5),
            // padding: const EdgeInsets.symmetric(
            //     horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
                // color: textClr.withOpacity(0.1),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xffd8d4e4),
                    const Color(0xffd8d4e4).withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),

            child: TextField(
              autofocus: true,
              controller: _controller,
              onChanged: ((val) {
                setState(() {
                  _entredMessage = val;
                });
              }),
              decoration: const InputDecoration(
                hintText: 'Search',
                icon: Icon(
                  Icons.search,
                  color: textClr,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin:
                  const EdgeInsets.only(right: 16, left: 20, top: 10, bottom: 5),
              child: const Text(
                'SUGGESTIONS',
                style: TextStyle(
                    color: darkGreyClr,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(
            //         right: 20, left: 16, top: 10, bottom: 5),
            //   child:
            // ),
            StreamBuilder(
                stream: _firestore
                    .collection('users')
                    .orderBy('username')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final usersDoc = snapshot.data?.docs;
                
                  return ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    // separatorBuilder: (context, index) =>
                    //     myId == usersDoc[index].id
                    //         ? const SizedBox()
                    //         : Container(
                    //             height: 1,
                    //             width: 2,
                    //             color: Colors.grey.withOpacity(0.5),
                    //           ),
                    itemCount: usersDoc!.length,
                    itemBuilder: (context, index) {
                      String user = usersDoc[index]['username'];
                              
                      bool fitchUser = false;
                      if (_entredMessage == '' || user.contains(_entredMessage)) {
                        fitchUser = true;
                      }
                              
                      return myId == usersDoc[index].id
                          ? const SizedBox()
                          : fitchUser
                              ? _buildChatItem(
                                  usersDoc[index]['username'],
                                  usersDoc[index].id,
                                  myId,
                                  usersDoc[index]['image_url'],
                                  usersDoc[index]['status'],
                                  '',
                                  true,
                                  '',
                                  false,
                                  context)
                              : const SizedBox();
                    },
                  );
                }),
          ],
        )
      ),
    );
  }

  Widget _buildChatItem(
      String username,
      String receiverId,
      String id,
      String imageUrl,
      String currentStatus,
      String lastMsg,
      bool seen,
      String time,
      bool lastMsgSenderMe,
      BuildContext ctx) {
    return GestureDetector(
      onTap: (() async {
        final currentUsername = await currentUserNameFn();
        final currentImage = await currentImageFn();

        setSeen(receiverId);
        // ignore: use_build_context_synchronously
        Navigator.push(
            ctx,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MessagesScreen(
                username: username,
                receiverId: receiverId,
                currentUsername: currentUsername,
                id: id,
                receiverImage: imageUrl,
                userImage: currentImage,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ));
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  if (currentStatus == 'Online')
                    const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.green,
                        )),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: seen ? textClr.withOpacity(0.7) : textClr),
                  ),
                  if (lastMsg != '')
                    Row(
                      children: [
                        if (lastMsgSenderMe)
                          const Icon(
                            Double.done_all,
                            size: 16,
                            color: Color.fromARGB(255, 49, 60, 180),
                          ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          //getLastMsg(receiverId),
                          '$lastMsg · $time',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: seen ? textClr.withOpacity(0.4) : textClr),
                        ),
                      ],
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
