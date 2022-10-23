import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:chat_app/theme/theme.dart';
import 'package:chat_app/widgets/auth/login_button.dart';
import 'package:chat_app/widgets/auth/login_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/pickers/select_photo_options_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final String myId = FirebaseAuth.instance.currentUser!.uid;
  String imageUrl = '';
  String? _username = '';
  bool _isLoading = false;
  bool _imagePicked = false;
  final _formKey = GlobalKey<FormState>();


  

  _flushbar(String flushbarText, BuildContext context) {
    return Flushbar(
      title: 'Done',
      message: flushbarText,
      titleColor: Colors.white,
      backgroundColor: Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: 3),
    ).show(context);
  }

  _submit(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    try {
      if (_imagePicked && !isValid) {
        
        setState(() {
          _isLoading = true;
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(myId)
            .update({'image_url': imageUrl});
        setState(() {
          _isLoading = false;
        });
        await _flushbar('Profile pic successfully updated',context);
      } else if (isValid && _imagePicked && _username!.trim() != '') {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });

        await FirebaseFirestore.instance.collection('users').doc(myId).update({
          'image_url': imageUrl,
          'username': _username!.trim(),
        });
        setState(() {
          _isLoading = false;
        });
        await _flushbar('updated successfully',context);
      } else if (isValid && !_imagePicked) {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });
        await FirebaseFirestore.instance.collection('users').doc(myId).update({
          'username': _username!.trim(),
        });
        setState(() {
          _isLoading = false;
        });
        _flushbar('Username successfully updated ',context);
      } else if (isValid && _imagePicked && _username!.trim() == '') {
        setState(() {
          _isLoading = true;
        });

        await FirebaseFirestore.instance.collection('users').doc(myId).update({
          'image_url': imageUrl,
        });
        setState(() {
          _isLoading = false;
        });
        
        await _flushbar('Profile pic successfully updated',context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
     
  }

  @override
  Widget build(BuildContext context) {
    File? _userImageFile;
    File? _pickedImage;

    void _pickedImageFn(File? pickedImage) async {
      _userImageFile = pickedImage;

      final ref = FirebaseStorage.instance.ref('user_image');
      await ref.putFile(pickedImage!);
      
      final imageUrlRef = await ref.getDownloadURL();
      setState(() {
        imageUrl = imageUrlRef;
        _imagePicked = true;
      });

      // await FirebaseFirestore.instance.collection('users').doc(myId).update({
      //   'image_url':imageUrl
      // });
      print('pickedimg : $imageUrlRef');
    }

    final ImagePicker _picker = ImagePicker();

    void _pickImage(ImageSource src) async {
      final pickedImageFile =
          await _picker.pickImage(source: src, imageQuality: 50, maxWidth: 150);
          
      if (pickedImageFile != null) {
        setState(() {
          _pickedImage = File(pickedImageFile.path);
        });
        _pickedImageFn(_pickedImage);
      } else {
        print('No Image Selected');
      }
    }

    void _showSelectPhotoOptions(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.5,
              maxChildSize: 0.5,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: SelectPhotoOptionsScreen(
                    onTap: _pickImage,
                  ),
                );
              });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: textClr),
        ),
        iconTheme: IconThemeData(color: textClr),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(myId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final username = snapshot.data?['username'];
                if (imageUrl == '') {
                  imageUrl = snapshot.data?['image_url'];
                }
                final email = snapshot.data?['email'];
                return Center(
                  child: Column(children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Stack(
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
                                Icons.add_a_photo,
                                color: Colors.white,
                              ),
                              onPressed: () => _showSelectPhotoOptions(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                );
              }),
          const SizedBox(
            height: 40,
          ),
          Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextForm(
                icon: Icons.person,
                hint: 'New username',
                fvalidator: (val) {
                  if (val!.isEmpty && _imagePicked) {
                    return null;
                  } else if (val.isEmpty || val.length < 4 && !_imagePicked) {
                    return 'Please enter a username or an image';
                  } else if (val.isEmpty || val.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                fonSaved: (val) => _username = val,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: MyButton(
              buttonText: 'Save Changes',
              isLoading: _isLoading,
              color: Colors.blue,
              key: const ValueKey('username'),
              onTap: ()  {
                _submit(context);
              },
            ),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
