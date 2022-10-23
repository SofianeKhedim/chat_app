// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:another_flushbar/flushbar.dart';
import 'package:chat_app/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({
    Key? key,
    required this.receiverId,
  }) : super(key: key);

  final String receiverId;

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _controller = TextEditingController();
  String _entredMessage = "";
  final String senderId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    setSeen();

    // TODO: implement initState
    super.initState();
  }

  void setSeen() {
    FirebaseFirestore.instance
        .collection('users/$senderId/chatUsers')
        .doc(widget.receiverId)
        .set({'seen': true}, SetOptions(merge: true));
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();

    //make isTyping to null
    FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .update({'isTyping': null});

    //add text to receiver db
    FirebaseFirestore.instance
        .collection('users/${widget.receiverId}/chatUsers/$senderId/chat')
        .add({
      'text': _entredMessage,
      'createdAt': Timestamp.now(),
      'senderId': senderId,
      'receiverId': widget.receiverId,
    });
    //add text to sender db
    FirebaseFirestore.instance
        .collection('users/$senderId/chatUsers/${widget.receiverId}/chat')
        .add({
      'text': _entredMessage,
      'createdAt': Timestamp.now(),
      'senderId': senderId,
      'receiverId': widget.receiverId,
    });
    //add text to last sender db
    FirebaseFirestore.instance
        .collection('users/$senderId/chatUsers/')
        .doc(widget.receiverId)
        .set(
      {
        'lastMsgSenderId': senderId,
        'lastMsg': _entredMessage,
        'seen': true,
        'time': Timestamp.now()
      },
    );
    //add text to last receiver db
    FirebaseFirestore.instance
        .collection('users/${widget.receiverId}/chatUsers/')
        .doc(senderId)
        .set(
      {
        'lastMsgSenderId': senderId,
        'lastMsg': _entredMessage,
        'seen': false,
        'time': Timestamp.now()
      },
    );

    _controller.clear();
    _entredMessage = '';
  }

  @override
  void dispose() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .update({'isTyping': null});
    // TODO: implement dispose
    super.dispose();
  }

  bool showEmoji = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            offset: const Offset(0.0, -3), 
            blurRadius: 3.0,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
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
                  child: TextField(
                    onTap: () {
                      setSeen();
                      setState(() {
                        showEmoji = false;
                      });
                    },
                    onSubmitted: ((value) {
                      if (_entredMessage.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    }),
                    controller: _controller,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                          color: textClr.withOpacity(0.6),
                          onPressed: () {
                            setState(() {
                              showEmoji = true;
                            });
                            FocusScope.of(context).unfocus();
                            print(showEmoji);
                          },
                          icon: const Icon(Icons.emoji_emotions_outlined)),
                      hintText: 'Type message',
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _entredMessage = val;
                        if (_entredMessage.trim() != "") {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(senderId)
                              .update({'isTyping': widget.receiverId});
                        } else {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(senderId)
                              .update({'isTyping': null});
                        }
                        setSeen();
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_entredMessage.trim().isNotEmpty) {
                    _sendMessage();
                  } else {
                    _entredMessage = '♥️';
                    _sendMessage();
                  }
                },
                icon: _entredMessage.trim().isEmpty
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 32,
                      )
                    : const Icon(Icons.send),
              )
            ],
          ),
          Offstage(
            offstage: !showEmoji,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (_, emoji) {
                  _entredMessage = _entredMessage + emoji.toString();
                },
                textEditingController: _controller,
                config: const Config(
                  columns: 7,
                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 32 * 1.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  bgColor: Colors.white,
                  indicatorColor: Colors.blue,
                  iconColor: Colors.grey,
                  iconColorSelected: Colors.blue,
                  backspaceColor: Colors.blue,
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.grey,
                  enableSkinTones: true,
                  showRecentsTab: true,
                  recentsLimit: 28,
                  replaceEmojiOnLimitExceed: false,
                  noRecents: Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                  loadingIndicator: SizedBox.shrink(),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                  checkPlatformCompatibility: true,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  emojiPickerFn() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        // Do something when emoji is tapped (optional)
      },
      onBackspacePressed: () {
        // Do something when the user taps the backspace button (optional)
      },
      textEditingController:
          _controller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
      config: const Config(
        columns: 7,
        emojiSizeMax:
            32 * 1.0, // Issue: https://github.com/flutter/flutter/issues/28894
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.RECENT,
        bgColor: Color(0xFFF2F2F2),
        indicatorColor: Colors.blue,
        iconColor: Colors.grey,
        iconColorSelected: Colors.blue,
        backspaceColor: Colors.blue,
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        enableSkinTones: true,
        showRecentsTab: true,
        recentsLimit: 28,
        noRecents: Text(
          'No Recents',
          style: TextStyle(fontSize: 20, color: Colors.black26),
          textAlign: TextAlign.center,
        ),
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: CategoryIcons(),
        buttonMode: ButtonMode.MATERIAL,
      ),
    );
  }
}
