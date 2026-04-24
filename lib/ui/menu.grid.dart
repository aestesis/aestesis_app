import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../window.dart';
import 'button.dart';
import 'menu.dart';
import 'select.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIGridMenu<T> extends StatefulWidget {
  final List<UIMenuItem<T>> items;
  final T? value;
  final ValueChanged<T>? onChanged;
  final double itemWidth;
  const UIGridMenu(
      {super.key,
      required this.items,
      this.value,
      this.onChanged,
      this.itemWidth = 40});
  @override
  State<UIGridMenu> createState() => _UIGridMenuState<T>();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIGridMenuState<T> extends State<UIGridMenu<T>> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    final selected =
        widget.items.firstWhereOrNull((e) => e.value == widget.value);
    return WindowBlur(
        onBlur: () => setState(() => visible = false),
        child: PortalTarget(
            visible: visible,
            anchor: const Aligned(
                shiftToWithinBound: AxisFlag(x: true, y: true),
                offset: Offset(0, 0),
                follower: Alignment.center,
                target: Alignment.center),
            portalFollower: TapRegion(
                onTapOutside: (_) {
                  setState(() => visible = false);
                },
                child: UIGridMenuContent(
                    itemWidth: widget.itemWidth,
                    items: widget.items,
                    value: widget.value,
                    onSelected: (v) {
                      setState(() => visible = false);
                      widget.onChanged?.call(v);
                    })),
            child: UITextButton(
                style: AEButtonStyle.transparent,
                icon: selected?.icon,
                text: selected?.text,
                onTap: () {
                  setState(() => visible = true);
                })));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIGridMenuContent<T> extends StatelessWidget {
  final List<UIMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final T? value;
  final double itemWidth;
  const UIGridMenuContent(
      {super.key,
      required this.items,
      required this.onSelected,
      this.value,
      required this.itemWidth});
  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.of(context).size.width * 0.8,
        itemWidth * items.length * 0.1 - 14);
    return Container(
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorScheme.of(context).primaryContainer,
            border: Border.all(
                color:
                    ColorScheme.of(context).onPrimaryContainer.withValues(alpha:0.5)),
            boxShadow: [
              BoxShadow(
                  color: ColorScheme.of(context).primaryContainer.withValues(alpha:0.5),
                  blurRadius: 5,
                  offset: const Offset(0, 5))
            ]),
        padding: const EdgeInsets.all(5),
        child: Wrap(children: [
          ...items.map((e) => SizedBox(
              width: itemWidth,
              child: UISelectItem(
                selected: value == e.value,
                onChanged: (v) {
                  if (e.value is T) {
                    onSelected(e.value as T);
                  }
                },
                child: Center(
                    child: Text(e.text, style: TextTheme.of(context).bodySmall)),
              )))
        ]));
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
