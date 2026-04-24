import 'dart:math';

import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';

import 'icon.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum KnobType {
  unit, // 0..1
  float, // -1..1
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class UIKnob extends StatefulWidget {
  final KnobType type;
  final Color? color;
  final UISize size;
  final String name;
  final double value;
  final DoubleCallback? onChanged;
  const UIKnob({
    super.key,
    required this.value,
    required this.name,
    this.onChanged,
    this.size = UISize.medium,
    this.color,
    this.type = KnobType.float,
  });
  @override
  State<UIKnob> createState() => _UIKnobState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _UIKnobState extends State<UIKnob> {
  bool primaryDragging = false;
  double primaryValue = 0;
  double primaryDragStart = 0;
  double primaryDragStartValue = 0;

  bool secondaryDragging = false;
  double secondaryValue = 0;
  double secondaryDragStart = 0;
  double secondaryDragStartValue = 0;

  double memoPrimaryValue = 0;

  @override
  void initState() {
    super.initState();
    primaryValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant UIKnob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      primaryValue = widget.value;
    }
  }

  int buttons = 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerMove: (event) {
          if (buttons != event.buttons) {
            if (secondaryDragging) {
              switch (event.buttons) {
                case 3:
                  memoPrimaryValue = primaryValue;
                  setState(() {
                    primaryValue = secondaryValue;
                  });
                  widget.onChanged?.call(primaryValue);
                case 2:
                  setState(() {
                    primaryValue = memoPrimaryValue;
                  });
                  widget.onChanged?.call(primaryValue);
                case 1:
                  setState(() {
                    secondaryDragging = false;
                    primaryDragging = true;
                    primaryDragStart = event.localPosition.dy;
                    primaryDragStartValue = secondaryValue;
                    primaryValue = secondaryValue;
                  });
              }
            }
          }
          buttons = event.buttons;
        },
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              primaryValue = 0;
            });
            widget.onChanged?.call(primaryValue);
          },
          onSecondaryLongPressDown: (event) {
            setState(() {
              secondaryDragging = true;
              secondaryValue = primaryValue;
              memoPrimaryValue = primaryValue;
            });
          },
          onSecondaryLongPressCancel: () {
            setState(() {
              secondaryDragging = false;
            });
          },
          onSecondaryLongPressEnd: (event) {
            setState(() {
              secondaryDragging = false;
              primaryDragging = false;
            });
          },
          onSecondaryLongPressStart: (event) {
            secondaryDragStart = event.localPosition.dy;
            secondaryDragStartValue = primaryValue;
            secondaryValue = primaryValue;
            memoPrimaryValue = primaryValue;
          },
          onSecondaryLongPressMoveUpdate: (event) {
            setState(() {
              if (secondaryDragging) {
                secondaryValue = range(
                  startValue: secondaryDragStartValue,
                  dragStart: secondaryDragStart,
                  dy: event.localPosition.dy,
                );
              } else if (primaryDragging) {
                primaryValue = range(
                  startValue: primaryDragStartValue,
                  dragStart: primaryDragStart,
                  dy: event.localPosition.dy,
                );
              }
            });
            if (primaryDragging) {
              widget.onChanged?.call(primaryValue);
            }
          },
          onVerticalDragDown: (event) {
            setState(() {
              primaryDragging = true;
            });
          },
          onVerticalDragCancel: () {
            setState(() {
              primaryDragging = false;
            });
          },
          onVerticalDragEnd: (event) {
            setState(() {
              primaryDragging = false;
            });
          },
          onVerticalDragStart: (event) {
            primaryDragStart = event.localPosition.dy;
            primaryDragStartValue = primaryValue;
          },
          onVerticalDragUpdate: (event) {
            setState(() {
              primaryValue = range(
                startValue: primaryDragStartValue,
                dragStart: primaryDragStart,
                dy: event.localPosition.dy,
              );
            });
            widget.onChanged?.call(primaryValue);
          },
          child: SizedBox(
            width: knobSize(widget.size),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: knobSize(widget.size),
                  height: knobSize(widget.size),
                  child: CustomPaint(
                    painter: KnobPainter(
                      type: widget.type,
                      strokeWidth: strokeWidth(),
                      value: primaryValue,
                      secondary: secondaryDragging ? secondaryValue : null,
                      background: ColorScheme.of(
                        context,
                      ).inversePrimary.withValues(alpha: 0.7),
                      color: widget.color ?? ColorScheme.of(context).secondary,
                    ),
                  ),
                ),
                SizedBox(height: strokeWidth()),
                Text(
                  primaryDragging ? text() : widget.name,
                  style: TextTheme.of(
                    context,
                  ).bodySmall!.apply(fontSizeFactor: textFactor(widget.size)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String text() {
    switch (widget.type) {
      case KnobType.float:
        if (primaryValue > 0) {
          return '+${(primaryValue * 100).round()}';
        }
        return '${(primaryValue * 100).round()}';
      case KnobType.unit:
        return '${(primaryValue * 100).round()}';
    }
  }

  double range({
    required double startValue,
    required double dragStart,
    required double dy,
  }) {
    switch (widget.type) {
      case KnobType.float:
        return max(-1, min(1, startValue + (dragStart - dy) / 50));
      case KnobType.unit:
        return max(0, min(1, startValue + (dragStart - dy) / 100));
    }
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

  double knobSize(UISize size) {
    switch (size) {
      case UISize.small:
        return 20;
      case UISize.medium:
        return 30;
      case UISize.large:
        return 40;
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
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class KnobPainter extends CustomPainter {
  final KnobType type;
  final double strokeWidth;
  final Color color;
  final double value;
  final Color background;
  final double? secondary;
  const KnobPainter({
    this.type = KnobType.float,
    required this.value,
    this.secondary,
    this.strokeWidth = 5,
    required this.color,
    required this.background,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final d = (strokeWidth * 0.5).ceilToDouble();
    final rect = Rect.fromLTWH(d, d, size.width - d * 2, size.height - d * 2);
    final center = rect.center;
    final r = rect.width * 0.5;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r, paint..color = background);
    switch (type) {
      case KnobType.unit:
        canvas.drawArc(
          rect,
          pi * 0.7,
          value * pi * 1.6,
          false,
          paint
            ..color = color
            ..strokeWidth = strokeWidth * 0.8,
        );
      case KnobType.float:
        const v0 = pi * 1.5;
        final v1 = v0 + value * pi * 0.8;
        final start = min(v0, v1);
        final sweep = max(v0, v1) - start;
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          paint
            ..color = color
            ..strokeWidth = strokeWidth * 0.8,
        );
    }
    if (secondary != null) {
      final av = angle(secondary!); //pi * 0.7 + secondary! * pi * 1.6;
      final pv = Offset(cos(av), sin(av)) * (r - strokeWidth);
      canvas.drawLine(
        center,
        pv + center,
        paint..color = color.withValues(alpha: 0.7),
      );
    }
    final av = angle(value); //pi * 0.7 + value * pi * 1.6;
    final pv = Offset(cos(av), sin(av)) * (r - strokeWidth);
    canvas.drawLine(center, pv + center, paint..color = color);
  }

  double angle(double value) {
    switch (type) {
      case KnobType.unit:
        return pi * 0.7 + value * pi * 1.6;
      case KnobType.float:
        return pi * 1.5 + value * pi * 0.8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      value != (oldDelegate as KnobPainter).value ||
      color != oldDelegate.color ||
      secondary != oldDelegate.secondary;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
