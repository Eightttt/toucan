import 'package:flutter/material.dart';

class UserDataModel {
  final String _username;
  final String _greeter;
  final TimeOfDay _notificationTime;
  final String _urlProfilePhoto;

  UserDataModel(this._username, this._greeter, this._notificationTime, this._urlProfilePhoto);

  String get username {
    return _username;
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
