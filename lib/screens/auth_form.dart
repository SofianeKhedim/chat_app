import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/auth/login_button.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password, String username,
      bool isLogin, BuildContext ctx, File? image) submitFn;
  final isLoading;

  const AuthForm(this.submitFn, this.isLoading, {super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String? _email = '';
  String? _password = '';
  String? _username = '';
  File? _userImageFile;

  void _pickedImage(File? pickedImage) {
    _userImageFile = pickedImage;
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please pick an image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }
 
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_email!.trim(), _password!.trim(), _username!.trim(),
          _isLogin, context, _userImageFile,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: defaultPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                if (_isLogin)
                  Image.asset(
                    'assests/login_png.png',
                    height: 250,
                  ),
                Row(
                  children: [
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: titleText,
                    ),
                  ],
                ),
                if (!_isLogin) const SizedBox(height: 30),
                if (!_isLogin) UserImagePicker(imagePickFn: _pickedImage),
                if (!_isLogin) const SizedBox(height: 20),
                if (!_isLogin)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                const SizedBox(height: 15),
                if (!_isLogin)
                  TextForm(
                    fkey: const ValueKey('username'),
                    fvalidator: (val) {
                      if (val!.isEmpty || val.length < 4) {
                        return 'Please enter at least 4 characters';
                      }
                      return null;
                    },
                    fonSaved: (val) => _username = val,
                    icon: Icons.person,
                    hint: 'User name',
                  ),
                TextForm(
                  fkey: const ValueKey('email'),
                  fvalidator: (val) {
                    if (val!.isEmpty || !val.contains('@')) {
                      return 'Please enter a valid email adress';
                    }
                    return null;
                  },
                  fonSaved: (val) => _email = val,
                  icon: Icons.mail,
                  hint: 'Email',
                ),
                TextForm(
                  fkey: const ValueKey('password'),
                  fvalidator: (val) {
                    if (val!.isEmpty || val.length < 7) {
                      return 'Password must be at least 7 characters';
                    }
                    return null;
                  },
                  fonSaved: (val) => _password = val,
                  icon: Icons.lock,
                  hint: 'Password',
                  isPassword: true,
                ),
                MyButton(
                  onTap: _submit,
                  buttonText: _isLogin ? 'LOGIN' : 'Sign Up',
                  isLoading: widget.isLoading,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'New to this app?' : 'Already a member?',
                      style: subTitle,
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        !_isLogin ? 'LOGIN' : 'Sign Up',
                        style: textButton.copyWith(
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _textFormFeild({
  //   required IconData icon,
  //   required String hint,
  //   bool isPassword = false,
  //   bool isUserName =false,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 5),
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  //     decoration: BoxDecoration(
  //       color: primaryClr.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(29),
  //     ),
  //     child: TextField(
  //       obscureText: isPassword ? (_viewPassword ? false : true) : false,
  //       keyboardType: isPassword
  //           ? TextInputType.visiblePassword
  //           : isUserName
  //               ? TextInputType.text
  //               : TextInputType.emailAddress,
  //       decoration: InputDecoration(
  //         icon: Icon(
  //           icon,
  //           color: primaryClr,
  //         ),
  //         suffixIcon: isPassword
  //             ? IconButton(
  //                 icon: _viewPassword
  //                     ? const Icon(
  //                         Icons.visibility,
  //                         color: primaryClr,
  //                       )
  //                     : const Icon(
  //                         Icons.visibility_off,
  //                         color: primaryClr,
  //                       ),
  //                 onPressed: () {
  //                   setState(() {
  //                     _viewPassword = !_viewPassword;
  //                   });
  //                 })
  //             : null,
  //         hintText: hint,
  //         border: InputBorder.none,
  //       ),
  //     ),
  //   );
  // }

}
