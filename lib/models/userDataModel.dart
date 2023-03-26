class UserDataModel {
  final String username;
  final String description;

  UserDataModel({required this.username, required this.description});

  String get getUsername {
    return username;
  }

  String get getDescription {
    return description;
  }
}
