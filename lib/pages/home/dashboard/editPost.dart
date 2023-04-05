import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toucan/shared/imagepickerpage.dart';

class EditPost extends StatefulWidget {
  const EditPost({Key? key}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final Color toucanOrange = Color(0xfff28705);

  File? _postPhoto;
  XFile? _postPhotoWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showImageOptions();
    });
  }

  showImageOptions() {
    showDialog(
      context: context,
      builder: (context) {
        int count = 0;
        return WillPopScope(
          onWillPop: () async {
            Navigator.popUntil(context, (route) {
              return count++ == 2;
            });
            return false;
          },
          child: AlertDialog(
            iconPadding: EdgeInsets.only(top: 10),
            icon: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                color: Color(0xfff28705),
                onPressed: () => Navigator.popUntil(context, (route) {
                  return count++ == 2;
                }),
                icon: Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
            actionsPadding: EdgeInsets.only(bottom: 37),
            actions: [
              ImagePickerPage(
                updateImage: updateImage,
                updateImageWeb: updateImageWeb,
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
        );
      },
    );
  }

  updateImage(File? imageFile) {
    if (imageFile != null) {
      setState(() {
        _postPhoto = imageFile;
      });
      Navigator.of(context).pop();
    }
  }

  updateImageWeb(XFile? imageFileWeb) {
    if (imageFileWeb != null) {
      setState(() {
        _postPhotoWeb = imageFileWeb;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: toucanOrange,
          icon: Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFFFDFDF5),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "New Post",
              style: TextStyle(
                color: toucanOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 21),
              child: ElevatedButton(
                onPressed: () => print("post it"),
                child: Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  minimumSize: Size(76, 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(),
    );
  }
}
