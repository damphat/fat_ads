import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FatOpen with ChangeNotifier {
  FatOpen({
    this.keepSplash = false,
    this.appId = testAppId,
    this.iosUnitId = testIosUnitId,
    this.androidUnitId = testAndroidUnitId,
    this.loadingTimeout = const Duration(seconds: 3),
  });

  static const testAndroidUnitId = 'ca-app-pub-3940256099942544/3419835294';
  static const testIosUnitId = 'ca-app-pub-3940256099942544/5662855259';
  static const testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const Duration maxCacheDuration = Duration(hours: 4);

  final bool keepSplash;
  final String appId;
  final String iosUnitId;
  final String androidUnitId;
  final Duration loadingTimeout;

  List<String> _logs = <String>[];
  List<String> get logs => _logs;

  AppOpenAd? _appOpenAd;
  bool _showing = false;
  DateTime? _appOpenLoadTime;
  final Completer _completer = Completer();
  Timer? _timer;
  Future<void> get loading => _completer.future;

  void log(String msg) {
    var time = DateTime.now();
    msg = '${time.second}${time.millisecond.toString().padLeft(3, '-')} | $msg';
    debugPrint('LOG: $msg');
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

  bool _initialized = false;
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    log('initialize');
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();

    if (keepSplash) {
      log("preserve native spash");
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    }

    _timer = Timer(loadingTimeout, () {
      log(" endWait because timeout $loadingTimeout");
      _endLoading();
    });

    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) {
      if (state == AppState.foreground) {
        log('foreground');
        showAdIfAvailable();
      }
    });
  }

  var _loadAd = false;
  void loadAd() {
    if (_loadAd || _appOpenAd != null) return;
    _loadAd = true;
    log('AppOpenAd.load()');
    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('event load: onAdLoaded: $ad');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          _loadAd = false;
          log(" endWait because ad is loaded");
          _endLoading();
        },
        onAdFailedToLoad: (error) {
          log('event load: onAdFailedToLoad $error');
          _loadAd = false;
          log(" endWait because ad is failed to load");
          _endLoading();
        },
      ),
    );
  }

  void _endLoading() {
    if (!_completer.isCompleted) {
      _completer.complete();

      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
      if (keepSplash) {
        FlutterNativeSplash.remove();
      }
    }
  }

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  bool showAdIfAvailable() {
    log('showAdIfAvailable()');
    if (!isAdAvailable) {
      log('  no ad available => loadAd()');
      loadAd();
      return false;
    }

    if (_showing) {
      log('  ad is showing => not show again');
      return false;
    }

    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      log('  ad expired => dispose and load new ad');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return false;
    }

    // a valid ad is available
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('  event show:onAdShowedFullScreenContent');
        _showing = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('  event show:onAdFailedToShowFullScreenContent');
        _showing = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        log('  event show:onAdDismissedFullScreenContent');
        _showing = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    log('ad available => show()');
    _appOpenAd!.show();
    return true;
  }
}

Future<void> appOpenAds({
  String appId = FatOpen.testAppId,
  String iosUnitId = FatOpen.testIosUnitId,
  String androidUnitId = FatOpen.testAndroidUnitId,
  Duration loadingTimeout = const Duration(seconds: 3),
}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    var open = FatOpen(
      appId: appId,
      iosUnitId: iosUnitId,
      androidUnitId: androidUnitId,
      loadingTimeout: loadingTimeout,
    );
    open.initialize();
    open.loadAd();
    await open.loading;
    if (open.showAdIfAvailable()) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
