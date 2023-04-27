import 'package:flutter/material.dart';

class UserDataModel {
  final String _username;
  final int _followCode;
  final List<dynamic> _followingList;
  final String _greeter;
  final TimeOfDay _notificationTime;
  final String _urlProfilePhoto;

  UserDataModel(this._username, this._followingList, this._followCode,
      this._greeter, this._notificationTime, this._urlProfilePhoto);

  String get username {
    return _username;
  }

  int get followCode {
    return _followCode;
  }

  List<dynamic> get followingList {
    return _followingList;
  }

  String get greeter {
    return _greeter;
  }

  TimeOfDay get notificationTime {
    return _notificationTime;
  }

  String get urlProfilePhoto {
    return _urlProfilePhoto;
  }
}
