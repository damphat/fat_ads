import 'package:fat_ads/fat_ads.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    FatOpenAdProvider(
      fatOpenAd: FatOpenAd(
        timeout: const Duration(minutes: 2),
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
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const FatOpenAdDebugger(
          child: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
