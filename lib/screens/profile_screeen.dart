

import 'package:chat_app/theme/theme.dart';
import 'package:chat_app/widgets/auth/login_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String myId = FirebaseAuth.instance.currentUser!.uid;


     setStatus(String status) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(myId)
          .update({'status': status});
    }

    

    Route _createRoute() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditProfile(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }

    return SafeArea(
      child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(myId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final username = snapshot.data?['username'];
            final imageUrl = snapshot.data?['image_url'];
            final email = snapshot.data?['email'];
            return SafeArea(
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 60,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 15,
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(29)),
                                height: 280,
                                width: 300,
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 80,
                                    ),
                                    Text(
                                      username,
                                      style: const TextStyle(
                                          color: textClr,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                          color: textClr,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        await setStatus('Offline');
                                        FirebaseAuth.instance.signOut();
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 25),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        alignment: Alignment.center,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(29),
                                            color: Colors.blue),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const Icon(
                                              Icons.logout,
                                              color: whiteClr,
                                            ),
                                            Text(
                                              'Logout',
                                              style: textButton.copyWith(
                                                  color: whiteClr),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 15,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ], shape: BoxShape.circle),
                            child: Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 65,
                                    backgroundImage: NetworkImage(imageUrl),
                                  ),
                                ),
                                CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 21,
                                      backgroundColor: Colors.blue,
                                      child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context, _createRoute());
                                          }),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
