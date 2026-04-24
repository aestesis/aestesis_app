import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import 'aestesis.dart';
import 'modules/fx.dart';
import 'modules/lut.dart';
import 'table.dart';
import 'ui/menu.context.dart';
import 'ui/icon.dart';
import 'ui/menu.dart';
import 'modules/camera.dart';
import 'modules/analog.dart';
import 'modules/player.dart';
import 'modules/shader.dart';
import 'modules/syn.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ModuleView extends StatefulWidget {
  final String moduleId;
  final int moduleIndex;
  final bool selected;
  final bool dragging;
  final BoolCallback? onSelected;
  const ModuleView(
      {super.key,
      required this.moduleId,
      required this.moduleIndex,
      this.selected = false,
      this.dragging = false,
      this.onSelected});
  @override
  State<ModuleView> createState() => _ModuleViewState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ModuleViewState extends State<ModuleView>
    with AutomaticKeepAliveClientMixin {
  late final StreamSubscription moduleChangedSubscription;
  @override
  void initState() {
    super.initState();
    moduleChangedSubscription = aes.bus.on<ModuleChangeEvent>().listen((event) {
      if (event.module.id == widget.moduleId) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    moduleChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.dragging || TableView.maybeOf(context) == null) {
      // table == null means beging dragged
      return container(
          context: context,
          child: Container(
              color: ColorScheme.of(context).surface,
              child: Center(
                  child: Text(module.name,
                      style: TextTheme.of(context).titleMedium))));
    }
    return UIContextMenu(
        isRoot: true,
        menu: [
          UIMenuItem(
              text: 'Remove ${module.type.name.toLowerCase()}',
              icon: UIIcon.delete,
              color: Colors.redAccent,
              onTap: () {
                aes.bus.fire(RemoveModuleEvent(module: module));
              }),
          const UIDivider(),
          ...ModuleType.values.map((type) => UIMenuItem(
              text: 'Insert ${type.name.toLowerCase()}',
              icon: type.icon,
              onTap: () {
                aes.bus.fire(InsertModuleEvent(type: type, at: module));
              }))
        ],
        child: container(context: context, child: content(module)));
  }

  Widget container({required BuildContext context, required Widget child}) {
    final color = widget.selected
        ? ColorScheme.of(context).tertiary
        : ColorScheme.of(context).inversePrimary;
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
            duration: aes.fadeDuration,
            decoration: BoxDecoration(
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(10)),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              handle(
                  color: color,
                  child: module.type.icon
                      .widget(size: UISize.medium, color: color)),
              Expanded(child: child),
              handle(color: color)
            ])));
  }

  Widget handle({required Color color, Widget? child}) =>
      ReorderableGridDragStartListener(
          index: widget.moduleIndex,
          child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: AnimatedContainer(
                  duration: aes.fadeDuration,
                  width: 20,
                  color: color.withValues(alpha:0.2),
                  child: child)));

  Widget content(Module module) {
    switch (module.type) {
      case ModuleType.analog:
        return AnalogModule(moduleId: module.id);
      case ModuleType.camera:
        return CameraModule(moduleId: module.id);
      case ModuleType.fx:
        return FxModule(moduleId: module.id);
      case ModuleType.lut:
        return LutModule(
            moduleId: module.id,
            onSelected: (selected) => widget.onSelected?.call(selected));
      case ModuleType.player:
        return PlayerModule(
            moduleId: module.id,
            onSelected: (selected) => widget.onSelected?.call(selected));
      case ModuleType.shader:
        return ShaderModule(moduleId: module.id);
      case ModuleType.syn:
        return SynModule(moduleId: module.id);
    }
  }

  Module get module => aes.composition!.getModule(widget.moduleId)!;
  @override
  bool get wantKeepAlive => true;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
extension ModuleTypeExt on ModuleType {
  UIIcon get icon {
    switch (this) {
      case ModuleType.analog:
        return UIIcon.moduleAnalog;
      case ModuleType.camera:
        return UIIcon.moduleCamera;
      case ModuleType.fx:
        return UIIcon.moduleFx;
      case ModuleType.lut:
        return UIIcon.moduleLut;
      case ModuleType.player:
        return UIIcon.modulePlayer;
      case ModuleType.shader:
        return UIIcon.moduleShader;
      case ModuleType.syn:
        return UIIcon.moduleSyn;
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
