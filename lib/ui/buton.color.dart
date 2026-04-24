import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import '../window.dart';
import 'icon.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIColorButton extends StatefulWidget {
  final Color color;
  final void Function(Color color)? onChanged;
  final UISize size;
  const UIColorButton({
    super.key,
    required this.color,
    this.onChanged,
    this.size = UISize.medium,
  });
  @override
  State<UIColorButton> createState() => _UIColorButtonState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIColorButtonState extends State<UIColorButton> {
  bool visible = false;
  bool tapOutside = false;
  @override
  Widget build(BuildContext context) {
    final rounded = BorderRadius.circular(20);
    return WindowBlur(
      onBlur: () => setState(() => visible = false),
      child: PortalTarget(
        visible: visible,
        anchor: const Aligned(
          shiftToWithinBound: AxisFlag(x: true, y: true),
          offset: Offset(5, -16),
          follower: Alignment.topLeft,
          target: Alignment.centerRight,
        ),
        portalFollower: TapRegion(
          onTapOutside: (_) {
            setState(() => visible = false);
            tapOutside = true;
            Timer(const Duration(milliseconds: 300), () {
              tapOutside = false;
            });
          },
          child: UIColorPicker(
            color: widget.color,
            onEnd: () => setState(() => visible = false),
            onChanged: (c) {
              widget.onChanged?.call(c);
            },
          ),
        ),
        child: InkWell(
          onTap: () {
            if (tapOutside) return;
            setState(() => visible = true);
          },
          child: ClipRRect(
            borderRadius: rounded,
            child: Container(
              width: widget.size.value,
              height: widget.size.value,
              decoration: BoxDecoration(
                borderRadius: rounded,
                border: Border.all(
                  color: ColorScheme.of(context).primaryContainer,
                  width: 2,
                ),
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIColorPicker extends StatefulWidget {
  final Color color;
  final void Function(Color color)? onChanged;
  final VoidCallback? onEnd;
  const UIColorPicker({
    super.key,
    required this.color,
    this.onChanged,
    this.onEnd,
  });
  @override
  State<UIColorPicker> createState() => _UIColorPickerState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIColorPickerState extends State<UIColorPicker> {
  late HSLColor hsl = HSLColor.fromColor(widget.color);
  bool processing = false;
  @override
  void didUpdateWidget(covariant UIColorPicker oldWidget) {
    if (!processing) {
      hsl = HSLColor.fromColor(widget.color);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    const sizeHSL = Size(200, 120);
    const sizeRGB = Size(200, 10);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorScheme.of(context).primaryContainer,
        border: Border.all(
          color: ColorScheme.of(
            context,
          ).onPrimaryContainer.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorScheme.of(
              context,
            ).primaryContainer.withValues(alpha: 0.5),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UIMovePainter(
            size: sizeRGB,
            onClose: () => widget.onEnd?.call(),
            onEnd: () => processing = false,
            onMove: (p) {
              if (!processing) {
                processing = true;
                hsl = HSLColor.fromColor(widget.color);
              }
              hsl = HSLColor.fromAHSL(1, hsl.hue, hsl.saturation, p.dx);
              widget.onChanged?.call(hsl.toColor());
            },
            painter: UIColorPickerLuminosityPainter(hsl: hsl),
          ),
          const SizedBox(height: 5),
          UIMovePainter(
            size: sizeHSL,
            onClose: () => widget.onEnd?.call(),
            onEnd: () => processing = false,
            onMove: (p) {
              if (!processing) {
                processing = true;
                hsl = HSLColor.fromColor(widget.color);
              }
              final h = 359.99 * p.dx;
              final s = p.dy;
              hsl = HSLColor.fromAHSL(1, h, s, hsl.lightness);
              widget.onChanged?.call(hsl.toColor());
            },
            painter: ColorPickerHSLPainter(hsl: hsl),
          ),
          const SizedBox(height: 5),
          UIMovePainter(
            size: sizeRGB,
            onClose: () => widget.onEnd?.call(),
            onMove: (p) {
              final r = p.dx;
              widget.onChanged?.call(widget.color.withRed((r * 255).toInt()));
            },
            painter: ColorPickerRedPainter(color: widget.color),
          ),
          UIMovePainter(
            size: sizeRGB,
            onClose: () => widget.onEnd?.call(),
            onMove: (p) {
              final g = p.dx;
              widget.onChanged?.call(widget.color.withGreen((g * 255).toInt()));
            },
            painter: UIColorPickerGreenPainter(color: widget.color),
          ),
          UIMovePainter(
            size: sizeRGB,
            onClose: () => widget.onEnd?.call(),
            onMove: (p) {
              final b = p.dx;
              widget.onChanged?.call(widget.color.withBlue((b * 255).toInt()));
            },
            painter: ColorPickerBluePainter(color: widget.color),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIColorPickerLuminosityPainter extends CustomPainter {
  final HSLColor hsl;
  const UIColorPickerLuminosityPainter({required this.hsl});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = hsl.toColor();
    final psize = Size(1, size.height);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5)),
    );
    for (double x = 0; x < size.width; x++) {
      final l = x / size.width;
      final c = HSLColor.fromAHSL(1, hsl.hue, hsl.saturation, l);
      paint.color = c.toColor();
      canvas.drawRect(Offset(x, 0) & psize, paint);
    }
    canvas.restore();
    _drawCursor(
      canvas,
      Offset(hsl.lightness * size.width, size.height / 2),
      hsl.toColor(),
    );
  }

  @override
  bool shouldRepaint(covariant UIColorPickerLuminosityPainter oldDelegate) =>
      hsl != oldDelegate.hsl;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class ColorPickerHSLPainter extends CustomPainter {
  final HSLColor hsl;
  const ColorPickerHSLPainter({required this.hsl});
  @override
  void paint(Canvas canvas, Size size) {
    //final hsl = HSLColor.fromColor(color);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = hsl.toColor();
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5)),
    );
    for (double x = 0; x < size.width; x++) {
      for (double y = 0; y < size.height; y++) {
        final h = 360 * x / size.width;
        final s = y / size.height;
        final c = HSLColor.fromAHSL(1, h, s, hsl.lightness);
        paint.color = c.toColor();
        canvas.drawRect(Offset(x, y) & const Size(1, 1), paint);
      }
    }
    canvas.restore();
    _drawCursor(
      canvas,
      Offset(hsl.hue * size.width / 360, hsl.saturation * size.height),
      hsl.toColor(),
    );
  }

  @override
  bool shouldRepaint(covariant ColorPickerHSLPainter oldDelegate) =>
      hsl != oldDelegate.hsl;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class ColorPickerRedPainter extends CustomPainter {
  final Color color;
  const ColorPickerRedPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final psize = Size(1, size.height);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5)),
    );
    for (double x = 0; x < size.width; x++) {
      final r = x / size.width;
      paint.color = color.withRed((r * 255).toInt());
      canvas.drawRect(Offset(x, 0) & psize, paint);
    }
    canvas.restore();
    _drawCursor(canvas, Offset(color.r * size.width, size.height / 2), color);
  }

  @override
  bool shouldRepaint(covariant ColorPickerRedPainter oldDelegate) =>
      color != oldDelegate.color;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class UIColorPickerGreenPainter extends CustomPainter {
  final Color color;
  const UIColorPickerGreenPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final psize = Size(1, size.height);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5)),
    );
    for (double x = 0; x < size.width; x++) {
      final g = x / size.width;
      paint.color = color.withGreen((g * 255).toInt());
      canvas.drawRect(Offset(x, 0) & psize, paint);
    }
    canvas.restore();
    _drawCursor(canvas, Offset(color.g * size.width, size.height / 2), color);
  }

  @override
  bool shouldRepaint(covariant UIColorPickerGreenPainter oldDelegate) =>
      color != oldDelegate.color;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class ColorPickerBluePainter extends CustomPainter {
  final Color color;
  const ColorPickerBluePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final psize = Size(1, size.height);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5)),
    );
    for (double x = 0; x < size.width; x++) {
      final b = x / size.width;
      paint.color = color.withBlue((b * 255).toInt());
      canvas.drawRect(Offset(x, 0) & psize, paint);
    }
    canvas.restore();
    _drawCursor(canvas, Offset(color.b * size.width, size.height / 2), color);
  }

  @override
  bool shouldRepaint(covariant ColorPickerBluePainter oldDelegate) =>
      color != oldDelegate.color;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void _drawCursor(Canvas canvas, Offset position, Color color) {
  final paint = Paint();
  paint
    ..style = PaintingStyle.fill
    ..color = color;
  canvas.drawCircle(position, 4, paint);
  paint
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  canvas.drawCircle(position, 5, paint..color = Colors.black);
  canvas.drawCircle(position, 6, paint..color = Colors.white);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIMovePainter extends StatelessWidget {
  final void Function(Offset position)? onMove;
  final void Function()? onEnd;
  final void Function()? onClose;
  final Size size;
  final CustomPainter painter;
  const UIMovePainter({
    super.key,
    this.onMove,
    this.onClose,
    required this.size,
    required this.painter,
    this.onEnd,
  });
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: () => onClose?.call(),
        onPanDown: (d) => move(d.localPosition),
        onPanStart: (d) => move(d.localPosition),
        onPanUpdate: (d) => move(d.localPosition),
        onPanEnd: (_) => onEnd?.call(),
        onPanCancel: () => onEnd?.call(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: CustomPaint(painter: painter, size: size),
        ),
      ),
    );
  }

  void move(Offset position) {
    final x = (position.dx - 5).clamp(0, size.width);
    final y = (position.dy - 5).clamp(0, size.height);
    onMove?.call(Offset(x / size.width, y / size.height));
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
