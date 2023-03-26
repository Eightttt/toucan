class GoalModel {
  final String _title;
  final String _tag;
  final DateTime _startDate;
  final DateTime _endDate;
  final int _period;
  final String _frequency;
  final String _description;
  final String _status;
  final bool _isPrivate;

  GoalModel(
    this._title,
    this._tag,
    this._startDate,
    this._endDate,
    this._period,
    this._frequency,
    this._description,
    this._status,
    this._isPrivate,
  );

  String get title => _title;

  String get tag => _tag;

  DateTime get startDate => _startDate;

  DateTime get endDate => _endDate;

  int get period => _period;

  String get frequency => _frequency;

  String get description => _description;

  String get status => _status;

  bool get isPrivate => _isPrivate;
}
