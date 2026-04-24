import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import '../aestesis.dart';
import '../ui/button.dart';
import '../ui/icon.dart';
import '../ui/sliver.grid.delegate.dart';
import '../ui/text.edit.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class PresetsEditor extends StatefulWidget {
  final VoidCallback? onClose;
  const PresetsEditor({super.key, this.onClose});
  @override
  State<PresetsEditor> createState() => _PresetsEditorState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _PresetsEditorState extends State<PresetsEditor> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 30;
    final n = w ~/ 210;
    final double h = (128.0 / n).ceilToDouble() * 40 + 10;
    return Column(children: [
      Container(
          height: 30,
          decoration: BoxDecoration(
              color: ColorScheme.of(context).primaryContainer,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            UIIcon.mapping.widget(
                size: UISize.medium,
                color: ColorScheme.of(context).onPrimaryContainer),
            const SizedBox(width: 10),
            const Text('Presets'),
            const Spacer(),
            UIIconButton(
                tooltip: 'External selection',
                asset: UIIcon.tv,
                onTap: () {
                  setState(() {});
                }),
            const SizedBox(width: 10),
            UIIconButton(
                tooltip: 'Close',
                asset: UIIcon.close,
                onTap: () {
                  widget.onClose?.call();
                })
          ])),
      Container(
          height: h,
          color: ColorScheme.of(context).primaryContainer.withValues(alpha:0.5),
          child: sliverView())
    ]);
  }

  Widget sliverView() => CustomScrollView(slivers: [
        SliverPadding(
            padding:
                const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            sliver: SliverReorderableGrid(
                onReorder: reorderPreset,
                itemCount: aes.presets.count,
                gridDelegate: const SliverGridDelegateWithMinMaxCrossAxisExtent(
                    maxCrossAxisCount: 128,
                    minCrossAxisExtent: 200,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 30),
                itemBuilder: (context, index) =>
                    PresetItem(key: Key(aes.presets[index].id), index: index)))
      ]);
  void reorderPreset(int oldIndex, int newIndex) {
    Debug.info('reorder o:$oldIndex n:$newIndex');
    aes.presets.reorder(oldIndex, newIndex);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class PresetItem extends StatefulWidget {
  final int index;
  const PresetItem({super.key, required this.index});
  @override
  State<PresetItem> createState() => _PresetItemState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _PresetItemState extends State<PresetItem> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final preset = aes.presets[widget.index];
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: Material(
            child: Container(
                color: Color.lerp(
                    Colors.black, ColorScheme.of(context).primaryContainer, 0.8),
                child: Row(children: [
                  ReorderableGridDragStartListener(
                      index: widget.index,
                      child: InkWell(
                          onTap: () {
                            preset.load();
                          },
                          child: Container(
                              color: ColorScheme.of(context)
                                  .onPrimaryContainer
                                  .withValues(alpha:0.1),
                              height: double.infinity,
                              width: 40,
                              child: Center(
                                  child: Text('${widget.index}',
                                      style: TextTheme.of(context)
                                          .bodySmall!
                                          .apply(
                                              color: ColorScheme.of(context)
                                                  .onPrimaryContainer
                                                  .withValues(alpha:preset.isEmpty
                                                      ? 0.3
                                                      : 0.8))))))),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: TextEdit(
                              initValue: preset.name,
                              grayed: preset.isEmpty,
                              onChanged: (v) => preset.name = v))),
                  MouseRegion(
                      onEnter: (_) => setState(() {
                            hover = true;
                          }),
                      onExit: (_) => setState(() {
                            hover = false;
                          }),
                      child: Container(
                          color: ColorScheme.of(context)
                              .onPrimaryContainer
                              .withValues(alpha:0.1),
                          child: Container(
                              height: double.infinity,
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Center(
                                  child: AnimatedSize(
                                      duration: aes.animDuration,
                                      curve: Curves.ease,
                                      child: Row(children: [
                                        if (hover) ...[
                                          UIIconButton(
                                              asset: UIIcon.edit,
                                              onTap: () {
                                                preset.save();
                                                hover = false;
                                                setState(() {});
                                              }),
                                          const SizedBox(width: 5),
                                          UIIconButton(
                                              asset: UIIcon.delete,
                                              onTap: () {
                                                preset.clear();
                                                hover = false;
                                                setState(() {});
                                              })
                                        ]
                                      ]))))))
                ]))));
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
