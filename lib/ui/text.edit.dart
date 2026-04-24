import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class TextEdit extends StatefulWidget {
  final String initValue;
  final bool grayed;
  final StringCallback? onChanged;
  const TextEdit(
      {super.key, this.initValue = '', this.onChanged, this.grayed = false});
  @override
  State<TextEdit> createState() => _TextEditState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _TextEditState extends State<TextEdit> {
  final controller = TextEditingController();
  final node = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.value = TextEditingValue(text: widget.initValue);
  }

  @override
  void didUpdateWidget(covariant TextEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initValue != oldWidget.initValue) {
      controller.value = TextEditingValue(text: widget.initValue);
    }
  }

  @override
  Widget build(BuildContext context) => TextField(
      controller: controller,
      focusNode: node,
      style: TextTheme.of(context).bodyMedium!.copyWith(
          color: 
              ColorScheme.of(context).onPrimaryContainer.withValues(alpha:widget.grayed ? 0.3 : 0.8)
              ),
      onChanged: (v) => widget.onChanged?.call(v),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
      ));
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
