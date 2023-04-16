class TaskModel {
  final String _id;
  final DateTime _date;
  final String _title;
  bool _isDone;

  TaskModel(this._id, this._date, this._title, this._isDone);

  String get id => _id;
  DateTime get date => _date;
  String get title => _title;
  bool get isDone => _isDone;

  set isDone(bool value) {
    _isDone = value;
  }
}
