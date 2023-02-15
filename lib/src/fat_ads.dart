import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'fat_open.dart';

class FatAds extends StatefulWidget {
  FatAds({
    super.key,
    required this.child,
    FatOpen? open,
  }) : open = Platform.isAndroid || Platform.isIOS ? open : null;

  final Widget child;
  final FatOpen? open;

  @override
  State<FatAds> createState() => _FatAdsState();
}

class _FatAdsState extends State<FatAds> {
  var loading = true;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.open != null) {
      widget.open!.initialize();
      widget.open!.loadAd();
      await widget.open!.loading;
      widget.open!.showAdIfAvailable();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    AppStateEventNotifier.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var child = loading
        ? const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            ),
          )
        : widget.child;

    return ChangeNotifierProvider.value(
      value: widget.open,
      child: child,
    );
  }
}
