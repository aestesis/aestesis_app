// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/scheduler.dart';
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
class _TrafficLightState extends State<TrafficLight>
    with TickerProviderStateMixin {
  bool pressed = false;
  List<OpaWidget> children = [];
  Ticker? ticker;
  void tickStart() {
    ticker?.stop();
    ticker = createTicker((_) {
      if (children.isNotEmpty) {
        if (children.last.opacity < 1) {
          children.last.opacity = 0.1 + children.last.opacity * 0.9;
          if (children.last.opacity > 0.99) {
            children.last.opacity = 1;
          }
          setState(() {});
        } else if (children.length > 1) {
          children = [children.last];
          setState(() {});
          ticker?.stop();
          ticker = null;
        }
      }
    });
    ticker?.start();
  }

  @override
  void dispose() {
    ticker?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.enabled
        ? (widget.hovered
              ? (pressed ? widget.press : widget.hover)
              : widget.normal)
        : 'window.blur';
    final asset = 'assets/svg/ui/$a.svg';
    if (children.isEmpty || children.last.asset != asset) {
      children.add(OpaWidget(key: UniqueKey(), asset: asset));
      tickStart();
    }
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
      child: Stack(children: [...children.map((c) => c.computed)]),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
class OpaWidget {
  Key key;
  String asset;
  double opacity;
  OpaWidget({required this.key, required this.asset, this.opacity = 0});
  Widget get computed => Opacity(
    opacity: opacity,
    child: SvgPicture.asset(key: key, asset, width: 14),
  );
}
///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
