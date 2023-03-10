import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fat_ads.dart';

class FatDebug extends StatefulWidget {
  const FatDebug({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<FatDebug> createState() => _FatDebugState();
}

class _FatDebugState extends State<FatDebug> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    if (kReleaseMode) {
      return widget.child;
    }
    final ad = context.watch<FatOpen?>();
    if (ad == null) {
      return widget.child;
    }
    final log = ad.logs.map(Text.new);
    final debug = !_showDebug
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
                      onPressed: () => context.read<FatOpen>().loadAd(),
                      child: const Text('load'),
                    ),
                    TextButton(
                      onPressed: () => context.read<FatOpen>().clearLogs(),
                      child: const Text('clear'),
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
        widget.child,
        debug,
      ],
    );
  }
}
