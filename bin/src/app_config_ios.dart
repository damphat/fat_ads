import 'dart:io';

import 'app_config.dart';

class AppConfigIos implements IAppConfig {
  static final _regValue = RegExp(
    r'(?<leftSpace>\s*)'
    r'(?<begin><key>GADApplicationIdentifier<\/key>(?:\s)*<string>)'
    r'(?<id>.*)'
    r'(?<end><\/string>)',
  );

  static final _regLocation = RegExp(r'(?=\s*<\/dict>(\s)*<\/plist>\s*$)');

  @override
  final String path;
  late String text;

  AppConfigIos._(this.path);

  _load() async {
    var file = File(path);
    text = await file.readAsString();
  }

  static Future<AppConfigIos> load(
      [String path = "ios/Runner/Info.plist"]) async {
    var plist = AppConfigIos._(path);
    await plist._load();
    return plist;
  }

  @override
  Future<void> save() {
    return File(path).writeAsString(text);
  }

  @override
  String? get applicationID {
    var match = _regValue.firstMatch(text);
    return match?.namedGroup('id');
  }

  String _xmlOf(String? id) {
    return ('\n\n    <key>GADApplicationIdentifier</key>\n'
        '    <string>$id</string>');
  }

  @override
  set applicationID(String? newId) {
    var id = applicationID;
    if (id != newId) {
      if (id == null) {
        // add
        text = text.replaceFirst(_regLocation, _xmlOf(newId));
      } else {
        if (newId == null) {
          // delete
          text = text.replaceFirst(_regValue, "");
        } else {
          // change
          text = text.replaceFirstMapped(_regValue, (m) {
            return '${m[1]}${m[2]}$newId${m[4]}';
          });
        }
      }
    }
  }
}
