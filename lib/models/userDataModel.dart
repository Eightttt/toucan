class UserDataModel {
  final String _username;
  final String _greeter;

  UserDataModel(this._username, this._greeter);

  String get username {
    return _username;
  }

  String get greeter {
    return _greeter;
  }
}
