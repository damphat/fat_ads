import 'dart:io';

import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

import 'app_config.dart';

const _androidNs = 'http://schemas.android.com/apk/res/android';

class AppConfigAndroid implements IAppConfig {
  @override
  final String path;
  XmlDocument? _document;
  // ignore: unused_field
  XmlElement? _manifest;
  XmlElement? _application;
  XmlElement? _ad;
  AppConfigAndroid._(this.path);

  Future<void> _load() async {
    var file = File(path);
    if (await file.exists() == false) return;
    var str = await file.readAsString();
    var d = _document = XmlDocument.parse(str);
    var m = _manifest = d.getElement('manifest');
    if (m == null) return;
    var a = _application = m.getElement('application');
    if (a == null) return;
    var ads = a.childElements
        .where((e) =>
            e.name.qualified == 'meta-data' &&
            e.attributes.firstWhereOrNull((a) =>
                    a.qualifiedName == 'android:name' &&
                    a.value == 'com.google.android.gms.ads.APPLICATION_ID') !=
                null)
        .toList();
    if (ads.length > 1) {
      throw Exception('Multiple APPLICATION ID');
    } else if (ads.length == 1) {
      _ad = ads[0];
    } else {
      // There no APPLICATION ID
      _ad = null;
    }
  }

  static Future<AppConfigAndroid> load([
    String path = "android/app/src/main/AndroidManifest.xml",
  ]) async {
    var ret = AppConfigAndroid._(path);
    await ret._load();
    return ret;
  }

  @override
  Future<void> save() async {
    var document = _document!;
    var file = File(path);
    await file.writeAsString(document.toXmlString(
      pretty: false,
      preserveWhitespace: (e) {
        return true;
      },
      indentAttribute: (value) => true,
    ));
  }

  @override
  String? get applicationID {
    return _ad?.getAttribute('value', namespace: _androidNs);
  }

  @override
  set applicationID(String? newId) {
    var application = _application!;
    var id = applicationID;
    if (id != newId) {
      if (newId != null) {
        if (id != null) {
          // change
          var ad = _ad!;
          var metaValue = ad.attributes
              .firstWhere((a) => a.qualifiedName == 'android:value');
          metaValue.value = newId;
        } else {
          // add
          application.children.addAll([
            XmlElement(
              XmlName('meta-data'),
              [
                XmlAttribute(XmlName('name', 'android'),
                    "com.google.android.gms.ads.APPLICATION_ID"),
                XmlAttribute(XmlName('value', 'android'), newId),
              ],
            ),
            XmlText('\n\n')
          ]);
        }
      } else {
        _ad?.parent?.children.remove(_ad);
        _ad = null;
      }
    }
  }
}
