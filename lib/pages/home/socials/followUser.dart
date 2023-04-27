import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/userFollowCodeModel.dart';
import 'package:toucan/services/database.dart';

class FollowUser extends StatefulWidget {
  FollowUser(
      {super.key,
      required this.uid,
      required this.followCode,
      required this.followingList});
  final String uid;
  final int followCode;
  final List<dynamic> followingList;

  @override
  State<FollowUser> createState() => _FollowUserState();
}

class _FollowUserState extends State<FollowUser> {
  final Color toucanOrange = Color(0xfff28705);

  final formKeyFollow = GlobalKey<FormState>();

  TextEditingController yourFollowCodeController = TextEditingController();

  String _theirFriendCode = "";

  followUser(BuildContext context) async {
    final isValid = formKeyFollow.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyFollow.currentState!.save();
      await DatabaseService(uid: widget.uid).followUser(int.parse(_theirFriendCode));
      Navigator.of(context).pop();
    }
  }

  String getYourFollowCode(int followCode) {
    String yourFollowCode = followCode.toString();
    String newFollowCode = "";

    for (int i = 0; i < yourFollowCode.length; i += 4) {
      newFollowCode += yourFollowCode.substring(i, i + 4);
      if (newFollowCode.length < 19) newFollowCode += " ";
    }

    return newFollowCode;
  }

  @override
  Widget build(BuildContext context) {
    List<UserFollowCodeModel>? existingUsers =
        Provider.of<List<UserFollowCodeModel>?>(context);

    yourFollowCodeController.text = getYourFollowCode(widget.followCode);

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
        Row(
          children: [
            Spacer(flex: 1),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // ==== Your Follow Code ====
                  Container(
                    child: Text("Your Follow Code"),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: TextField(
                      readOnly: true,
                      controller: yourFollowCodeController,
                      textAlign: TextAlign.center,
                      onTap: () {
                        yourFollowCodeController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: yourFollowCodeController.text.length,
                        );
                        Clipboard.setData(
                            ClipboardData(text: yourFollowCodeController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      style: TextStyle(
                          color: toucanOrange, fontWeight: FontWeight.w500),
                    ),
                  ),

                  // ==== Their Follow Code ====
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: Text(
                      "To follow someone, enter their Follow Code.",
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                    child: Form(
                      key: formKeyFollow,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration:
                            InputDecoration(hintText: "0000 0000 0000 0000"),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          new CustomInputFormatter(),
                        ],
                        validator: (value) {
                          // Check if no input
                          if (value!.length <= 0) return 'Cannot be empty';

                          // Check if length is not 16 digits with 3 spaces
                          if (value.length < 19)
                            return "Follow code does not exist";

                          // Check if code is own follow code
                          if (value == yourFollowCodeController.text)
                            return "You cannot follow yourself";

                          // Remove spaces from input follow code
                          String theirFriendCode = value.replaceAll(" ", "");

                          // Check if code is in followed accounts
                          if (widget.followingList
                              .contains(int.parse(theirFriendCode)))
                            return "Already following this account";

                          // Check if code matches any existing user
                          Iterable<UserFollowCodeModel> matchingUser =
                              existingUsers!.where((user) =>
                                  user.followCode.toString() ==
                                  theirFriendCode);
                          if (matchingUser.length == 0)
                            return "Follow code does not exist";
                          return null;
                        },
                        onSaved: (value) =>
                            _theirFriendCode = value!.replaceAll(" ", ""),
                      ),
                    ),
                  ),

                  // Follow button
                  Row(
                    children: [
                      Spacer(flex: 1),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => followUser(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                          ),
                          child: Text(
                            "Follow",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Spacer(flex: 1),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
    ;
  }
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    if (string.length > 19) {
      string = string.substring(0, 19);
    }

    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
