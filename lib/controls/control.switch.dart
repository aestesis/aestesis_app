import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../aestesis.dart';
//import '../ui/buton.color.dart';
import '../ui/button.dart';
import '../ui/icon.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ControlSwitch extends StatefulWidget {
  final Control control;
  final UISize size;
  final UIIcon active;
  final UIIcon inactive;
  const ControlSwitch({
    super.key,
    this.size = UISize.medium,
    required this.control,
    required this.active,
    required this.inactive,
  });
  @override
  State<ControlSwitch> createState() => _ControlSwitchState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ControlSwitchState extends State<ControlSwitch> {
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
    return Column(
      mainAxisSize: .min,
      children: [
        Container(
          width: switchSize(widget.size),
          height: switchSize(widget.size),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: BoxBorder.all(
              color: ColorScheme.of(context).inversePrimary,
              width: 1,
            ),
          ),
          child: UIIconButton(
            size: widget.size,
            color: ColorScheme.of(context).secondary,
            asset: control.boolean ? widget.active : widget.inactive,
            onTap: () {
              control.boolean = !control.boolean;
              control.change(source: ControlChangeSource.ui);
            },
          ),
        ),
        SizedBox(height: strokeWidth()),
        Text(
          widget.control.name,
          textAlign: .center,
          style: TextTheme.of(
            context,
          ).bodySmall!.apply(fontSizeFactor: textFactor(widget.size)),
        ),
      ],
    );
  }

  double strokeWidth() {
    switch (widget.size) {
      case UISize.small:
        return 3;
      case UISize.medium:
        return 5;
      case UISize.large:
        return 6;
    }
  }

  double textFactor(UISize size) {
    switch (size) {
      case UISize.small:
        return 0.3;
      case UISize.medium:
        return 0.5;
      case UISize.large:
        return 0.8;
    }
  }

  double switchSize(UISize size) {
    switch (size) {
      case UISize.small:
        return 20;
      case UISize.medium:
        return 30;
      case UISize.large:
        return 40;
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
