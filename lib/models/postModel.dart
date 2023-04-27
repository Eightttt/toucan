class PostModel {
  final String _username;
  final int _followCode;
  final String _id;
  final String _caption;
  final String _imageURL;
  final DateTime _date;
  final bool _isEdited;

  PostModel(
    this._username,
    this._followCode,
    this._id,
    this._caption,
    this._imageURL,
    this._date,
    this._isEdited,
  );

  String get username => _username;
  int get followCode => _followCode;
  String get id => _id;
  String get caption => _caption;
  String get imageURL => _imageURL;
  DateTime get date => _date;
  bool get isEdited => _isEdited;
}
