// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({
    Key? key,
    required this.id,
    required this.username,
    required this.currentUsername,
    required this.receiverId,
    required this.receiverImage,
    required this.userImage,
  }) : super(key: key);
  final String id;
  final String username;
  final String currentUsername;
  final String receiverId;
  final String receiverImage;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users/$id/chatUsers/$receiverId/chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        }

        final docs = snapshot.data?.docs;
        int? length = docs?.length;

        return ListView.builder(
          reverse: true,
          itemCount: length,
          itemBuilder: (context, index) {
            // return StreamBuilder(
            //   stream: FirebaseFirestore.instance
            //       .collection('users')
            //       .doc(receiverId)
            //       .snapshots(),
            //   builder: (context, snapshot2) {
            //     if (snapshot2.connectionState == ConnectionState.waiting) {
            //       return const Center();
            //     }
            //     final receiverImag = snapshot2

            //   },
            // );

            if (docs?[index]['senderId'] == id &&
                docs?[index]['receiverId'] == receiverId) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: docs?[index]['text'].length > 15
                        ? MediaQuery.of(context).size.width * 0.65
                        : null,
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20 * 0.75, vertical: 10),
                    decoration: BoxDecoration(
                        color:  Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30)),
                    child:
                        // Text(currentUsername),
                        Text(
                      docs?[index]['text'],
                      style: const TextStyle(
                          color: textClr,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              );
            } else if (docs?[index]['senderId'] == receiverId &&
                docs?[index]['receiverId'] == id) {
                  final editedIndex= index==0 ? index : index-1 ;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (index==0||
                 ( docs?[editedIndex]['senderId'] == id &&
                docs?[editedIndex]['receiverId'] == receiverId)
                  )?
                  Padding(
                    padding: const EdgeInsets.only(left : 10,top: 10),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ):Padding(
                    padding: const EdgeInsets.only(left : 10,top: 10),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    )),
                  Container(
                    width: docs?[index]['text'].length > 15
                        ? MediaQuery.of(context).size.width * 0.65
                        : null,
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20 * 0.75, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30)),
                    child:
                        // Text(username),
                        Text(
                      docs?[index]['text'],
                      style: const TextStyle(
                          color: textClr,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
