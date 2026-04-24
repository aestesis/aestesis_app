import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../core/native.view.dart';
import '../ui/icon.dart';
import '../controls/asset.view.dart';
import '../controls/control.color.dart';
import '../controls/control.knob.dart';
import '../controls/control.menu.dart';
import '../ui/menu.dart';
import '../ui/sliver.grid.delegate.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class AnalogModule extends StatefulWidget {
  final String moduleId;
  const AnalogModule({super.key, required this.moduleId});
  @override
  State<AnalogModule> createState() => _AnalogModuleState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AnalogModuleState extends State<AnalogModule> {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final blur = module[AnalogControl.blur.id];
    final zoom = module[AnalogControl.zoom.id];
    final hue = module[AnalogControl.hue.id];
    final saturation = module[AnalogControl.saturation.id];
    final brightness = module[AnalogControl.brightness.id];
    final white = module[AnalogControl.white.id];
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Expanded(
              child: Column(children: [
            const SizedBox(height: 20, child: Row(children: [])),
            const SizedBox(height: 5),
            Expanded(
                child: Scrollbar(
                    controller: scrollController,
                    child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverGrid.builder(
                              itemCount: assets.length,
                              gridDelegate:
                                  SliverGridDelegateWithMinMaxCrossAxisExtent(
                                      maxCrossAxisCount: assets.length,
                                      minCrossAxisExtent: 160,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 190),
                              itemBuilder: (_, i) => AnalogInput(
                                  key: Key(
                                      "analog.${module.id}.input.${assets[i].id}"),
                                  moduleId: module.id,
                                  asset: assets[i])),
                          const SliverToBoxAdapter(child: SizedBox(height: 10))
                        ])))
          ])),
          const SizedBox(width: 5),
          Container(width: 0.5, color: ColorScheme.of(context).inversePrimary),
          const SizedBox(width: 10),
          SizedBox(
              width: 338,
              child: Column(children: [
                SizedBox(
                    height: 20,
                    child: Row(children: [
                      Text(module.name, style: TextTheme.of(context).bodySmall)
                    ])),
                const SizedBox(height: 5),
                ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: NativeView(
                                moduleId: widget.moduleId,
                                assetId: widget.moduleId)))),
                const SizedBox(height: 5),
                Expanded(
                    child: Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                  ControlKnob(control: zoom),
                  const SizedBox(width: 10),
                  ControlKnob(control: blur),
                  const SizedBox(width: 40),
                  ControlKnob(control: hue),
                  const SizedBox(width: 10),
                  ControlKnob(control: saturation),
                  const SizedBox(width: 10),
                  ControlKnob(control: brightness),
                  const SizedBox(width: 40),
                  ControlKnob(control: white),
                ])))
              ])),
          const SizedBox(width: 5),
        ]));
  }

  Module get module => aes.composition![widget.moduleId];
  List<Asset> get assets => [...module.assets?.whereType<Asset>() ?? []];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class AnalogInput extends StatefulWidget {
  final String moduleId;
  final Asset asset;
  const AnalogInput({super.key, required this.asset, required this.moduleId});
  @override
  State<AnalogInput> createState() => _AnalogInputState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AnalogInputState extends State<AnalogInput> {
  late final StreamSubscription controlSubscription;
  @override
  initState() {
    super.initState();
    final color = module[AnalogSourceControl.color.id(widget.asset.id)];
    controlSubscription = color.listen((control) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controlSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blend = module[AnalogSourceControl.blendMode.id(widget.asset.id)];
    final opacity = module[AnalogSourceControl.opacity.id(widget.asset.id)];
    final gain = module[AnalogSourceControl.gain.id(widget.asset.id)];
    final color = module[AnalogSourceControl.color.id(widget.asset.id)];
    return Center(
        child: Container(
            width: 160,
            height: 190,
            decoration: BoxDecoration(
                border: Border.all(
                    color: ColorScheme.of(context).inversePrimary, width: 0.5),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AssetView(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      live: true,
                      color: color.color,
                      moduleId: widget.moduleId,
                      asset: widget.asset),
                  const SizedBox(height: 5),
                  Expanded(
                      child: Stack(children: [
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: ControlMenu(
                                itemWidth: 86,
                                size: UISize.small,
                                control: blend,
                                items: blendItems))),
                    Positioned.fill(
                        top: 14,
                        child: Center(
                            child: ControlKnob(
                                control: opacity, size: UISize.large))),
                    Positioned(
                        right: 17.5,
                        bottom: 8,
                        child:
                            ControlColor(control: color, size: UISize.medium)),
                    Positioned(
                        right: 11,
                        top: 16,
                        child: ControlKnob(control: gain, size: UISize.medium)),
                  ])),
                ])));
  }

  Module get module => aes.composition![widget.moduleId];

  final blendItems = [
    for (final blendMode in ControlBlendMode.values)
      UIMenuItem<double>(
        value: blendMode.index.toDouble(),
        // TODO: icon: blendMode.icon,
        text: blendMode.name,
      )
  ];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
