import 'package:flutter/material.dart';

import '../aestesis.dart';
import 'icon.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class UIIconButton extends StatefulWidget {
  final UIIcon asset;
  final VoidCallback? onTap;
  final UISize size;
  final Color? color;
  final String? tooltip;
  final bool enabled;
  const UIIconButton(
      {super.key,
      required this.asset,
      this.onTap,
      this.size = UISize.medium,
      this.color,
      this.tooltip,
      this.enabled = true});
  @override
  State<UIIconButton> createState() => _UIIconButtonState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UIIconButtonState extends State<UIIconButton> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? ColorScheme.of(context).onSurface;
    final color = widget.enabled
        ? hover
            ? baseColor.withValues(alpha:1)
            : baseColor.withValues(alpha:0.8)
        : baseColor.withValues(alpha:0.2);
    return tooltip(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onTap : null,
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => hover = true),
                onExit: (_) => setState(() => hover = false),
                child: widget.asset.widget(size: widget.size, color: color))));
  }

  Widget tooltip({required Widget child}) => widget.tooltip != null
      ? Tooltip(message: widget.tooltip, child: child)
      : child;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
enum AEButtonStyle { outlined, filled, transparent }

////////////////////////////////////////////////////////////////////////////////////////////////////
class UITextButton extends StatefulWidget {
  final UIIcon? icon;
  final String? text;
  final VoidCallback? onTap;
  final AEButtonStyle style;
  final MainAxisSize mainAxisSize;
  final UISize size;
  final EdgeInsetsGeometry? padding;
  const UITextButton(
      {super.key,
      this.icon,
      this.text,
      this.onTap,
      this.style = AEButtonStyle.outlined,
      this.size = UISize.medium,
      this.mainAxisSize = MainAxisSize.min,
      this.padding});
  @override
  State<UITextButton> createState() => _UITextButtonState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _UITextButtonState extends State<UITextButton> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: InkWell(
            onTap: widget.onTap,
            child: AnimatedContainer(
                duration: aes.fadeDuration,
                padding: widget.size.padding,
                decoration: BoxDecoration(
                    boxShadow: widget.style == AEButtonStyle.outlined && hover
                        ? [
                            BoxShadow(
                                color: ColorScheme.of(context)
                                    .onSurface
                                    .withValues(alpha:0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ]
                        : [],
                    border: Border.all(
                        color: widget.style == AEButtonStyle.outlined
                            ? ColorScheme.of(context).onSurface.withValues(alpha:0.6)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                    color: widget.style == AEButtonStyle.outlined
                        ? ColorScheme.of(context).surface
                        : widget.style == AEButtonStyle.transparent
                            ? (hover
                                ? ColorScheme.of(context)
                                    .onSurface
                                    .withValues(alpha:0.1)
                                : Colors.transparent)
                            : hover
                                ? ColorScheme.of(context).inversePrimary
                                : ColorScheme.of(context)
                                    .inversePrimary
                                    .withValues(alpha:0.8)),
                child: Row(mainAxisSize: widget.mainAxisSize, children: [
                  if (widget.icon != null) ...[
                    widget.icon!.widget(size: widget.size, color: color),
                    if (widget.text != null) const SizedBox(width: 5)
                  ],
                  if (widget.mainAxisSize == MainAxisSize.max)
                    Expanded(child: Center(child: text))
                  else
                    text
                ]))));
  }

  Color get color => (widget.style == AEButtonStyle.filled
          ? Colors.white
          : ColorScheme.of(context).onSurface)
      .withValues(alpha:hover ? 1 : 0.8);
  Widget get text => widget.text != null
      ? Text(widget.text!,
          style: widget.size.bodyStyle(context)!.copyWith(color: color))
      : Container();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
