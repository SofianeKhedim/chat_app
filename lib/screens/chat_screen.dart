import 'package:chat_app/screens/messages_screen.dart';
import 'package:chat_app/screens/profile_screeen.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

import '../double_icons.dart';
import '../theme/theme.dart';
import '../widgets/messages/messages.dart';
import '../widgets/messages/new_messages.dart';
import '../widgets/package_edited/action_edited.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  String currentUsername = '';
  final String myId = FirebaseAuth.instance.currentUser!.uid;
  final String email = FirebaseAuth.instance.currentUser!.email!;
  final _firestore = FirebaseFirestore.instance;
  bool selectedCategoryChats = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(myId).update({'status': status});
  }

  void setTypingNull() async {
    await _firestore.collection('users').doc(myId).update({'isTyping': null});
  }

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus('Online');
    } else {
      //offline
      setStatus('Offline');
      setTypingNull();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    Route _createSearchScreenRoute() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
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

    Route _createRoute() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     DropdownButton(
      //       icon: const Icon(
      //         Icons.more_vert,
      //         color: Colors.white,
      //       ),
      //       items: [
      //         DropdownMenuItem(
      //           value: 'logout',
      //           child: Row(
      //             children: const [
      //               Icon(
      //                 Icons.exit_to_app,
      //                 color: Colors.black,
      //               ),
      //               SizedBox(width: 10),
      //               Text('Logout'),
      //             ],
      //           ),
      //         ),
      //       ],
      //       onChanged: (itemIdentifier) {
      //         if (itemIdentifier == 'logout') {
      //           FirebaseAuth.instance.signOut();
      //           setStatus('Offline');
      //           FocusScope.of(context).unfocus();
      //         }
      //       },
      //     ),
      //     const SizedBox(width: 7),
      //   ],
      // ),

      // Flexible(
      //   child:
      // StreamBuilder(
      //       stream: _firestore.collection('users').snapshots(),
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const Center(child: CircularProgressIndicator());
      //         }
      //         final usersDoc = snapshot.data?.docs;

      //         return ListView.separated(
      //           shrinkWrap: true,
      //           scrollDirection: Axis.horizontal,
      //           separatorBuilder: (context, index) =>
      //               myId == usersDoc[index].id
      //                   ? const SizedBox()
      //                   : Container(
      //                       height: 1,
      //                       width: 2,
      //                       color: Colors.grey.withOpacity(0.5),
      //                     ),
      //           itemCount: usersDoc!.length,
      //           itemBuilder: (context, index) {
      //             return  myId == usersDoc[index].id? const SizedBox(): InkWell(
      //               onTap: (() async{
      //                 final currentUsername = await currentUserNameFn();

      //                 // ignore: use_build_context_synchronously
      //                 Navigator.push(
      //                     context,
      //                     PageTransition(
      //                       type: PageTransitionType.rightToLeft,
      //                       child: MessagesScreen(
      //                         username: usersDoc[index]['username'],
      //                         receiverId: usersDoc[index].id,
      //                         currentUsername: currentUsername,
      //                         id: myId,
      //                       ),
      //                       duration: const Duration(milliseconds: 500),
      //                     ));
      //               }),
      //               child: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: Column(
      //                   children: [
      //                     CircleAvatar(
      //                       radius: 25,
      //                       backgroundImage:
      //                           NetworkImage(usersDoc[index]['image_url']),
      //                     ),
      //                     const SizedBox(
      //                       height: 2,
      //                     ),
      //                     Text(
      //                       usersDoc[index]['username'],
      //                       style: const TextStyle(
      //                           fontWeight: FontWeight.w300, fontSize: 10),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             );
      //           },
      //         );
      //       }),
      // ),

      body: _selectedIndex == 2
          ? const ProfileScreen()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            margin: const EdgeInsets.only(
                                right: 15, left: 16, top: 16, bottom: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, _createSearchScreenRoute());
                              },
                              child: Row(
                                children: const [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.search,
                                    color: textClr,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Search'),
                                ],
                              ),
                            ),
                            // TextField(
                            //   onTap: () {
                            //     Navigator.push(
                            //         context,
                            //         PageRouteBuilder(
                            //             transitionDuration: const Duration(microseconds: 500),
                            //             pageBuilder: (_, __, ___) =>
                            //                 const SearchScreen()));
                            //   },
                            //   decoration: InputDecoration(
                            //     hintText: 'Search',
                            //     icon: Icon(
                            //       Icons.search,
                            //       color: textClr,
                            //     ),
                            //     border: InputBorder.none,
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       isDarkMode = !isDarkMode;
                      //     });
                      //   },
                      //   child: Container(
                      //       margin: const EdgeInsets.only(
                      //           right: 20, top: 18, bottom: 5),
                      //       child: isDarkMode
                      //           ? const Icon(Icons.wb_sunny_outlined)
                      //           : const Icon(Icons.nightlight_round_outlined)),
                      // ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 16, top: 18, bottom: 5),
                          child: StreamBuilder(
                              stream: _firestore
                                  .collection('users')
                                  .doc(myId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final image_url = snapshot.data?['image_url'];
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingImage();
                                }
                                return CircleAvatar(
                                  radius: 25,
                                  backgroundImage: Image.network(image_url,
                                      loadingBuilder:
                                          (context, child, loadingProgress) =>
                                              loadingImage(),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              loadingImage()).image,
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        right: 16, left: 16, top: 10, bottom: 5),
                    child: Text(
                      'Recent Chat',
                      style: TextStyle(
                          color: textClr,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(29),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xffd8d4e4),
                              const Color(0xffd8d4e4).withOpacity(0.4),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: (() {
                                setState(() {
                                  selectedCategoryChats = true;
                                });
                              }),
                              child: AnimatedContainer(
                                curve: Curves.easeIn,
                                duration: const Duration(milliseconds: 400),
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, top: 5, bottom: 5),
                                margin: const EdgeInsets.only(
                                    right: 5, left: 5, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: selectedCategoryChats
                                      ? Colors.white
                                      : null,
                                ),
                                child: const Text(
                                  'Chats',
                                  style: TextStyle(
                                      color: textClr,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: (() {
                                setState(() {
                                  selectedCategoryChats = false;
                                });
                              }),
                              child: AnimatedContainer(
                                curve: Curves.easeIn,
                                duration: const Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: !selectedCategoryChats
                                      ? Colors.white
                                      : null,
                                ),
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, top: 5, bottom: 5),
                                margin: const EdgeInsets.only(
                                    right: 5, left: 5, top: 2, bottom: 2),
                                child: const Text(
                                  'Online',
                                  style: TextStyle(
                                      color: textClr,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // !selectedCategoryChats
                  //     ? Flexible(
                  //         child: StreamBuilder(
                  //             stream:
                  //                 _firestore.collection('users').snapshots(),
                  //             builder: (context, snapshot) {
                  //               if (snapshot.connectionState ==
                  //                   ConnectionState.waiting) {
                  //                 return const Center(
                  //                     child: CircularProgressIndicator());
                  //               }
                  //               final usersDoc = snapshot.data?.docs;

                  //               return ListView.builder(
                  //                 shrinkWrap: true,
                  //                 scrollDirection: Axis.vertical,
                  //                 // separatorBuilder: (context, index) =>
                  //                 //     myId == usersDoc[index].id
                  //                 //         ? const SizedBox()
                  //                 //         : Container(
                  //                 //             height: 1,
                  //                 //             width: 2,
                  //                 //             color: Colors.grey.withOpacity(0.5),
                  //                 //           ),
                  //                 itemCount: usersDoc!.length,
                  //                 itemBuilder: (context, index) {
                  //                   return myId == usersDoc[index].id
                  //                       ? const SizedBox()
                  //                       : usersDoc[index]['status']=='Online'? _buildChatItem(
                  //                           usersDoc[index]['username'],
                  //                           usersDoc[index].id,
                  //                           myId,
                  //                           usersDoc[index]['image_url'],
                  //                           usersDoc[index]['status'],
                  //                           '',
                  //                           true,
                  //                           '',
                  //                           false,
                  //                           false,
                  //                           context):const SizedBox();
                  //                 },
                  //               );
                  //             }),
                  //       )
                  // :
                  Expanded(
                    child: StreamBuilder(
                      stream: _firestore
                          .collection('users/$myId/chatUsers')
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot1) {
                        if (snapshot1.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot1.connectionState == ConnectionState.none) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot1.error == true) {
                          return const Center(child: Text('Error'));
                        }
                        final chatUsersDocs = snapshot1.data?.docs;

                        return ListView.builder(
                          // shrinkWrap: true,
                          reverse: false,
                          // separatorBuilder: (context, index) =>
                          //     myId == chatUsersDocs[index].id
                          //         ? const SizedBox()
                          //         : Container(
                          //             width: double.infinity,
                          //             height: 1.0,
                          //             color: Colors.grey.withOpacity(0.5),
                          //           ),
                          itemCount: chatUsersDocs!.length,
                          itemBuilder: (context, index) {
                            return StreamBuilder(
                              stream: _firestore
                                  .collection('users')
                                  .doc(chatUsersDocs[index].id)
                                  .snapshots(),
                              builder: (context, snapshot2) {
                                if (snapshot2.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(child: SizedBox());
                                }
                                if (snapshot2.error == true) {
                                  return const Center(child: Text('Error'));
                                }
                                final usersDocs = snapshot2.data;
                                final Timestamp time =
                                    chatUsersDocs[index]['time'];
                                final DateTime myTime = DateTime.now();
                                String lastMsgTime =
                                    DateFormat('jm').format(time.toDate());
                                if (myTime.difference(time.toDate()).inDays >
                                        1 &&
                                    myTime.difference(time.toDate()).inDays <
                                        7) {
                                  lastMsgTime =
                                      DateFormat('EEEE').format(time.toDate());
                                } else if (myTime
                                        .difference(time.toDate())
                                        .inDays >=
                                    7) {
                                  if ('${(myTime.difference(time.toDate()).inDays / 7).floor()}' ==
                                      '1') {
                                    lastMsgTime = 'One week ago';
                                  } else {
                                    lastMsgTime =
                                        '${(myTime.difference(time.toDate()).inDays / 7).floor()} Weeks ago';
                                  }
                                }

                                return myId == chatUsersDocs[index].id
                                    ? const SizedBox()
                                    : selectedCategoryChats
                                        ? Container(
                                            child: _buildChatItem(
                                                usersDocs!['username'],
                                                usersDocs.id,
                                                myId,
                                                usersDocs['image_url'],
                                                usersDocs['status'],
                                                chatUsersDocs[index]['lastMsg'],
                                                chatUsersDocs[index]['seen'],
                                                lastMsgTime,
                                                chatUsersDocs[index]
                                                        ['lastMsgSenderId'] ==
                                                    myId,
                                                true,
                                                context),
                                          )
                                        : usersDocs!['status'] == 'Online'
                                            ? Container(
                                                child: _buildChatItem(
                                                    usersDocs['username'],
                                                    usersDocs.id,
                                                    myId,
                                                    usersDocs['image_url'],
                                                    usersDocs['status'],
                                                    chatUsersDocs[index]
                                                        ['lastMsg'],
                                                    chatUsersDocs[index]
                                                        ['seen'],
                                                    lastMsgTime,
                                                    chatUsersDocs[index][
                                                            'lastMsgSenderId'] ==
                                                        myId,
                                                    true,
                                                    context),
                                              )
                                            : const SizedBox();
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),

      bottomNavigationBar:
          // BottomNavigationBar(()
          //   selectedLabelStyle: const TextStyle(
          //       color: textClr, fontSize: 14, fontWeight: FontWeight.w400,fontFamily: 'Sfpro'),
          //   unselectedLabelStyle: const TextStyle(
          //       color: textClr, fontSize: 14, fontWeight: FontWeight.w400,fontFamily: 'Poppins'),
          //   elevation: 2,
          //   backgroundColor: Colors.white,
          //   selectedItemColor: textClr,
          //   unselectedItemColor: textClr.withOpacity(0.3),
          //   type: BottomNavigationBarType.fixed,
          //   iconSize: 22,
          //   currentIndex: _selectedIndex,
          //   onTap: (index) {
          //     setState(() {
          //       _selectedIndex = index;
          //       if (index == 0) {
          //         selectedCategoryChats = true;
          //       } else if (index == 1) {
          //         Navigator.push(context, _createSearchScreenRoute());
          //       }
          //     });
          //   },
          //   items: const [
          //     BottomNavigationBarItem(
          //       icon: Icon(Double.chat_1),
          //       label: 'Discussions',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Double.users),
          //       label: 'Contacts',
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Double.user),
          //       label: 'Profile',
          //     ),
          //   ],
          // ),

          Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: textClr,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: textClr,
              tabs: const [
                GButton(
                  icon: Double.chat_empty,
                  //LineIcons.rocketChat,
                  // Double.chat,
                  text: 'Discussions',
                  iconColor: textClr,
                  textColor: textClr,
                ),
                GButton(
                  icon: Double.users_1,
                  //Icons.people_alt_outlined,
                  text: 'Contacts',
                  iconColor: textClr,
                  textColor: textClr,
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                  iconColor: textClr,
                  textColor: textClr,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                  if (index == 0) {
                    selectedCategoryChats = true;
                  } else if (index == 1) {
                    Navigator.push(context, _createSearchScreenRoute());
                  }
                });
              },
            ),
          ),
        ),
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
      bool slidable,
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
        // PageTransition(
        //   type: PageTransitionType.rightToLeft,
        //   child: MessagesScreen(
        //     username: username,
        //     receiverId: receiverId,
        //     currentUsername: currentUsername,
        //     id: id,
        //   ),
        //   duration: const Duration(milliseconds: 500),
        // ));
      }),
      child: Slidable(
        endActionPane: slidable
            ? ActionPane(
                extentRatio: 0.15,
                motion: const DrawerMotion(),
                children: [
                  if (slidable)
                    SlidableActionEdited(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      borderRadius: BorderRadius.circular(25),
                      margin:
                          const EdgeInsets.only(right: 15, top: 5, bottom: 5),
                      onPressed: (context) {
                        showDialog(
                            context: context,
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 7),
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
                                            _firestore
                                                .collection(
                                                    'users/$id/chatUsers/')
                                                .doc(receiverId)
                                                .delete();
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                              color: Colors.red,
                                            ),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      backgroundColor: const Color(0xFFffe4e4),
                      foregroundColor: const Color(0xFFf56a5f),
                      icon: LineIcons.trash,
                    ),
                ],
              )
            : null,
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(25),
          //   border: Border.all(color: Colors.grey.withOpacity(0.2)),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                      backgroundImage: Image.network(imageUrl,
                          loadingBuilder: (context, child, loadingProgress) =>
                              loadingImage(),
                          errorBuilder: (context, error, stackTrace) =>
                              loadingImage()).image,
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
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                          fontWeight: seen ? FontWeight.w400 : FontWeight.w600,
                          fontSize: 18,
                          color: seen ? textClr.withOpacity(0.6) : textClr),
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
                            lastMsg.length < 20
                                ? lastMsg
                                : '${lastMsg.substring(0, 20)}...',
                            style: TextStyle(
                                fontWeight:
                                    seen ? FontWeight.w400 : FontWeight.w600,
                                fontSize: 15,
                                color:
                                    seen ? textClr.withOpacity(0.5) : textClr),
                          ),
                          Text(
                            //getLastMsg(receiverId),
                            '· $time',
                            style: TextStyle(
                                fontWeight:
                                    seen ? FontWeight.w400 : FontWeight.w600,
                                fontSize: 15,
                                color:
                                    seen ? textClr.withOpacity(0.5) : textClr),
                          ),
                        ],
                      )
                  ],
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!seen)
                        const CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.blue,
                        ),
                      const SizedBox(
                        width: 13,
                      ),
                    ],
                  ),
                )
                // const CircleAvatar(
                //   radius: 5,
                //   backgroundColor: Colors.blue,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container loadingImage() {
    return Container(
      width: 25,
      height: 25,
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
          borderRadius: BorderRadius.circular(25)),
    );
  }
}
