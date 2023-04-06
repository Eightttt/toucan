class PostModel {
  final String _id;
  final String _title;
  final String _caption;
  final String _imageURL;
  final DateTime _date;

  PostModel(
    this._id,
    this._title,
    this._caption,
    this._imageURL,
    this._date,
  );

  String get id => _id;
  String get title => _title;
  String get caption => _caption;
  String get imageURL => _imageURL;
  DateTime get date => _date;
}
