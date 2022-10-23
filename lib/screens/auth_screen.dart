import 'dart:io';

import 'package:chat_app/screens/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx, File? image) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref('user_image')
            .child('${authResult.user!.uid}.jpg');
        await ref.putFile(image!);
        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'email': email,
          'username': username,
          'password': password,
          'image_url': imageUrl,
          'isTyping': null,
          'status': 'Online'
        });
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'error Occured';
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      //   content: Text(e.toString()),
      //   backgroundColor: Theme.of(ctx).errorColor,
      // ));
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
