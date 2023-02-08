// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fat_open_ad.dart';

class FatOpenAdProvider extends StatefulWidget {
  FatOpenAdProvider({
    super.key,
    required this.child,
    FatOpenAd? fatOpenAd,
  }) : fatOpenAd = fatOpenAd ?? FatOpenAd();

  final Widget child;
  final FatOpenAd fatOpenAd;

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

  Future<void> init() async {
    await ad.initialize();
    await ad.loadAd();
    await ad.showAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: widget.fatOpenAd,
        child: widget.child,
      );
}
