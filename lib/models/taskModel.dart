class TaskModel {
  final DateTime _date;
  final String _task;
  bool _isDone;

  TaskModel(this._date, this._task, this._isDone);

  DateTime get date => _date;
  String get task => _task;
  bool get isDone => _isDone;

  set isDone(bool value) {
    _isDone = value;
  }
}
