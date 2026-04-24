import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'button.dart';
import 'icon.dart';
import 'menu.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIMenuIconButton extends StatefulWidget {
  final UIIcon asset;
  final UISize size;
  final List<UIItem> menu;
  final String? tooltip;
  final double? itemWidth;
  const UIMenuIconButton(
      {super.key,
      required this.asset,
      this.size = UISize.medium,
      required this.menu,
      this.tooltip,
      this.itemWidth});
  @override
  State<UIMenuIconButton> createState() => _UIMenuIconButtonState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIMenuIconButtonState extends State<UIMenuIconButton> {
  bool visible = false;
  bool tapOutside = false;
  @override
  Widget build(BuildContext context) {
    return UIPortalMenu(
        visible: visible,
        width: widget.itemWidth,
        onVisibleChanged: (v) {
          setState(() => visible = v);
          tapOutside = true;
          Timer(const Duration(milliseconds: 300), () => tapOutside = false);
        },
        anchor: const Aligned(
            shiftToWithinBound: AxisFlag(x: true, y: true),
            follower: Alignment.topCenter,
            target: Alignment.bottomCenter,
            offset: Offset(0, 10)),
        menu: widget.menu,
        child: UIIconButton(
            asset: widget.asset,
            size: widget.size,
            tooltip: widget.tooltip,
            enabled: widget.menu.isNotEmpty,
            onTap: () {
              if (tapOutside) return;
              setState(() {
                visible = true;
              });
            }));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIMenuTextButton<T> extends StatefulWidget {
  final List<UIMenuItem<T>> menu;
  final T? value;
  final void Function(T value)? onChanged;
  final AEButtonStyle style;
  final UISize size;
  final double? itemWidth;
  const UIMenuTextButton(
      {super.key,
      this.onChanged,
      this.menu = const [],
      this.style = AEButtonStyle.filled,
      this.size = UISize.medium,
      this.itemWidth,
      this.value});
  @override
  State<UIMenuTextButton<T>> createState() => _UIMenuTextButtonState<T>();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIMenuTextButtonState<T> extends State<UIMenuTextButton<T>> {
  bool visible = false;
  bool tapOutside = false;
  @override
  Widget build(BuildContext context) {
    final selected =
        widget.menu.firstWhereOrNull((e) => e.value == widget.value);
    return UIPortalMenu<T>(
        visible: visible,
        size: widget.size,
        width: widget.itemWidth,
        menu: widget.menu,
        value: widget.value,
        anchor: const Aligned(
            shiftToWithinBound: AxisFlag(x: true, y: true),
            follower: Alignment.centerLeft,
            target: Alignment.centerRight,
            offset: Offset(5, 0)),
        onChanged: (v) {
          widget.onChanged?.call(v);
        },
        onVisibleChanged: (v) {
          setState(() => visible = v);
          tapOutside = true;
          Timer(const Duration(milliseconds: 300), () => tapOutside = false);
        },
        child: UITextButton(
            icon: selected?.icon,
            text: selected?.text,
            style: widget.style,
            size: widget.size,
            onTap: () {
              setState(() {
                if (tapOutside) return;
                visible = true;
              });
            }));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
