class PostModel {
  final String _id;
  final String _caption;
  final String _imageURL;
  final DateTime _date;

  PostModel(
    this._id,
    this._caption,
    this._imageURL,
    this._date,
  );

  String get id => _id;
  String get caption => _caption;
  String get imageURL => _imageURL;
  DateTime get date => _date;
}
