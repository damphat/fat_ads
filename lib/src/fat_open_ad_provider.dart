import 'package:provider/provider.dart';

import 'fat_open_ad.dart';
import 'package:flutter/material.dart';

class FatOpenAdProvider extends StatefulWidget {
  final Widget child;
  final FatOpenAd fatOpenAd;
  FatOpenAdProvider({
    super.key,
    required this.child,
    FatOpenAd? fatOpenAd,
  }) : fatOpenAd = fatOpenAd ?? FatOpenAd();

  @override
  State<FatOpenAdProvider> createState() => _FatOpenAdProviderState();
}

class _FatOpenAdProviderState extends State<FatOpenAdProvider> {
  late FatOpenAd ad;
  @override
  void initState() {
    super.initState();
    ad = widget.fatOpenAd;
    init();
  }

  void init() async {
    await ad.initialize();
    await ad.loadAd();
    await ad.showAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.fatOpenAd,
      child: widget.child,
    );
  }
}
