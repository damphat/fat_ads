import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fat_open.dart';

class FatAds extends StatefulWidget {
  FatAds({
    super.key,
    required this.child,
    FatOpen? open,
  }) : open = open ?? FatOpen();

  final Widget child;
  final FatOpen open;

  @override
  State<FatAds> createState() => _FatAdsState();
}

class _FatAdsState extends State<FatAds> {
  late FatOpen openApp;
  var loading = true;
  @override
  void initState() {
    super.initState();
    openApp = widget.open;
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
      home: openApp.loadingBuilder!(context, percent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.open,
      child: Builder(
        builder: (context) {
          final percent =
              context.select<FatOpen, int?>((value) => value.percent);
          final ad = context.read<FatOpen>();
          if (!loading || ad.loadingBuilder == null) {
            return widget.child;
          }

          return buildLoading(context, percent ?? 0);
        },
      ),
    );
  }
}
