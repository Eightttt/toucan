class TaskModel {
  final DateTime _date;
  final String _title;
  bool _isDone;

  TaskModel(this._date, this._title, this._isDone);

  DateTime get date => _date;
  String get title => _title;
  bool get isDone => _isDone;

  set isDone(bool value) {
    _isDone = value;
  }
}
