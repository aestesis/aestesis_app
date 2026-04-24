import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';

/// ///////////////////////////////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////////////////////////////
class NativeView extends StatefulWidget {
  final String moduleId;
  final String? assetId;
  final Color color;
  final double gain;
  final bool paused;
  const NativeView(
      {super.key,
      required this.moduleId,
      this.assetId,
      this.color = Colors.white,
      this.gain = 1,
      this.paused = false});
  @override
  State<NativeView> createState() => _NativeViewState();
}

/// ///////////////////////////////////////////////////////////////////////////////////////////////////////
class _NativeViewState extends State<NativeView> {
  late final StreamSubscription<AssetTexture> subs;
  @override
  void initState() {
    super.initState();
    subs = aes.textures.listen(
        moduleId: widget.moduleId,
        assetId: widget.assetId ?? widget.moduleId,
        onData: (t) {
          if (mounted) setState(() {});
        });
  }

  @override
  void dispose() {
    subs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = '${widget.moduleId}.${widget.assetId ?? widget.moduleId}';
    final t = aes.textures[key];
    if (t != null) {
      /*
      if (widget.moduleId == widget.assetId) {
        final module = aes.composition![widget.moduleId].name;
        Debug.info('NativeView: $module id: ${t.textureId}');
      }
      */
      return Texture(textureId: t.textureId, freeze: widget.paused);
    }
    return Container(color: Colors.black);
    /*
    Debug.info('NativeView: texture not found: $key, backing up with AlibView');
    return AlibView(
        moduleId: moduleId, assetId: assetId, color: color, paused: paused);
    */
  }
}
/// ///////////////////////////////////////////////////////////////////////////////////////////////////////
/// ///////////////////////////////////////////////////////////////////////////////////////////////////////

