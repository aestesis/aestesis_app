import 'dart:async';
import 'dart:io';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:open_file_macos/open_file_macos.dart';
import 'package:path/path.dart' as path;

import '../aestesis.dart';
import '../core/native.view.dart';
import '../ui/button.dart';
import '../ui/icon.dart';
import '../controls/asset.view.dart';
import '../ui/menu.context.dart';
import '../ui/menu.dart';
import '../ui/sliver.grid.delegate.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class PlayerModule extends StatefulWidget {
  final String moduleId;
  final BoolCallback? onSelected;
  const PlayerModule({super.key, required this.moduleId, this.onSelected});
  @override
  State<PlayerModule> createState() => _PlayerModuleState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _PlayerModuleState extends State<PlayerModule> {
  static const fileFormats = ['mv4', '3gp', '3g2', 'mp4', 'mov'];
  late final StreamSubscription assetChangedSubscription;
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    assetChangedSubscription = module[PlayerControl.asset.id].listen((_) {
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
    final assetControl = module[PlayerControl.asset.id];
    final positionControl = module[PlayerControl.position.id];
    return UIContextMenu(
        menu: [
          if (assets.isNotEmpty)
            UIMenuItem(
                text: 'Remove all videos',
                icon: UIIcon.delete,
                color: Colors.redAccent,
                onTap: () {
                  aes.bus.fire(
                      RemoveAssetsEvent(module: module, assets: [...assets]));
                })
        ],
        child: DropTarget(
            onDragDone: (details) {
              add(
                  files: details.files
                      .where((file) =>
                          fileFormats.any((ext) =>
                              file.path.toLowerCase().endsWith('.$ext')) ==
                          true)
                      .map((f) => f.path));
            },
            onDragEntered: (_) {
              widget.onSelected?.call(true);
            },
            onDragExited: (_) {
              widget.onSelected?.call(false);
            },
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(children: [
                  Expanded(
                      child: Column(children: [
                    SizedBox(
                        height: 20,
                        child: Row(children: [
                          const Spacer(),
                          UIIconButton(
                              asset: UIIcon.add,
                              tooltip: 'Add video files',
                              onTap: () async {
                                final r = aes['player.files.directory'];
                                final directory = r != null ? r['path'] : null;
                                final result = await aes.alib.pickFiles(
                                    "Add video files",
                                    directory,
                                    true,
                                    fileFormats);
                                if (result.isEmpty) return;
                                final files = [...result.whereType<String>()];
                                add(files: files);
                                aes['player.files.directory'] = {
                                  'path': path.dirname(files.first)
                                };
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
                                      itemBuilder: (_, i) => UIContextMenu(
                                              menu: [
                                                if (Platform.isMacOS &&
                                                    assets[i].uri != null)
                                                  UIMenuItem(
                                                      text: 'Show in finder',
                                                      icon: UIIcon.finder,
                                                      onTap: () {
                                                        OpenFileMacos().open(
                                                            assets[i]
                                                                .uri!
                                                                .replaceAll(
                                                                    'file:',
                                                                    ''),
                                                            viewInFinder: true);
                                                      }),
                                                UIMenuItem(
                                                    text: 'Remove video',
                                                    icon: UIIcon.delete,
                                                    color: Colors.redAccent,
                                                    onTap: () {
                                                      aes.bus.fire(
                                                          RemoveAssetsEvent(
                                                              module: module,
                                                              assets: [
                                                            assets[i]
                                                          ]));
                                                    })
                                              ],
                                              child: AssetView(
                                                key: Key(
                                                    '${module.id}.${assets[i].id}'),
                                                moduleId: module.id,
                                                asset: assets[i],
                                                selected: assetControl.value
                                                        .toInt() ==
                                                    i,
                                                control: assetControl.value
                                                            .toInt() ==
                                                        i
                                                    ? positionControl
                                                    : null,
                                                onTap: () {
                                                  if (assetControl.value
                                                          .toInt() !=
                                                      i) {
                                                    assetControl.value =
                                                        i.toDouble();
                                                    assetControl.change(
                                                        source:
                                                            ControlChangeSource
                                                                .ui);
                                                  }
                                                },
                                              ))),
                                  const SliverToBoxAdapter(
                                      child: SizedBox(height: 10))
                                ]))),
                  ])),
                  const SizedBox(width: 5),
                  Container(
                      width: 0.5, color: ColorScheme.of(context).inversePrimary),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 338,
                      child: Column(children: [
                        SizedBox(
                            height: 20,
                            child: Row(children: [
                              Text(module.name,
                                  style: TextTheme.of(context).bodySmall)
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
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [])))
                      ])),
                  const SizedBox(width: 5)
                ]))));
  }

  Future<void> add({required Iterable<String> files}) async {
    aes.bus.fire(AddAssetsEvent(module: module, assets: [
      ...files
          .map((file) => Asset(
              id: file,
              name: path.basenameWithoutExtension(file),
              uri: 'file:$file'))
          .where((a) => assets.firstWhereOrNull((o) => a.id == o.id) == null)
    ]));
  }

  Module get module => aes.composition![widget.moduleId];
  List<Asset> get assets => [...module.assets?.whereType<Asset>() ?? []];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
