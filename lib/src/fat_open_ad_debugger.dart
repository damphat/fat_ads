// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fat_ads.dart';

class FatOpenAdDebugger extends StatefulWidget {
  const FatOpenAdDebugger({
    super.key,
    required this.child,
  });
  final Widget child;

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
    final ad = context.watch<FatOpenAd>();
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
