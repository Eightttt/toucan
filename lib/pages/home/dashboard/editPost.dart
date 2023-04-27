import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/imagepickerpage.dart';
import 'package:toucan/shared/loading.dart';

class EditPost extends StatefulWidget {
  final String uid;
  final String? goalId;
  final PostModel? post;

  const EditPost(
      {Key? key,
      required this.uid,
      required this.goalId,
      required this.post})
      : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final formKeyUser = GlobalKey<FormState>();
  bool _isSavingUserData = false;
  UploadTask? uploadTask;
  final _textFocusNode = FocusNode();

  final Color toucanOrange = Color(0xfff28705);
  final Color toucanWhite = Color(0xFFFDFDF5);
  final double imageSize = 50;
  late bool _isEdit;

  String? _caption = '';

  File? _postPhoto;
  XFile? _postPhotoWeb;
  String? _urlPostPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.post == null) {
      _isEdit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pass true to pop the widget and its root
        // Unallow user to proceed without picking at least one picture
        showImageOptions();
      });
    } else {
      _isEdit = true;
      _caption = widget.post?.caption;
      _urlPostPhoto = widget.post?.imageURL;
    }
  }

  showImageOptions() {
    showDialog(
      context: context,
      builder: (context) {
        int count = 0;
        return WillPopScope(
          onWillPop: () async {
            if ((kIsWeb ? _postPhotoWeb != null : _postPhoto != null) ||
                _isEdit) return true;
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
                  (kIsWeb ? _postPhotoWeb == null : _postPhoto == null) &&
                          (!_isEdit)
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

  savePostData(int followCode) async {
    String? postId = widget.post?.id;
    _textFocusNode.unfocus();
    final isValid = formKeyUser.currentState?.validate();

    if (isValid != null && isValid) {
      formKeyUser.currentState!.save();
      DatabaseService databaseService = DatabaseService(uid: widget.uid);
      setState(() {
        _isSavingUserData = true;
      });

      if (widget.goalId == null) return;
      // If post doesn't exist, create it first and get the postId
      if (postId == null) {
        postId = await DatabaseService(uid: widget.uid).updatePostData(
          widget.goalId!,
          postId,
          followCode,
          _caption!,
          _urlPostPhoto ?? '',
          _isEdit,
        );
      }

      // Upload post photo and get url
      if (kIsWeb ? _postPhotoWeb != null : _postPhoto != null) {
        _urlPostPhoto = await databaseService.uploadPostPhoto(
          widget.goalId!,
          postId!,
          _postPhoto,
          _postPhotoWeb,
          setUploadTask,
        );
      }

      // Save all changes
      await DatabaseService(uid: widget.uid).updatePostData(
        widget.goalId!,
        postId,
        followCode,
        _caption!,
        _urlPostPhoto ?? widget.post!.imageURL,
        _isEdit,
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

  @override
  void dispose() {
    _textFocusNode.dispose();
    super.dispose();
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
        },
      );

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
                onPressed: () => savePostData(userData!.followCode),
                child: Text(
                  _isEdit ? "Save" : "Post",
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
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Form(
                    key: formKeyUser,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
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
                                    child: CachedNetworkImage(
                                      imageUrl: userData.urlProfilePhoto,
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
                              focusNode: _textFocusNode,
                              textAlignVertical: TextAlignVertical.top,
                              keyboardType: TextInputType.multiline,
                              maxLines: 10,
                              initialValue: _caption,
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

                          // ==== Post Image ====
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
                                                : _postPhoto == null) &&
                                            (_urlPostPhoto == null)
                                        ? MediaQuery.of(context).size.height *
                                            .45
                                        : null,
                                    child: (_urlPostPhoto == null)
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: toucanOrange,
                                              ),
                                            ],
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: _urlPostPhoto!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: kIsWeb
                                          ? _postPhotoWeb != null
                                              ? CachedNetworkImage(
                                                  imageUrl: _postPhotoWeb!.path,
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
