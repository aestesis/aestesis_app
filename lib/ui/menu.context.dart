import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'menu.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIContextMenu extends StatefulWidget {
  final Widget child;
  final List<UIItem> menu;
  final bool isRoot;
  const UIContextMenu(
      {super.key,
      required this.menu,
      required this.child,
      this.isRoot = false});
  @override
  State<UIContextMenu> createState() => _UIContextMenuState();
  static List<UIItem> of(BuildContext context) {
    List<UIItem> menu = [];
    context.visitAncestorElements((element) {
      if (element.widget is UIContextMenu) {
        final cm = element.widget as UIContextMenu;
        if (cm.menu.isNotEmpty) {
          menu.add(const UIDivider());
          menu.addAll(cm.menu);
        }
        if (cm.isRoot) return false;
      }
      return true;
    });
    return menu;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIContextMenuState extends State<UIContextMenu> {
  static final onMenu = Event<Key>();
  final menuKey = UniqueKey();
  Offset mousePosition = const Offset(0, 0);
  Offset menuPosition = const Offset(0, 0);
  bool visible = false;
  @override
  void initState() {
    super.initState();
    onMenu.on(otherMenu);
  }

  @override
  void dispose() {
    onMenu.off(otherMenu);
    super.dispose();
  }

  void otherMenu(Key key) {
    if (key != menuKey) {
      setState(() {
        visible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menu.isEmpty) return widget.child;
    return UIPortalMenu(
        menu: menu(context),
        anchor: Aligned(
            shiftToWithinBound: const AxisFlag(x: true, y: true),
            follower: Alignment.topLeft,
            target: Alignment.topLeft,
            offset: menuPosition),
        visible: visible,
        onVisibleChanged: (v) => setState(() => visible = v),
        child: MouseRegion(
            onHover: (event) => {mousePosition = event.localPosition},
            child: GestureDetector(
                onSecondaryTap: () {
                  setState(() {
                    visible = true;
                    menuPosition = mousePosition;
                    onMenu.fire(menuKey);
                  });
                },
                child: widget.child)));
  }

  List<UIItem> menu(BuildContext context) {
    if (widget.isRoot) {
      return widget.menu;
    }
    final parents = UIContextMenu.of(context);
    return [...widget.menu, ...parents];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
