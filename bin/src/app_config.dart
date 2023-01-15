abstract class IAppConfig {
  String get path;
  String? applicationID;
  Future<void> save();
}
