class GoalModel {
  final String _title;
  final String _tag;
  final DateTime _startDate;
  final DateTime _endDate;
  final int _period;
  final String _frequency;
  final String _description;
  late String _status;
  final bool _isPrivate;
  final String _id;

  GoalModel(
    this._id,
    this._title,
    this._tag,
    this._startDate,
    this._endDate,
    this._period,
    this._frequency,
    this._description,
    this._isPrivate,
  ) {
    this._status = _setStatus(startDate, endDate);
  }

  String _setStatus(DateTime startDate, DateTime endDate) {
    if (DateTime.now().isBefore(startDate)) return "not started";
    if (DateTime.now().isAfter(endDate)) return "done";
    return "in-progress";
  }

  String get title => _title;
  String get tag => _tag;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get period => _period;
  String get frequency => _frequency;
  String get description => _description;
  String get status => _status;
  bool get isPrivate => _isPrivate;
  String get id => _id;
}
