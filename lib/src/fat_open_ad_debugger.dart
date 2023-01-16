import 'package:fat_ads/fat_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FatOpenAdDebugger extends StatefulWidget {
  final Widget child;
  const FatOpenAdDebugger({
    super.key,
    required this.child,
  });

  @override
  State<FatOpenAdDebugger> createState() => _FatOpenAdDebuggerState();
}

class _FatOpenAdDebuggerState extends State<FatOpenAdDebugger> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return widget.child;
    }
    var ad = context.watch<FatOpenAd>();
    var log = ad.logs.map((e) => Text(e));
    var debug = !_showDebug
        ? InkWell(
            onTap: () => setState(() => _showDebug = !_showDebug),
            child: const Icon(
              Icons.info,
              color: Colors.yellow,
            ),
          )
        : Container(
            margin: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.yellow.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // titlebar = (title + close)
                Container(
                  color: Colors.black.withAlpha(40),
                  child: Row(
                    children: [
                      // title
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: const Text('Ads Debugger'),
                        ),
                      ),
                      // close
                      IconButton(
                          onPressed: () =>
                              setState(() => _showDebug = !_showDebug),
                          icon: const Icon(
                            Icons.close,
                          )),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => context.read<FatOpenAd>().loadAd(),
                      child: const Text('load'),
                    ),
                    TextButton(
                      onPressed: () => context.read<FatOpenAd>().showAd(),
                      child: const Text('show'),
                    ),
                    TextButton(
                      onPressed: () => context.read<FatOpenAd>().clearLogs(),
                      child: const Text('clear'),
                    ),
                    TextButton(
                      onPressed: () => context.read<FatOpenAd>().showMenu(),
                      child: const Icon(Icons.menu),
                    ),
                  ],
                ),
                // body
                Expanded(
                  child: ListView(
                    children: log.toList(),
                  ),
                )
              ],
            ),
          );
    return Stack(
      children: [
        debug,
        widget.child,
      ],
    );
  }
}
