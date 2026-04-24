import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../ui/icon.dart';
import '../ui/knob.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ControlKnob extends StatefulWidget {
  final Control control;
  final UISize size;
  final Color? color;
  const ControlKnob(
      {super.key,
      this.size = UISize.medium,
      this.color,
      required this.control});
  @override
  State<ControlKnob> createState() => _ControlKnobState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ControlKnobState extends State<ControlKnob> {
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
    return UIKnob(
        name: widget.control.name,
        size: widget.size,
        color: widget.color,
        value: control.value,
        type: control.type == ControlType.unit ? KnobType.unit : KnobType.float,
        onChanged: (v) {
          control.value = v;
          control.change(source: ControlChangeSource.ui);
        });
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
