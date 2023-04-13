import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toucan/shared/loading.dart';
import '../../../models/userDataModel.dart';
import '../../../services/database.dart';
import '../../../shared/imagepickerpage.dart';

class EditProfile extends StatefulWidget {
  EditProfile(this.uid);
  final String uid;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKeyUser = GlobalKey<FormState>();

  final toucanOrange = Color(0xfff28705);
  final toucanWhite = Color(0xFFFDFDF5);

  final double iconSize = 36;
  final double appBarheight = 98;
  final double imageSize = 110;

  bool _isSavingUserData = false;
  UploadTask? uploadTask;
  String _username = "";
  String _greeter = "";
  String? _urlProfilePhoto;
  File? _profilePhoto;
  XFile? _profilePhotoWeb;

  TextEditingController _notificationTimeText = TextEditingController();
  bool _hasInitializedNotificationTimeText = false;
  TimeOfDay? _pickedNotificationTime;
  TimeOfDay? _notificationTime;

  showImageOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          iconPadding: EdgeInsets.only(top: 10),
          icon: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              color: Color(0xfff28705),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios_rounded),
            ),
          ),
          actionsPadding: EdgeInsets.only(bottom: 37),
          actions: [
            ImagePickerPage(
              updateImage: updateImage,
              updateImageWeb: updateImageWeb,
              isCrop: true,
            ),
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        );
      },
    );
  }

  updateImage(File? imageFile) {
    if (imageFile != null) {
      setState(() {
        _profilePhoto = imageFile;
      });
    }
  }

  updateImageWeb(XFile? imageFileWeb) {
    if (imageFileWeb != null) {
      setState(() {
        _profilePhotoWeb = imageFileWeb;
      });
    }
  }

  saveUserData(UserDataModel userData) async {
    final isValid = formKeyUser.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyUser.currentState!.save();
      DatabaseService databaseService = DatabaseService(uid: widget.uid);
      setState(() {
        _isSavingUserData = true;
      });
      _urlProfilePhoto = await databaseService.uploadProfilePhoto(
          _profilePhoto, _profilePhotoWeb, setUploadTask);
      DatabaseService(uid: widget.uid).updateUserData(
        _username,
        _greeter,
        _notificationTime ?? userData.notificationTime,
        _urlProfilePhoto ?? userData.urlProfilePhoto,
      );
      setState(() {
        _isSavingUserData = false;
      });
      Navigator.of(context).pop();
    } else {
      print("error");
    }
  }

  setUploadTask(UploadTask? newUploadTask) {
    setState(() {
      uploadTask = newUploadTask;
    });
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return Container(
            padding: EdgeInsets.only(top: 15, bottom: 35),
            child: Text(
              "Saving changes...\n${100 * progress.roundToDouble()}%",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          );
        } else {
          return Container(
            height: 50,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);

    if (userData != null && !_hasInitializedNotificationTimeText) {
      _hasInitializedNotificationTimeText =
          !_hasInitializedNotificationTimeText;
      _notificationTimeText.text =
          userData.notificationTime.format(context).toString();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: userData == null
          ? Loading(size: 40)
          : Stack(
              children: [
                Container(
                  color: toucanOrange,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Form(
                          key: formKeyUser,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(47, 0, 47, 0),
                            height: double.infinity,
                            color: toucanWhite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: appBarheight +
                                      MediaQuery.of(context).size.height * 0.1,
                                ),

                                // === USERNAME ===
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 3),
                                  child: Text(
                                    'Username',
                                    style: TextStyle(
                                      color: toucanOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  initialValue: userData.username,
                                  maxLength: 16,
                                  decoration: const InputDecoration(
                                    errorMaxLines: 3,
                                    counterText: "",
                                  ),
                                  validator: (value) {
                                    const pattern =
                                        r"^(?=[a-zA-Z0-9._]{4,20}$)(?!.*[_.]{2})[^_.].*[^_.]$";
                                    final regEx = RegExp(pattern);

                                    if (value!.length < 4 ||
                                        value.length > 20) {
                                      return 'Must be within 4 to 20 alphanumeric characters, underscores, or periods';
                                    } else if (!regEx.hasMatch(value)) {
                                      return 'Must not have leading, trailing, and repeating underscores and periods';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) => _username = value!,
                                ),

                                // === GREETER ===
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 20, 0, 3),
                                  child: Text(
                                    'Greeter',
                                    style: TextStyle(
                                      color: toucanOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  initialValue: userData.greeter,
                                  maxLength: 56,
                                  inputFormatters: [
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      int newLines =
                                          newValue.text.split('\n').length;
                                      if (newLines > 3) {
                                        return oldValue;
                                      } else {
                                        return newValue;
                                      }
                                    }),
                                  ],
                                  decoration: const InputDecoration(
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
                                  onSaved: (value) => _greeter = value!,
                                ),

                                // Notification Time
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 5, 0, 3),
                                  child: Text(
                                    'Notification Time',
                                    style: TextStyle(
                                      color: toucanOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    errorMaxLines: 3,
                                  ),
                                  controller: _notificationTimeText,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                            context: context,
                                            initialTime:
                                                userData.notificationTime);

                                    if (pickedTime != null) {
                                      _pickedNotificationTime = pickedTime;
                                      _notificationTimeText.text =
                                          _pickedNotificationTime!
                                              .format(context)
                                              .toString();
                                    }
                                  },
                                  validator: (value) {
                                    if (value!.length <= 0) {
                                      return 'Choose a time';
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (value) {
                                    _notificationTime = _pickedNotificationTime;
                                  },
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            side: BorderSide(
                                                width: 1, color: toucanOrange),
                                            backgroundColor: toucanWhite,
                                            foregroundColor: toucanOrange,
                                            minimumSize: const Size(120, 33),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Cancel")),
                                    ),
                                    Spacer(flex: 1),
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                          onPressed: () =>
                                              saveUserData(userData),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            side: BorderSide(
                                                width: 1, color: toucanOrange),
                                            minimumSize: const Size(120, 33),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          child: const Text("Save")),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ===== App Bar =====
                        Container(
                          height: appBarheight,
                          child: AppBar(
                            elevation: 4,
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_sharp),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          top: appBarheight - imageSize / 2,
                          left: MediaQuery.of(context).size.width / 2 -
                              imageSize / 2,
                          child: Container(
                            height: imageSize,
                            width: imageSize,
                            child: FloatingActionButton(
                              backgroundColor: toucanWhite,
                              shape: CircleBorder(side: BorderSide.none),
                              elevation: 3,
                              onPressed: showImageOptions,
                              child: ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: userData.urlProfilePhoto,
                                      fit: BoxFit.cover,
                                    ),
                                    kIsWeb
                                        ? _profilePhotoWeb != null
                                            ? CachedNetworkImage(
                                                imageUrl:
                                                    _profilePhotoWeb!.path,
                                                fit: BoxFit.cover,
                                              )
                                            : SizedBox()
                                        : _profilePhoto != null
                                            ? Image.file(
                                                File(_profilePhoto!.path),
                                                fit: BoxFit.cover,
                                              )
                                            : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          width: iconSize,
                          height: iconSize,
                          left: MediaQuery.of(context).size.width / 2 +
                              imageSize / 2 -
                              iconSize,
                          top: appBarheight + imageSize / 2 - iconSize,
                          child: FloatingActionButton(
                            elevation: 4,
                            onPressed: showImageOptions,
                            child: Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==== Uploading Progress Indicator ====
                Visibility(
                  visible: _isSavingUserData,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Loading(size: 40),
                      buildProgress(),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
