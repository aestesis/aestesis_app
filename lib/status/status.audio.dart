import 'dart:async';
import 'dart:math';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/svg.dart';

import '../aestesis.dart';
import '../ui/select.dart';
import '../window.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusAudio extends StatefulWidget {
  const StatusAudio({super.key});
  @override
  State<StatusAudio> createState() => _StatusAudioState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusAudioState extends State<StatusAudio>
    with TickerProviderStateMixin {
  late final StreamSubscription settingsSubscribtion;
  late final StreamSubscription audioSubscribtion;
  late final ticker = createTicker((_) {
    level = level * 0.9;
    level = min(1, level + peak * 0.1);
    if (level > 0.01 && mounted) {
      setState(() {});
    }
  });
  List<AudioDevice> devices = [];
  bool visible = false;
  bool hover = false;
  double level = 0;
  double peak = 0;
  bool tapOuside = false;
  @override
  void initState() {
    super.initState();
    aes.alib.audioDevices().then((devices) {
      setState(() {
        this.devices = [
          ...devices
              .whereType<AudioDevice>()
              .where((d) => d.inputChannels.isNotEmpty)
        ];
      });
    });
    settingsSubscribtion = aes.bus.on<SettingsUpdateEvent>().listen((_) {
      setState(() {});
    });
    audioSubscribtion = aes.bus.on<AudioEvent>().listen((event) {
      peak = event.audio.peak;
    });
    ticker.start();
  }

  @override
  void dispose() {
    settingsSubscribtion.cancel();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorScheme.of(context)
        .onSurface
        .withValues(alpha:visible || hover ? 1 : 0.8);
    return WindowBlur(
        onBlur: () => setState(() => visible = false),
        child: PortalTarget(
            visible: visible,
            anchor: const Aligned(
                offset: Offset(0, -6),
                follower: Alignment.bottomCenter,
                target: Alignment.topRight),
            portalFollower: TapRegion(
                onTapOutside: (_) {
                  setState(() => visible = false);
                  tapOuside = true;
                  Timer(const Duration(milliseconds: 300),
                      () => tapOuside = false);
                },
                child: const StatusAudioSettings()),
            child: Tooltip(
                message: 'Audio Input',
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
                                    ? ColorScheme.of(context)
                                        .primaryContainer
                                        .withValues(alpha:0.3)
                                    : null,
                            height: 24,
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              SvgPicture.asset('assets/svg/ui/audio.input.svg',
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                      color.withValues(alpha:0.4 + level * 0.6),
                                      BlendMode.srcIn)),
                              const SizedBox(width: 5),
                              Text(device?.name ?? 'No device',
                                  style: TextTheme.of(context)
                                      .bodySmall!
                                      .apply(color: color))
                            ])))))));
  }

  AudioDevice? get device => devices.firstWhereOrNull(
      (d) => d.name == aes.compositionSettings?.audioSettings?.deviceName);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusAudioSettings extends StatefulWidget {
  const StatusAudioSettings({super.key});
  @override
  State<StatusAudioSettings> createState() => _StatusAudioSettingsState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusAudioSettingsState extends State<StatusAudioSettings> {
  late final StreamSubscription settingsSubscribtion;
  List<AudioDevice> devices = [];
  @override
  void initState() {
    super.initState();
    aes.alib.audioDevices().then((devices) {
      setState(() {
        this.devices = [
          ...devices
              .whereType<AudioDevice>()
              .where((d) => d.inputChannels.isNotEmpty)
        ];
      });
    });
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
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 66),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorScheme.of(context).primaryContainer,
            boxShadow: [
              BoxShadow(
                  color: ColorScheme.of(context).primaryContainer.withValues(alpha:0.5),
                  blurRadius: 5,
                  offset: const Offset(0, 5))
            ]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: ColorScheme.of(context).inversePrimary,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Text('Audio Input', style: TextTheme.of(context).bodyMedium),
          ),
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text('Device',
                                style: TextTheme.of(context).bodySmall)),
                        Container(
                            height: 0.5, color: ColorScheme.of(context).primary),
                        const SizedBox(height: 5),
                        ...devices.map((d) => UISelectItem(
                            selected: d.name == audioSettings?.deviceName,
                            onChanged: (v) {
                              if (v == true) {
                                aes.compositionSettings!.audioSettings = AudioSettings(
                                    deviceName: d.name,
                                    leftChannel: 0,
                                    rightChannel:
                                        d.inputChannels.length > 1 ? 1 : 0);
                                aes.bus.fire(SettingsChangeEvent());
                              } else {
                                aes.compositionSettings!.audioSettings = null;
                                aes.bus.fire(SettingsChangeEvent());
                              }
                            },
                            child: Text(d.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextTheme.of(context).bodySmall))),
                        if (device != null) ...[
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text('Left Channel',
                                          style: TextTheme.of(context).bodySmall)),
                                  Container(
                                      height: 0.5,
                                      color: ColorScheme.of(context).primary),
                                  const SizedBox(height: 5),
                                  ...device!.inputChannels.mapIndexed((i, c) =>
                                      UISelectItem(
                                          selected:
                                              i == audioSettings?.leftChannel,
                                          onChanged: (v) {
                                            if (v == true) {
                                              aes.compositionSettings!.audioSettings =
                                                  AudioSettings(
                                                      deviceName: device!.name,
                                                      leftChannel: i,
                                                      rightChannel: audioSettings
                                                              ?.rightChannel ??
                                                          0);
                                              aes.bus
                                                  .fire(SettingsChangeEvent());
                                            }
                                          },
                                          child: Text(c.toString(),
                                              style: TextTheme.of(context)
                                                  .bodySmall)))
                                ])),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text('Right Channel',
                                          style: TextTheme.of(context).bodySmall)),
                                  Container(
                                      height: 0.5,
                                      color: ColorScheme.of(context).primary),
                                  const SizedBox(height: 5),
                                  ...device!.inputChannels.mapIndexed((i, c) =>
                                      UISelectItem(
                                          selected:
                                              i == audioSettings?.rightChannel,
                                          onChanged: (v) {
                                            if (v == true) {
                                              aes.compositionSettings!.audioSettings =
                                                  AudioSettings(
                                                      deviceName: device!.name,
                                                      leftChannel: audioSettings
                                                              ?.leftChannel ??
                                                          0,
                                                      rightChannel: i);
                                              aes.bus
                                                  .fire(SettingsChangeEvent());
                                            }
                                          },
                                          child: Text(c.toString(),
                                              style: TextTheme.of(context)
                                                  .bodySmall)))
                                ]))
                          ])
                        ]
                      ]))))
        ]));
  }

  AudioSettings? get audioSettings => aes.compositionSettings?.audioSettings;
  AudioDevice? get device =>
      devices.firstWhereOrNull((d) => d.name == audioSettings?.deviceName);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
