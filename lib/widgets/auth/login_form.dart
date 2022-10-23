// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class TextForm extends StatefulWidget {
  final Key? fkey;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final bool isUserName;
  final String? Function(String?)? fvalidator;
  final void Function(String?)? fonSaved;
  const TextForm({
    Key? key,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.isUserName = false,
     this.fkey,
     this.fvalidator,
     this.fonSaved,
  }) : super(key: key);

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {
  bool _viewPassword = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: primaryClr.withOpacity(0.1),
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextFormField(
        key: widget.fkey,
        validator: widget.fvalidator,
        onSaved: widget.fonSaved,
        obscureText: widget.isPassword ? (_viewPassword ? false : true) : false,
        keyboardType: widget.isPassword
            ? TextInputType.visiblePassword
            : widget.isUserName
                ? TextInputType.text
                : TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: Icon(
            widget.icon,
            color: primaryClr,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: _viewPassword
                      ? const Icon(
                          Icons.visibility,
                          color: primaryClr,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: primaryClr,
                        ),
                  onPressed: () {
                    setState(() {
                      _viewPassword = !_viewPassword;
                    });
                  })
              : null,
          hintText: widget.hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
