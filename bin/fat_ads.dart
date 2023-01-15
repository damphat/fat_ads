// ignore_for_file: avoid_print

import 'dart:io';

import 'src/app_config.dart';
import 'src/app_config_android.dart';
import 'src/app_config_ios.dart';

const testAppId = 'ca-app-pub-3940256099942544~3347511713';
final appIdReg = RegExp(r'ca-app-pub-\d+~\d+');

void update(IAppConfig config) {
  var id = config.applicationID;
  id ??= testAppId;

  if (!appIdReg.hasMatch(id)) {
    id = testAppId;
  }

  print('Change your application ID ($id):');
  var newId = stdin.readLineSync() ?? "";
  newId = newId.trim();
  if (newId.isNotEmpty) {
    if (!appIdReg.hasMatch(newId)) {
      throw Exception('$newId is not a valid application id');
    } else {
      id = newId;
    }
  }
  config.applicationID = id;
  config.save();
}

Future<void> processAndroid() async {
  var config = await AppConfigAndroid.load();
  print('===== ${config.path} =====');
  if (config.applicationID == null) {
    print([
      '    ERROR: missing com.google.android.gms.ads.APPLICATION_ID',
      '',
      '    <meta-data',
      '        android:name="com.google.android.gms.ads.APPLICATION_ID"',
      '        android:value="ca-app-pub-3940256099942544~3347511713">',
      '',
    ].join('\n'));
  } else if (config.applicationID == testAppId) {
    print([
      '    WARN: you are using a test application ID',
      '',
      '    <meta-data',
      '        android:name="com.google.android.gms.ads.APPLICATION_ID"',
      '        android:value="ca-app-pub-3940256099942544~3347511713">',
      '',
    ].join('\n'));
  } else {
    print([
      '    INFO: look good',
      '',
      '    <meta-data',
      '        android:name="com.google.android.gms.ads.APPLICATION_ID"',
      '        android:value="${config.applicationID}">',
      '',
    ].join('\n'));
  }
  update(config);
}

Future<void> processIos() async {
  var config = await AppConfigIos.load();
  print('===== ${config.path} =====');
  if (config.applicationID == null) {
    print([
      '    ERROR: missing application ID ',
      '',
      '    <key>GADApplicationIdentifier</key>',
      '    <string>ca-app-pub-3940256099942544~3347511713</string>',
      '',
    ].join('\n'));
  } else if (config.applicationID == testAppId) {
    print([
      '    WARN: you are using a test application ID',
      '',
      '    <key>GADApplicationIdentifier</key>',
      '    <string>ca-app-pub-3940256099942544~3347511713</string>',
      '',
    ].join('\n'));
  } else {
    print([
      '    INFO: look good',
      '',
      '    <key>GADApplicationIdentifier</key>',
      '    <string>${config.applicationID}</string>',
      '',
    ].join('\n'));
  }
  update(config);
}

void main() async {
  await processAndroid();
  await processIos();
}
