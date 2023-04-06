import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/shared/imagepickerpage.dart';
import 'package:toucan/shared/loading.dart';

class EditPost extends StatefulWidget {
  const EditPost({Key? key}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final Color toucanOrange = Color(0xfff28705);
  final Color toucanWhite = Color(0xFFFDFDF5);
  final double imageSize = 50;

  String _caption = '';

  File? _postPhoto;
  XFile? _postPhotoWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pass true to pop the widget and its root
      // Unallow user to proceed without picking at least one picture
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
            if (kIsWeb ? _postPhotoWeb != null : _postPhoto != null)
              return true;
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
                onPressed: () {
                  print("Popped through icon button");
                  (kIsWeb ? _postPhotoWeb == null : _postPhoto == null)
                      ? Navigator.popUntil(context, (route) {
                          return count++ == 2;
                        })
                      : Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
            actionsPadding: EdgeInsets.only(bottom: 37),
            actions: [
              ImagePickerPage(
                updateImage: updateImage,
                updateImageWeb: updateImageWeb,
                isCrop: false,
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
    print("Inside Update image: $imageFile");
    if (imageFile != null) {
      setState(() {
        _postPhoto = imageFile;
      });
    }
  }

  updateImageWeb(XFile? imageFileWeb) {
    if (imageFileWeb != null) {
      setState(() {
        _postPhotoWeb = imageFileWeb;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              padding: const EdgeInsets.only(right: 36),
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
      body: userData == null
          ? Loading(size: 40)
          : Form(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // === User Photo & Username ===
                      Container(
                        height: imageSize,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: Container(
                                color: toucanWhite,
                                width: imageSize,
                                child: Image.network(
                                  userData.urlProfilePhoto,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: imageSize * .15, left: 13),
                              child: Text(
                                userData.username,
                                style: TextStyle(
                                  color: toucanOrange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // === GREETER ===
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 12),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          // TODO: initialValue: place caption,
                          decoration: InputDecoration(
                            hintText: "Add a caption...",
                            hintStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: toucanOrange,
                            ),
                            contentPadding: EdgeInsets.all(15),
                            errorMaxLines: 3,
                          ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return 'Must not be empty';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _caption = value!,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: toucanWhite,
                          ),
                          onPressed: () {
                            showImageOptions();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: (kIsWeb
                                        ? _postPhotoWeb == null
                                        : _postPhoto == null)
                                    ? MediaQuery.of(context).size.height * .45
                                    : null,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: toucanOrange,
                                    ),
                                    Text(
                                      "/",
                                      style: TextStyle(
                                        color: toucanOrange,
                                        fontSize: 30,
                                      ),
                                    ),
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: toucanOrange,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: kIsWeb
                                      ? _postPhotoWeb != null
                                          ? Image.network(
                                              _postPhotoWeb!.path,
                                              fit: BoxFit.cover,
                                            )
                                          : SizedBox()
                                      : _postPhoto != null
                                          ? Image.file(
                                              File(_postPhoto!.path),
                                              fit: BoxFit.cover,
                                            )
                                          : SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
