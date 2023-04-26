class DummyModel {
  String assetPath;
  String caption;

  DummyModel({this.assetPath = "", this.caption = ""});

  String get assetPathString {
    return assetPath;
  }

  String get captionString {
    return caption;
  }
}