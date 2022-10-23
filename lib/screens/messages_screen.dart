// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/messages/messages.dart';
import '../widgets/messages/new_messages.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({
    Key? key,
    required this.username,
    required this.receiverId,
    required this.currentUsername,
    required this.id,
    required this.receiverImage,
    required this.userImage,
  }) : super(key: key);
  final String username;
  final String receiverId;
  final String currentUsername;
  final String id;
  final String receiverImage;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.2),
        elevation: 1,
        iconTheme: const IconThemeData(color: textClr),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(receiverImage),
            ),
            const SizedBox(
              width: 10,
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                      color: textClr,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 23,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(receiverId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return Text(
                              snapshot.data?['isTyping'] == id
                                  ? 'typing...'
                                  : snapshot.data?['status'] == 'Online'
                                      ? 'Online'
                                      : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: snapshot.data?['isTyping'] == id
                                    ? Colors.green
                                    : snapshot.data?['status'] == 'Online'
                                        ? Colors.green
                                        : Colors.red.shade400,
                              ));
                        }),
                  ],
                ),

                // Text(
                //   snapshot.data?['isTyping'] == id ? 'typing...' : '',
                //   style: const TextStyle(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w500,
                //       color: Colors.black),
                // )
              ],
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    itemBuilder: (ctx) {
                      return [
                        PopupMenuItem(
                          child: Text('Delete conversation'),
                          onTap: () {
                            print('tapped');
                            Future.delayed(Duration(seconds: 0), () {
                              return showDialog(
                                context: ctx,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0))),
                                    title: const Text('Delete message?'),
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 50,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Do you really want to delete this conversation?',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 25),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              onTap: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 7),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'users/$id/chatUsers/')
                                                    .doc(receiverId)
                                                    .delete();
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 7),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                  color: Colors.red,
                                                ),
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            });
                          },
                        )
                      ];
                    }),
              ],
            ))
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: Messages(
                  id: id,
                  username: username,
                  currentUsername: currentUsername,
                  receiverId: receiverId,
                  receiverImage: receiverImage,
                  userImage: receiverImage),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users/$receiverId/chatUsers')
                  .doc(id)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center();
                }
                final lastMsgDocsExistence = snapshot.data?.exists;
                final seen = lastMsgDocsExistence == true
                    ? snapshot.data!['seen']
                    : false;
                final lastMsgSenderId = lastMsgDocsExistence == true
                    ? snapshot.data!['lastMsgSenderId']
                    : receiverId;

                return lastMsgSenderId == receiverId
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            seen ? 'seen' : '',
                            style: TextStyle(color: textClr.withOpacity(0.7)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      );
              }),
            ),
            NewMessages(
              receiverId: receiverId,
            ),
          ],
        ),
      ),
    );
  }
}
