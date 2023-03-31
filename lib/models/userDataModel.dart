import 'package:flutter/material.dart';

class UserDataModel {
  final String _username;
  final String _greeter;
  final TimeOfDay _notificationTime;

  UserDataModel(this._username, this._greeter, this._notificationTime);

  String get username {
    return _username;
  }

  String get greeter {
    return _greeter;
  }

  TimeOfDay get notificationTime {
    return _notificationTime;
  }
}
