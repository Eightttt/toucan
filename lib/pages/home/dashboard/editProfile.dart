import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toucan/shared/loading.dart';

import '../../../models/userDataModel.dart';
import '../../../services/database.dart';

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

  String _username = "";

  String _greeter = "";

  TextEditingController _notificationTimeText = TextEditingController();
  late TimeOfDay _pickedNotificationTime;
  late TimeOfDay _notificationTime;

  imagePicker() {
    print("Image picker");
  }

  saveUserData() {
    final isValid = formKeyUser.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyUser.currentState!.save();
      DatabaseService(uid: widget.uid).updateUserData(
        _username,
        _greeter,
        _notificationTime,
      );
      Navigator.of(context).pop();
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);

    if (userData != null) {
      _pickedNotificationTime = userData.notificationTime;
      _notificationTimeText.text =
          _pickedNotificationTime.format(context).toString();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: userData == null
          ? Loading()
          : Container(
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

                                if (value!.length < 4 || value.length > 20) {
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
                                hintText: "Start Date - End Date",
                                errorMaxLines: 3,
                              ),
                              controller: _notificationTimeText,
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: _pickedNotificationTime);

                                if (pickedTime != null) {
                                  _pickedNotificationTime = pickedTime;
                                  _notificationTimeText.text =
                                      _pickedNotificationTime
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
                                Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton(
                                      onPressed: saveUserData,
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
                      left:
                          MediaQuery.of(context).size.width / 2 - imageSize / 2,
                      child: Container(
                        height: imageSize,
                        width: imageSize,
                        child: FloatingActionButton(
                          shape: CircleBorder(side: BorderSide.none),
                          elevation: 3,
                          onPressed: imagePicker,
                          child: CircleAvatar(
                            backgroundImage: Image.asset(
                              "assets/temp-img1.png",
                              fit: BoxFit.cover,
                            ).image,
                            radius: imageSize / 2,
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
                        onPressed: imagePicker,
                        child: Icon(Icons.camera_alt_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
