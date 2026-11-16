import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../aestesis.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class TrafficLights extends StatefulWidget {
  const TrafficLights({super.key});
  @override
  State<TrafficLights> createState() => _TrafficLightsState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _TrafficLightsState extends State<TrafficLights> {
  StreamSubscription? sub;
  bool enabled = true;
  bool hovered = false;
  @override
  void initState() {
    super.initState();
    sub = aes.bus.on<WindowEvent>().listen((we) {
      switch (we) {
        case WindowFocusedEvent():
          enabled = true;
          setState(() {});
        case WindowBlurredEvent():
          enabled = false;
          setState(() {});
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hovered = true;
        setState(() {});
      },
      onExit: (_) {
        hovered = false;
        setState(() {});
      },
      child: Row(
        mainAxisSize: .min,
        spacing: 8,
        children: [
          TrafficLight(
            normal: 'window.close.normal',
            hover: 'window.close.hover',
            press: 'window.close.press',
            enabled: enabled,
            hovered: hovered,
            onPress: () {
              aes.window.close();
            },
          ),
          TrafficLight(
            normal: 'window.minimize.normal',
            hover: 'window.minimize.hover',
            press: 'window.minimize.press',
            enabled: enabled,
            hovered: hovered,
            onPress: () {
              aes.window.minimize();
            },
          ),
          TrafficLight(
            normal: 'window.maximize.normal',
            hover: 'window.maximize.hover',
            press: 'window.maximize.press',
            enabled: enabled,
            hovered: hovered,
            onPress: () {
              aes.window.isFullScreen = !aes.window.isFullScreen;
            },
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class TrafficLight extends StatefulWidget {
  final bool enabled;
  final bool hovered;
  final String normal;
  final String hover;
  final String press;
  final VoidCallback onPress;
  const TrafficLight({
    super.key,
    required this.normal,
    required this.hover,
    required this.press,
    required this.onPress,
    required this.enabled,
    required this.hovered,
  });
  @override
  State<TrafficLight> createState() => _TrafficLightState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
class _TrafficLightState extends State<TrafficLight> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final a = widget.enabled
        ? (widget.hovered
              ? (pressed ? widget.press : widget.hover)
              : widget.normal)
        : 'window.blur';
    String asset = 'assets/svg/ui/$a.svg';
    return GestureDetector(
      onTapDown: (_) {
        pressed = true;
        setState(() {});
      },
      onTapUp: (_) {
        pressed = false;
        setState(() {});
      },
      onTapCancel: () {
        pressed = false;
        setState(() {});
      },
      onTap: widget.onPress,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: SvgPicture.asset(asset, width: 12),
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
