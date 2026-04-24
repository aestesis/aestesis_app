import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'aestesis.dart';
import 'core/flutter.extensions.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class AEWindowManager extends StatefulWidget {
  final Widget child;
  const AEWindowManager({super.key, required this.child});
  @override
  State<AEWindowManager> createState() => _AEWindowManagerState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AEWindowManagerState extends State<AEWindowManager> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
  @override
  void onWindowResize() async {
    windowUpdate();
    aes.bus.fire(const WindowBlurEvent());
  }

  @override
  void onWindowMove() async {
    windowUpdate();
  }

  @override
  void onWindowBlur() {
    aes.bus.fire(const WindowBlurEvent());
    super.onWindowBlur();
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    SystemNavigator.pop();
  }

  Future<void> windowUpdate() async {
    final r = await windowManager.getBounds();
    aes['windowBounds'] = r.toJson();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class WindowBlurEvent {
  const WindowBlurEvent();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class WindowBlur extends StatefulWidget {
  final Widget child;
  final VoidCallback onBlur;
  const WindowBlur({super.key, required this.child, required this.onBlur});
  @override
  State<WindowBlur> createState() => _WindowBlurState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _WindowBlurState extends State<WindowBlur> {
  late final StreamSubscription blurSubscription;
  @override
  void initState() {
    super.initState();
    blurSubscription = aes.bus.on<WindowBlurEvent>().listen((event) {
      widget.onBlur();
    });
  }

  @override
  void dispose() {
    blurSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
