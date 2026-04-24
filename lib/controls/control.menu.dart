import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';
import '../aestesis.dart';
import '../ui/button.dart';
import '../ui/menu.button.dart';
import '../ui/icon.dart';
import '../ui/menu.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ControlMenu extends StatefulWidget {
  final Control control;
  final List<UIMenuItem<double>> items;
  final UISize size;
  final double? itemWidth;
  const ControlMenu(
      {super.key,
      required this.control,
      required this.items,
      this.size = UISize.medium,
      this.itemWidth});
  @override
  State<ControlMenu> createState() => _ControlMenuState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ControlMenuState extends State<ControlMenu> {
  late final StreamSubscription controlSubscription;
  late Control control = widget.control;
  @override
  initState() {
    super.initState();
    controlSubscription = widget.control.listen((control) {
      this.control = control;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controlSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UIMenuTextButton(
        style: AEButtonStyle.transparent,
        size: widget.size,
        itemWidth: widget.itemWidth,
        menu: widget.items,
        value: control.value,
        onChanged: (value) {
          control.value = value;
          control.change(source: ControlChangeSource.ui);
          setState(() {});
        });
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
