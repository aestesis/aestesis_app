import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../ui/buton.color.dart';
import '../ui/icon.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ControlColor extends StatefulWidget {
  final Control control;
  final UISize size;
  const ControlColor(
      {super.key, this.size = UISize.medium, required this.control});
  @override
  State<ControlColor> createState() => _ControlColorState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ControlColorState extends State<ControlColor> {
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
    return UIColorButton(
        color: control.color,
        size: widget.size,
        onChanged: (color) {
          control.color = color;
          control.change(source: ControlChangeSource.ui);
        });
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
