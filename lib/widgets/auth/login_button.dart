import 'package:chat_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
   MyButton({
    Key? key,
    required this.buttonText,
    required this.isLoading,
    this.onTap,
    this.color=primaryClr
  }) : super(key: key);
  final bool isLoading;
  final String buttonText;
  final Color color;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 700),
        margin: const EdgeInsets.only(top: 25),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.075,
        width: isLoading? 95:double.infinity,
        decoration:  BoxDecoration(
             shape: isLoading? BoxShape.circle : BoxShape.rectangle,
            borderRadius: !isLoading? BorderRadius.circular(35) : null, color: color),
        child: isLoading? const CircularProgressIndicator(color: Colors.white,) : Text(
          buttonText,
          style: textButton.copyWith(color: whiteClr),
        ),
      ),
    );
  }
}
