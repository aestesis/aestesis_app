import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class UISelectItem extends StatefulWidget {
  final bool selected;
  final Widget child;
  final BoolCallback onChanged;
  final MainAxisSize mainAxisSize;
  final Color? color;
  const UISelectItem(
      {super.key,
      required this.selected,
      required this.child,
      required this.onChanged,
      this.mainAxisSize = MainAxisSize.max,
      this.color});

  @override
  State<UISelectItem> createState() => _UISelectItemState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _UISelectItemState extends State<UISelectItem> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? ColorScheme.of(context).inversePrimary;
    return InkWell(
        onTap: () {
          widget.onChanged(!widget.selected);
        },
        child: MouseRegion(
            onEnter: (_) => setState(() => hovered = true),
            onExit: (_) => setState(() => hovered = false),
            child: Container(
                width: widget.mainAxisSize == MainAxisSize.max
                    ? double.infinity
                    : null,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: widget.selected
                        ? color.withValues(alpha:1)
                        : hovered
                            ? color.withValues(alpha:0.3)
                            : null),
                child: widget.child)));
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
