import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:json5/json5.dart';
import 'package:intl/intl.dart';

class FatOpenAd with ChangeNotifier {
  static const testAndroidUnitId = 'ca-app-pub-3940256099942544/3419835294';
  static const testIosUnitId = 'ca-app-pub-3940256099942544/5662855259';
  static const testAppId = 'ca-app-pub-3940256099942544~3347511713';

  final String iosUnitId;
  final String androidUnitId;
  final bool? immersiveModeEnabled;
  final Duration timeout;
  String _state = "none";
  String get state => _state;
  List<String> _logs = <String>[];
  List<String> get logs => _logs;

  void setState(String state) {
    _state = state;
    notifyListeners();
  }

  void log(String msg) {
    var time = DateFormat.Hms().format(DateTime.now());
    msg = "$time | $msg";
    _logs = [..._logs, msg];
    notifyListeners();
  }

  void clearLogs() {
    _logs = [];
    notifyListeners();
  }

  String get adUnitId {
    if (kReleaseMode) {
      return Platform.isAndroid ? androidUnitId : iosUnitId;
    } else {
      return Platform.isAndroid ? testAndroidUnitId : testIosUnitId;
    }
  }

  FatOpenAd({
    this.iosUnitId = testIosUnitId,
    this.androidUnitId = testAndroidUnitId,
    this.immersiveModeEnabled,
    this.timeout = const Duration(seconds: 5),
  });

  @override
  String toString() {
    var o = {
      'adUnitId': adUnitId,
    };
    return JSON5.stringify(o, space: 5);
  }

  Future<InitializationStatus> initialize() async {
    log('initializing');
    WidgetsFlutterBinding.ensureInitialized();
    var ret = await MobileAds.instance.initialize();
    log('initialized $ret');
    return ret;
  }

  AppOpenAd? openAd;
  Future<void> loadAd() async {
    log('loadAd()');
    if (openAd != null) {
      log('loadAd() error, already loaded');
      return;
    }

    var loadCompleter = Completer();

    var timer = Timer(timeout, () {
      log('loadAd() error, timeout');
      loadCompleter.complete();
    });

    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('loadAd() success');
          timer.cancel();
          openAd = ad;
          // complete twice
          loadCompleter.complete();
        },
        onAdFailedToLoad: (error) {
          log('loadAd() error, $error');
          timer.cancel();
          // complete twice
          // should not send the error
          loadCompleter.complete();
        },
      ),
    );
    return loadCompleter.future;
  }

  // request | show | hide
  Future<void> showAd() async {
    log('showAd()');
    if (openAd == null) {
      if (openAd == null) {
        log('showAd() error, no ad loaded');
        return;
      }
    }

    Completer showCompleter = Completer();
    log('showAd() request to show()');

    if (immersiveModeEnabled != null) {
      openAd!.setImmersiveMode(immersiveModeEnabled!);
    }

    openAd!.show();

    openAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('showAd() showing');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('showAd() can not show $error');
        ad.dispose();
        openAd = null;
        showCompleter.complete();
      },
      onAdDismissedFullScreenContent: (ad) {
        log('showAd() dismissed');
        ad.dispose();
        openAd = null;
        loadAd();
        showCompleter.complete();
      },
    );
  }

  void showMenu() {
    // TODO: exception if not initalized
    MobileAds.instance.openDebugMenu(adUnitId);
  }
}
