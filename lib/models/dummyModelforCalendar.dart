class DummyModel {
  String task;
  bool status;

  DummyModel({this.task = "", this.status = false});

  String get taskString {
    return task;
  }

  bool get statusBool {
    return status;
  }
}