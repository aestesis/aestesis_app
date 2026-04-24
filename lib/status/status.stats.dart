import 'dart:async';
import 'dart:math';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusStats extends StatefulWidget {
  const StatusStats({super.key});
  @override
  State<StatusStats> createState() => _StatusBarState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusBarState extends State<StatusStats> {
  late final StreamSubscription statisticsSubscription;
  CompositionStatistics? get statistics => aes.statistics;
  CompositionSettings? get settings => aes.compositionSettings;
  @override
  void initState() {
    super.initState();
    statisticsSubscription =
        aes.bus.on<StatisticsUpdateEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    statisticsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorScheme.of(context).onSurface.withValues(alpha:0.6);
    final tt =
        TextTheme.of(context).bodySmall!.apply(color: color.withValues(alpha:0.8));
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (statistics != null) ...[
        SizedBox(
            width: 50,
            child: Row(children: [
              Icon(Icons.wind_power, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(
                      min(statistics!.fps, aes.compositionSettings!.fps)
                          .toStringAsFixed(0),
                      style: tt))
            ])),
        const SizedBox(width: 10),
        SizedBox(
            width: 60,
            child: Row(children: [
              Icon(Icons.directions_run, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                  child:
                      Text('${statistics!.cpu.toStringAsFixed(1)}%', style: tt))
            ])),
        const SizedBox(width: 10),
        SizedBox(
            width: 90,
            child: Row(children: [
              Icon(Icons.memory, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                  child: Text('${statistics!.ram.toStringAsFixed(1)}Mb',
                      style: tt))
            ])),
      ]
    ]);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
