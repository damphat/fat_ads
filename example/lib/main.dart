import 'package:fat_ads/fat_ads.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    FatOpenAdProvider(
      fatOpenAd: FatOpenAd(
        timeout: const Duration(seconds: 5),
        loadingPage: (context, percent) {
          return Scaffold(
            body: Center(
              child: Text("Loading $percent %!"),
            ),
          );
        },
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fat Ads'),
        ),
        body: const FatOpenAdDebugger(
          child: Center(
            child: Text('Did you see the App Open Ad popup?'),
          ),
        ),
      ),
    );
  }
}
