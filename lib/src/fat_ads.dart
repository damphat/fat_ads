import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fat_open_app.dart';

class FatAds extends StatefulWidget {
  FatAds({
    super.key,
    required this.child,
    FatOpenApp? openApp,
  }) : openApp = openApp ?? FatOpenApp();

  final Widget child;
  final FatOpenApp openApp;

  @override
  State<FatAds> createState() => _FatAdsState();
}

class _FatAdsState extends State<FatAds> {
  late FatOpenApp openApp;
  var loading = true;
  @override
  void initState() {
    super.initState();
    openApp = widget.openApp;
    init();
  }

  Future<void> init() async {
    setState(() {
      loading = true;
    });
    await openApp.initialize();
    await openApp.loadAd();

    await openApp.showAd();

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildLoading(BuildContext context, int percent) {
    return MaterialApp(
      home: openApp.loadingPage!(context, percent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.openApp,
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
