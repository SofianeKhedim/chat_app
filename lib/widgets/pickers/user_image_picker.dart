import 'dart:io';

import 'package:chat_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.imagePickFn});

  final void Function(File? pickedImage) imagePickFn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  void _pickImage(ImageSource src) async {
    final pickedImageFile = await _picker.pickImage(source: src,imageQuality: 50,maxWidth: 150);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(_pickedImage);
    } else {
      print('No Image Selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          
          child:_pickedImage == null ? const Icon(Icons.person,color: secondaryClr,size: 50,):null,
          radius: 40,
          backgroundColor: darkGreyClr,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 1),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: primaryClr.withOpacity(0.1),
                borderRadius: BorderRadius.circular(29),
              ),
              child: TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(
                  Icons.photo_camera,
                  color: primaryClr,
                ),
                label: Text(
                  'Add Image\nFrom Camera',
                  textAlign: TextAlign.center,
                  style: subTitle,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 1),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: primaryClr.withOpacity(0.1),
                borderRadius: BorderRadius.circular(29),
              ),
              child: TextButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(
                  Icons.image_outlined,
                  color: primaryClr,
                ),
                label: Text(
                  'Add Image\nFrom Gallery',
                  textAlign: TextAlign.center,
                  style: subTitle,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
