import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPage extends StatefulWidget {
  final Function(File?) updateImage;
  final Function(XFile?) updateImageWeb;
  const ImagePickerPage(
      {required this.updateImage, required this.updateImageWeb, super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final Color toucanOrange = Color(0xfff28705);
  final Color toucanWhite = Color(0xFFFDFDF5);

  Future pickImage(ImageSource imageSource) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: imageSource);
      if (pickedImage == null) return;

      if (kIsWeb) {
        widget.updateImageWeb(pickedImage);
        Navigator.of(context).pop();
      } else {
        File? image = File(pickedImage.path);
        image = await cropSquareImage(pickedImage);
        widget.updateImage(image);
        if (image != null) Navigator.of(context).pop();
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File?> cropSquareImage(XFile imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 25,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Photo",
          toolbarColor: toucanOrange,
          backgroundColor: toucanWhite,
          cropFrameColor: toucanWhite,
          cropGridColor: toucanWhite,
          activeControlsWidgetColor: toucanOrange,
        ),
        IOSUiSettings(title: "Crop Photo"),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 10),
          child: ElevatedButton.icon(
            icon: Icon(Icons.insert_photo_outlined),
            onPressed: () => pickImage(ImageSource.gallery),
            label: Text(
              "Choose from Gallery",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 10, 45, 10),
          child: ElevatedButton.icon(
            onPressed: () => pickImage(ImageSource.camera),
            icon: Icon(Icons.photo_camera_outlined),
            label: Text(
              "Take a New Photo",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
