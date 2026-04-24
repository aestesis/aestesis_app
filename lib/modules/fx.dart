import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb.flutter/bb.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../controls/asset.view.dart';
import '../controls/control.knob.dart';
import '../core/native.view.dart';
import '../ui/button.dart';
import '../ui/icon.dart';
import '../ui/sliver.grid.delegate.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class FxModule extends StatefulWidget {
  final String moduleId;
  const FxModule({super.key, required this.moduleId});
  @override
  State<FxModule> createState() => _FxModuleState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _FxModuleState extends State<FxModule> {
  final scrollController = ScrollController();
  late final StreamSubscription assetChangedSubscription;
  @override
  void initState() {
    super.initState();
    assetChangedSubscription = module[FxControl.asset.id].listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    assetChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfx = module[FxControl.asset.id];
    final clevel = module[FxControl.level.id];
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Expanded(
              child: Column(children: [
            SizedBox(
                height: 20,
                child: Row(children: [
                  const Spacer(),
                  if (kDebugMode)
                    UIIconButton(
                        asset: UIIcon.filesSave,
                        tooltip: 'Save Previews',
                        onTap: () async {
                          savePreviews();
                        })
                ])),
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
                                      mainAxisExtent: 90),
                              itemBuilder: (_, i) => AssetView(
                                    key: Key('${module.id}.${assets[i].id}'),
                                    moduleId: module.id,
                                    asset: assets[i],
                                    selected: cfx.value.toInt() == i,
                                    onTap: () {
                                      if (cfx.value.toInt() != i) {
                                        cfx.value = i.toDouble();
                                        cfx.change(
                                            source: ControlChangeSource.ui);
                                      }
                                    },
                                  )),
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
                  ControlKnob(control: clevel),
                ])))
              ])),
          const SizedBox(width: 5)
        ]));
  }

  void savePreviews() async {
    const folder = '/Users/renanyoy/Desktop/previews';
    for (final asset in assets) {
      final key = "${widget.moduleId}.${asset.id}";
      final image = aes.previews[key];
      if (image == null) {
        Debug.info('no preview for $key');
        continue;
      }
      final uiImage = await BB.loadImage(image.image);
      final bytes = await uiImage.toByteData(format: ImageByteFormat.png);
      final file = File('$folder/${asset.id}.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    }
  }

  Module get module => aes.composition![widget.moduleId];
  List<Asset> get assets => (module.assets?.whereType<Asset>() ?? []).toList();
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
