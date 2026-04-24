import 'package:bb.flutter/bb.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../window.dart';
import 'icon.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIItem {
  const UIItem();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class UIDivider extends UIItem {
  const UIDivider();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class UIMenuItem<T> extends UIItem {
  final UIIcon? icon;
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final T? value;
  final Color? color;
  const UIMenuItem(
      {this.value,
      this.icon,
      required this.text,
      this.onTap,
      this.color,
      this.enabled = true});
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIPortalMenuItem<T> extends StatefulWidget {
  final UIMenuItem<T> item;
  final VoidCallback? onTap;
  final bool showIcon;
  final bool selected;
  final double? width;
  final UISize size;
  const UIPortalMenuItem(
      {super.key,
      required this.item,
      this.onTap,
      this.showIcon = true,
      this.selected = false,
      this.width,
      this.size = UISize.medium});
  @override
  State<UIPortalMenuItem<T>> createState() => _UIPortalMenuItemState<T>();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIPortalMenuItemState<T> extends State<UIPortalMenuItem<T>> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? ColorScheme.of(context).secondary
        : (widget.item.color ?? ColorScheme.of(context).onPrimaryContainer).withValues(alpha:hover ? 1 : 0.8);
    return MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: InkWell(
            onTap: () {
              widget.onTap?.call();
              widget.item.onTap?.call();
            },
            child: SizedBox(
                width: widget.width,
                child: Row(
                    mainAxisSize: widget.width == null
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.showIcon) ...[
                        if (widget.item.icon != null) ...[
                          widget.item.icon!
                              .widget(size: UISize.medium, color: color),
                          const SizedBox(width: 10)
                        ] else
                          SizedBox(width: 10 + UISize.medium.value)
                      ],
                      Text(widget.item.text,
                          style: widget.size
                              .bodyStyle(context)!
                              .apply(color: color))
                    ]))));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIPortalMenu<T> extends StatefulWidget {
  final Widget child;
  final List<UIItem> menu;
  final Aligned anchor;
  final bool visible;
  final BoolCallback? onVisibleChanged;
  final Function(T value)? onChanged;
  final T? value;
  final double? width;
  final UISize size;
  const UIPortalMenu(
      {super.key,
      required this.menu,
      required this.child,
      this.anchor =
          const Aligned(follower: Alignment.topLeft, target: Alignment.topLeft),
      required this.visible,
      this.onVisibleChanged,
      this.onChanged,
      this.value,
      this.width,
      this.size = UISize.medium});
  @override
  State<UIPortalMenu<T>> createState() => _UIPortalMenuState<T>();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIPortalMenuState<T> extends State<UIPortalMenu<T>> {
  @override
  Widget build(BuildContext context) {
    final visible = widget.visible;
    final showIcon =
        widget.menu.whereType<UIMenuItem>().any((m) => m.icon != null);
    return WindowBlur(
        onBlur: () => widget.onVisibleChanged?.call(false),
        child: PortalTarget(
            visible: visible,
            anchor: widget.anchor,
            portalFollower: TapRegion(
                onTapOutside: (_) {
                  widget.onVisibleChanged?.call(false);
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: ColorScheme.of(context).primaryContainer,
                        boxShadow: [
                          BoxShadow(
                              color: ColorScheme.of(context)
                                  .primaryContainer
                                  .withValues(alpha:0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 5))
                        ]),
                    child: IntrinsicWidth(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          ...BB.separator(
                              separatorBuilder: () => const SizedBox(height: 5),
                              items: widget.menu.map((m) {
                                if (m is UIMenuItem<T>) {
                                  return UIPortalMenuItem<T>(
                                      item: m,
                                      width: widget.width,
                                      size: widget.size,
                                      showIcon: showIcon,
                                      selected: widget.value != null &&
                                          widget.value == m.value,
                                      onTap: () {
                                        widget.onVisibleChanged?.call(false);
                                        if (m.value is! T) return;
                                        widget.onChanged?.call(m.value as T);
                                      });
                                }                                
                                return Container(
                                    height: 0.5,
                                    color: ColorScheme.of(context)
                                        .onPrimaryContainer
                                        .withValues(alpha:0.5));
                              }))
                        ])))),
            child: widget.child));
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

