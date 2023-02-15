import 'package:fat_ads/fat_ads.dart';
import 'package:flutter/material.dart';

void main() async {
  appOpenAds(
    loadingTimeout: Duration(seconds: 5),
  );

  runApp(MyApp());
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
