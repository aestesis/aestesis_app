import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import '../aestesis.dart';
import '../ui/select.dart';
import '../window.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusVideo extends StatefulWidget {
  const StatusVideo({super.key});
  @override
  State<StatusVideo> createState() => _StatusVideoState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusVideoState extends State<StatusVideo> {
  late final StreamSubscription settingsSubscribtion;
  bool visible = false;
  bool hover = false;
  bool tapOuside = false;
  @override
  void initState() {
    super.initState();
    settingsSubscribtion = aes.bus.on<SettingsUpdateEvent>().listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    settingsSubscribtion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorScheme.of(
      context,
    ).onSurface.withValues(alpha: visible || hover ? 1 : 0.8);
    final tt = TextTheme.of(context).bodySmall!.apply(color: color);
    return WindowBlur(
      onBlur: () => setState(() => visible = false),
      child: PortalTarget(
        visible: visible,
        anchor: const Aligned(
          offset: Offset(0, -6),
          follower: Alignment.bottomCenter,
          target: Alignment.topRight,
        ),
        portalFollower: TapRegion(
          onTapOutside: (_) {
            setState(() => visible = false);
            tapOuside = true;
            Timer(const Duration(milliseconds: 300), () => tapOuside = false);
          },
          child: const StatusVideoSettings(),
        ),
        child: Tooltip(
          message: 'Video Settings',
          child: MouseRegion(
            onEnter: (_) => setState(() => hover = true),
            onExit: (_) => setState(() => hover = false),
            child: InkWell(
              onTap: () {
                if (tapOuside) return;
                setState(() => visible = true);
              },
              child: Container(
                color: visible
                    ? ColorScheme.of(context).primaryContainer
                    : hover
                    ? ColorScheme.of(
                        context,
                      ).primaryContainer.withValues(alpha: 0.3)
                    : null,
                height: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (aes.compositionSettings != null) ...[
                      Icon(
                        Icons.aspect_ratio,
                        size: 16,
                        color: color.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${aes.compositionSettings!.width.toStringAsFixed(0)} x ${aes.compositionSettings!.height.toStringAsFixed(0)}',
                        style: tt,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusVideoSettings extends StatefulWidget {
  const StatusVideoSettings({super.key});
  @override
  State<StatusVideoSettings> createState() => _StatusVideoSettingsState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusVideoSettingsState extends State<StatusVideoSettings> {
  late final StreamSubscription settingsSubscribtion;
  @override
  void initState() {
    super.initState();
    settingsSubscribtion = aes.bus.on<SettingsUpdateEvent>().listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    settingsSubscribtion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 66,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorScheme.of(context).primaryContainer,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: ColorScheme.of(context).inversePrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Text(
              'Video Settings',
              style: TextTheme.of(context).bodyMedium,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  'Resolution',
                                  style: TextTheme.of(context).bodySmall,
                                ),
                              ),
                              Container(
                                height: 0.5,
                                color: ColorScheme.of(context).primary,
                              ),
                              const SizedBox(height: 5),
                              ...VideoResolution.values.mapIndexed(
                                (i, c) => UISelectItem(
                                  selected:
                                      aes.compositionSettings?.width ==
                                          c.size.width &&
                                      aes.compositionSettings?.height ==
                                          c.size.height,
                                  onChanged: (v) {
                                    if (v == true) {
                                      aes.compositionSettings!.width =
                                          c.size.width;
                                      aes.compositionSettings!.height =
                                          c.size.height;
                                      aes.bus.fire(SettingsChangeEvent());
                                    }
                                  },
                                  child: Text(
                                    c.label,
                                    style: TextTheme.of(context).bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  'Frame Rate',
                                  style: TextTheme.of(context).bodySmall,
                                ),
                              ),
                              Container(
                                height: 0.5,
                                color: ColorScheme.of(context).primary,
                              ),
                              const SizedBox(height: 5),
                              ...VideoFps.values.mapIndexed(
                                (i, c) => UISelectItem(
                                  selected:
                                      c ==
                                      VideoFps.fromFps(
                                        aes.compositionSettings!.fps,
                                      ),
                                  onChanged: (v) {
                                    if (v == true) {
                                      aes.compositionSettings!.fps = c.fps;
                                      aes.bus.fire(SettingsChangeEvent());
                                    }
                                  },
                                  child: Text(
                                    c.label,
                                    style: TextTheme.of(context).bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum VideoResolution {
  wsvga,
  hd,
  hdp,
  fullhd,
  reels,
  square,
  fourk,
  heightk;

  Size get size {
    switch (this) {
      case VideoResolution.wsvga:
        return const Size(1024, 576);
      case VideoResolution.hd:
        return const Size(1280, 720);
      case VideoResolution.hdp:
        return const Size(1600, 900);
      case VideoResolution.fullhd:
        return const Size(1920, 1080);
      case VideoResolution.reels:
        return const Size(1080, 1920);
      case VideoResolution.square:
        return const Size(1920, 1920);
      case VideoResolution.fourk:
        return const Size(3840, 2160);
      case VideoResolution.heightk:
        return const Size(7680, 4320);
    }
  }

  double get ratio => size.width / size.height;

  String get label {
    switch (this) {
      case VideoResolution.wsvga:
        return 'WSVGA (1024x576)';
      case VideoResolution.hd:
        return 'HD (1280x720)';
      case VideoResolution.hdp:
        return 'HD+ (1600x900)';
      case VideoResolution.fullhd:
        return 'FHD (1920x1080)';
      case VideoResolution.reels:
        return 'Reels (1080x1920)';
      case VideoResolution.square:
        return 'Square (1920x1920)';
      case VideoResolution.fourk:
        return '4K (3840x2160)';
      case VideoResolution.heightk:
        return '8K (7680x4320)';
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
enum VideoFps {
  fps24,
  fps25,
  fps30,
  fps60,
  fps120;

  double get fps {
    switch (this) {
      case VideoFps.fps24:
        return 24;
      case VideoFps.fps25:
        return 25;
      case VideoFps.fps30:
        return 30;
      case VideoFps.fps60:
        return 60;
      case VideoFps.fps120:
        return 120;
    }
  }

  String get label {
    switch (this) {
      case VideoFps.fps24:
        return '24 fps';
      case VideoFps.fps25:
        return '25 fps';
      case VideoFps.fps30:
        return '30 fps';
      case VideoFps.fps60:
        return '60 fps';
      case VideoFps.fps120:
        return '120 fps';
    }
  }

  static VideoFps? fromFps(double fps) {
    if (fps == 24) return VideoFps.fps24;
    if (fps == 25) return VideoFps.fps25;
    if (fps == 30) return VideoFps.fps30;
    if (fps == 60) return VideoFps.fps60;
    if (fps == 120) return VideoFps.fps120;
    return null;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
