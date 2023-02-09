import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fat_open_app.dart';

class FatAds extends StatefulWidget {
  FatAds({
    super.key,
    required this.child,
    FatOpenApp? openApp,
  }) : fatOpenAd = openApp ?? FatOpenApp();

  final Widget child;
  final FatOpenApp fatOpenAd;

  @override
  State<FatAds> createState() => _FatAdsState();
}

class _FatAdsState extends State<FatAds> {
  late FatOpenApp ad;
  var loading = true;
  @override
  void initState() {
    super.initState();
    ad = widget.fatOpenAd;
    init();
  }

  Future<void> init() async {
    await ad.initialize();
    await ad.loadAd();

    setState(() {
      loading = false;
    });
    await ad.showAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildLoading(BuildContext context, int percent) {
    return MaterialApp(
      home: ad.loadingPage!(context, percent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.fatOpenAd,
      child: Builder(
        builder: (context) {
          final percent =
              context.select<FatOpenApp, int?>((value) => value.percent);
          final ad = context.read<FatOpenApp>();
          if (!loading || ad.loadingPage == null) {
            return widget.child;
          }

          return buildLoading(context, percent ?? 0);
        },
      ),
    );
  }
}
