class PostModel {
  final String _id;
  final String _caption;
  final String _imageURL;
  final DateTime _date;
  final DateTime? _editDate;

  PostModel(
    this._id,
    this._caption,
    this._imageURL,
    this._date,
    this._editDate,
  );

  String get id => _id;
  String get caption => _caption;
  String get imageURL => _imageURL;
  DateTime get date => _date;
  DateTime? get editDate => _editDate;
}
