import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../core/native.view.dart';
import '../ui/icon.dart';
import '../ui/menu.context.dart';
import '../ui/menu.dart';
import '../ui/sliver.grid.delegate.dart';

// https://pub.dev/packages/shadertoy_client

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ShaderModule extends StatefulWidget {
  final String moduleId;
  const ShaderModule({super.key, required this.moduleId});
  @override
  State<ShaderModule> createState() => _ShaderModuleState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ShaderModuleState extends State<ShaderModule> {
  static const String appKey = 'NtrlR8';
  late final StreamSubscription assetChangedSubscription;
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    assetChangedSubscription = module[ShaderControl.asset.id].listen((_) {
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
    final assetControl = module[ShaderControl.asset.id];
    return UIContextMenu(
        menu: [
          if (assets.isNotEmpty)
            UIMenuItem(
                text: 'Remove all luts',
                icon: UIIcon.delete,
                color: Colors.redAccent,
                onTap: () {
                  aes.bus.fire(RemoveAssetsEvent(
                      module: module,
                      assets: [...assets.where((a) => a.uri != null)]));
                })
        ],
        child: Padding(
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
                                          mainAxisExtent: 90),
                                  itemBuilder: (_, i) => const ShaderItem()),
                              const SliverToBoxAdapter(
                                  child: SizedBox(height: 10))
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
                            child: Row(
                                mainAxisSize: MainAxisSize.min, children: [])))
                  ])),
              const SizedBox(width: 5)
            ])));
  }

  Module get module => aes.composition![widget.moduleId];
  List<Asset> get assets => [...module.assets?.whereType<Asset>() ?? []];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ShaderItem extends StatefulWidget {
  const ShaderItem({super.key});
  @override
  State<ShaderItem> createState() => _ShaderItemState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ShaderItemState extends State<ShaderItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
