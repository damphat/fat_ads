import 'package:fat_ads/fat_ads.dart';
import 'package:flutter/material.dart';

// Note: app will crash if you forgot to add AdMob App ID to AndroidManifest.xml | Info.plist

void main() async {
  appOpenAds(
    // androidUnitId: "ca-app-pub-3940256099942544/3419835294",
    loadingTimeout: const Duration(seconds: 5),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fat Ads'),
        ),
        body: const FatDebug(
          child: Center(child: Text('Did you see the App Open Ad popup?')),
        ),
      ),
    );
  }
}
