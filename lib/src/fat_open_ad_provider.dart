// ignore_for_file: public_member_api_docs, prefer_final_parameters, prefer_expression_function_bodies

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
              context.select<FatOpenAd, int?>((value) => value.percent);
          final ad = context.read<FatOpenAd>();
          if (!loading || ad.loadingPage == null) {
            return widget.child;
          }

          return buildLoading(context, percent ?? 0);
        },
      ),
    );
  }
}
