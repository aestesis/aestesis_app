import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../controls/asset.view.dart';
import '../core/native.view.dart';
import '../ui/icon.dart';
import '../ui/menu.button.dart';
import '../ui/menu.context.dart';
import '../ui/menu.dart';
import '../ui/sliver.grid.delegate.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class CameraModule extends StatefulWidget {
  final String moduleId;
  const CameraModule({super.key, required this.moduleId});
  @override
  State<CameraModule> createState() => _CameraModuleState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _CameraModuleState extends State<CameraModule> {
  final scrollController = ScrollController();
  late final StreamSubscription assetChangedSubscription;
  List<CameraDevice> devices = [];
  @override
  void initState() {
    super.initState();
    discoverCameras();
    assetChangedSubscription = module[CameraControl.asset.id].listen((_) {
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
    final control = module[CameraControl.asset.id];
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Row(children: [
          Expanded(
              child: Column(children: [
            SizedBox(
                height: 20,
                child: Row(children: [
                  const Spacer(),
                  UIMenuIconButton(
                    tooltip: 'Add camera input',
                    asset: UIIcon.add, menu: [
                    ...devices
                        .where((d) =>
                            assets.firstWhereOrNull((a) => a.id == d.id) ==
                            null)
                        .map((device) => UIMenuItem(
                            text: device.name,
                            icon: device.icon,
                            onTap: () {
                              aes.bus.fire(AddAssetsEvent(
                                  module: module, assets: [device.toAsset()]));
                            }))
                  ])
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
                              itemBuilder: (_, i) => UIContextMenu(
                                      menu: [
                                          UIMenuItem(
                                              text: 'Remove camera input',
                                              icon: UIIcon.delete,
                                              color: Colors.redAccent,
                                              onTap: () {
                                                aes.bus.fire(RemoveAssetsEvent(
                                                    module: module,
                                                    assets: [assets[i]]));
                                              })
                                      ],
                                      child: AssetView(
                                        key:
                                            Key('${module.id}.${assets[i].id}'),
                                        moduleId: module.id,
                                        asset: assets[i],
                                        selected: control.value.toInt() == i,
                                        live: true,
                                        onTap: () {
                                          Debug.info('tap ${assets[i].id}');
                                          if (control.value.toInt() != i) {
                                            control.value = i.toDouble();
                                            control.change(
                                                source: ControlChangeSource.ui);
                                          }
                                        },
                                      )))
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
                const Expanded(
                    child: Center(
                        child:
                            Row(mainAxisSize: MainAxisSize.min, children: [])))
              ])),
          const SizedBox(width: 5)
        ]));
  }

  Future<void> discoverCameras() async {
    devices = [...(await aes.alib.cameraDevices()).whereType<CameraDevice>()];
    for (final device in devices) {
      Debug.info(device.description);
    }
    setState(() {});
  }

  Module get module => aes.composition![widget.moduleId];
  List<Asset> get assets => (module.assets?.whereType<Asset>() ?? []).toList();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
extension CameraDeviceExtension on CameraDevice {
  UIIcon get icon {
    switch (position) {
      case CameraPosition.undefined:
        switch (type) {
          case CameraType.builtin:
            return UIIcon.cameraBuiltin;
          case CameraType.external:
            return UIIcon.cameraExternal;
          case CameraType.continuity:
            return UIIcon.cameraContinuity;
          case CameraType.deskview:
            return UIIcon.cameraDeskview;
          case CameraType.undefined:
            return UIIcon.moduleCamera;
        }
      case CameraPosition.front:
        return UIIcon.cameraFront;
      case CameraPosition.back:
        return UIIcon.cameraBack;
      case CameraPosition.virtual:
        return UIIcon.cameraVirtual;
    }
  }

  String get description => '$name ($manufacturer, $model, $position, $type)';
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
