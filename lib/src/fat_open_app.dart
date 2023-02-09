import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:json5/json5.dart';

class FatOpenApp with ChangeNotifier {
  FatOpenApp({
    this.hideApplication = false,
    this.iosUnitId = testIosUnitId,
    this.androidUnitId = testAndroidUnitId,
    this.immersiveModeEnabled,
    this.loadingTimeout = const Duration(seconds: 5),
    this.loadingPage,
  });

  static const testAndroidUnitId = 'ca-app-pub-3940256099942544/3419835294';
  static const testIosUnitId = 'ca-app-pub-3940256099942544/5662855259';
  static const testAppId = 'ca-app-pub-3940256099942544~3347511713';

  final bool hideApplication;
  final String iosUnitId;
  final String androidUnitId;
  final bool? immersiveModeEnabled;
  final Duration loadingTimeout;
  final Widget Function(BuildContext context, int percent)? loadingPage;

  int? _percent = 0;
  int? get percent => _percent;
  void _setPercent(int? percent) {
    _percent = percent;
    notifyListeners();
  }

  String _state = 'none';
  String get state => _state;
  List<String> _logs = <String>[];
  List<String> get logs => _logs;

  void setState(String state) {
    _state = state;
    notifyListeners();
  }

  void log(String msg) {
    var time = DateTime.now();
    msg = '${time.second}${time.millisecond.toString().padLeft(3, '-')} | $msg';
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

  @override
  String toString() {
    final o = {
      'adUnitId': adUnitId,
    };
    return JSON5.stringify(o, space: 5);
  }

  Future<InitializationStatus> initialize() async {
    log('initializing');
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    if (hideApplication) {
      log("preserve native spash");
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    }
    final ret = await MobileAds.instance.initialize();
    log('initialized $ret');
    return ret;
  }

  AppOpenAd? openAd; // TODO: _openAd
  Future<void> loadAd() async {
    _setPercent(0);

    log('loadAd()');
    if (openAd != null) {
      log('loadAd() error, already loaded');
      return;
    }

    final loadCompleter = Completer();

    var count = loadingTimeout;
    const step = Duration(milliseconds: 200);
    final timer = Timer.periodic(step, (final timer) {
      if (loadingTimeout != Duration.zero) {
        _setPercent(100 -
            (count.inMilliseconds * 100 ~/ loadingTimeout.inMilliseconds));
      }
      count = count - step;
      if (count <= Duration.zero) {
        log('loadAd() error, timeout');
        timer.cancel();
        loadCompleter.complete();
      }
    });

    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait, // TODO
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

  Future<void> showAd() async {
    await _showAd();
    if (hideApplication) {
      log("remove native spash");
      FlutterNativeSplash.remove();
    }
  }

  // request | show | hide
  Future<void> _showAd() async {
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
    return showCompleter.future;
  }

  void showMenu() {
    // TODO: exception if not initalized
    MobileAds.instance.openDebugMenu(adUnitId);
  }
}
