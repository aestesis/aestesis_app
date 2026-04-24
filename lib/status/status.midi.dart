import 'dart:async';

import 'package:bb.flutter/bb.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/svg.dart';

import '../aestesis.dart';
import '../midi/midi.io.dart';
import '../midi/midi.io.message.dart';
import '../ui/select.dart';
import '../window.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusMidi extends StatefulWidget {
  const StatusMidi({super.key});
  @override
  State<StatusMidi> createState() => _StatusMidiState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusMidiState extends State<StatusMidi> with TickerProviderStateMixin {
  late final ticker = createTicker((_) {
    midiActivity = midiActivity * 0.9;
    clockActivity = clockActivity * 0.9;
    if ((midiActivity > 0.01 || clockActivity > 0.01) && mounted) {
      setState(() {});
    }
  });
  bool visible = false;
  bool hover = false;
  double midiActivity = 0;
  double clockActivity = 0;
  int clockCount = 0;
  double bpm = 120;
  double time = 0;
  bool tapOuside = false;
  late final StreamSubscription midiSubscription;
  late final StreamSubscription midiMessageSubscription;
  @override
  void initState() {
    super.initState();
    midiSubscription = aes.midi.onDevicesChanged.listen((_) => setState(() {}));
    midiMessageSubscription = aes.midi.onMidiMessage.listen((event) {
      if (event is MidiIOChannelMessage) {
        midiActivity = 1;
      } else if (event is MidiIOMessageClock) {
        if (clockCount % 24 == 0) {
          clockActivity = 1;
          final t = DateTime.now().millisecondsSinceEpoch / 1000;
          if (time != 0) {
            bpm = bpm * 0.8 + (60 / (t - time)) * 0.2;
          }
          time = t;
        }
        clockCount++;
      } else if (event is MidiIOSystemMessage &&
          event.type == MidiIOMessageType.start) {
        clockCount = 0;
      } else if (event is MidiIOMessageSongPosition) {
        Debug.info("song position ${event.position}");
      }
    });
    ticker.start();
  }

  @override
  void dispose() {
    midiSubscription.cancel();
    midiMessageSubscription.cancel();
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        ColorScheme.of(context).onSurface.withValues(alpha:visible || hover ? 1 : 0.8);
    final tt = TextTheme.of(context).bodySmall!.apply(color: color);
    return WindowBlur(
        onBlur: () => setState(() => visible = false),
        child: PortalTarget(
            visible: visible,
            anchor: const Aligned(
                shiftToWithinBound: AxisFlag(x: true),
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
                child: StatusMidiSettings(
                    onClosed: () => setState(() {
                          visible = false;
                        }),
                    onChanged: () {
                      aes.bus.fire(SettingsChangeEvent());
                      setState(() {});
                    })),
            child: Tooltip(
                message: 'Midi Settings',
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
                              SvgPicture.asset('assets/svg/ui/midi.port.svg',
                                  width: 14,
                                  colorFilter: ColorFilter.mode(
                                      color.withValues(alpha:
                                          0.6 + midiActivity * 0.4),
                                      BlendMode.srcIn)),
                              const SizedBox(width: 5),
                              if (aes.midi.selectedSources.isNotEmpty) ...[
                                if (aes.midi.selectedSources.length == 1)
                                  Text(aes.midi.selectedSources.first.name,
                                      style: tt)
                                else
                                  Text(
                                      '${aes.midi.selectedSources.length} devices',
                                      style: tt)
                              ] else
                                Text('No device', style: tt),
                              const SizedBox(width: 10),
                              SvgPicture.asset('assets/svg/ui/heart.svg',
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                      color.withValues(alpha:
                                          0.6 + clockActivity * 0.4),
                                      BlendMode.srcIn)),
                              SizedBox(
                                  width: 40,
                                  child: Text(bpm.toStringAsFixed(1),
                                      style: tt, textAlign: TextAlign.end)),
                            ])))))));
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusMidiSettings extends StatefulWidget {
  final VoidCallback? onChanged;
  final VoidCallback? onClosed;
  const StatusMidiSettings({super.key, this.onChanged, this.onClosed});
  @override
  State<StatusMidiSettings> createState() => _StatusMidiSettingsState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusMidiSettingsState extends State<StatusMidiSettings> {
  late final Timer timer;
  late final StreamSubscription midiSubscription;
  late final StreamSubscription midiMessageSubscription;
  final List<MidiMessageTimed> messages = [];
  double get time => DateTime.now().millisecondsSinceEpoch / 1000;
  @override
  void initState() {
    const keptMessages = 8;
    super.initState();
    midiSubscription = aes.midi.onDevicesChanged.listen((_) => setState(() {}));
    midiMessageSubscription = aes.midi.onMidiMessage.listen((event) {
      if (event is! MidiIOChannelMessage) {
        return;
      }
      messages.add(MidiMessageTimed(message: event));
      if (messages.length > keptMessages) {
        messages.removeRange(0, messages.length - keptMessages);
      }
      if (mounted) {
        setState(() {});
      }
    });
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      bool changed = false;
      while (messages.isNotEmpty && messages.first.time < time - 5) {
        messages.removeAt(0);
        changed = true;
      }
      if (mounted && changed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    midiSubscription.cancel();
    midiMessageSubscription.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 540,
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
            child: Text('Midi Settings', style: TextTheme.of(context).bodyMedium),
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
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(children: [
                              SizedBox(
                                  width: 162,
                                  child: Text('Inputs',
                                      style: TextTheme.of(context).bodySmall)),
                              Text('Channels',
                                  style: TextTheme.of(context).bodySmall)
                            ])),
                        Container(
                            height: 0.5, color: ColorScheme.of(context).primary),
                        const SizedBox(height: 5),
                        ...BB.separator(
                            separatorBuilder: () => const SizedBox(height: 2),
                            items: aes.midi.sources.map((s) => Row(children: [
                                  Expanded(
                                      child: UISelectItem(
                                          selected: aes.midi.selectedSources
                                              .contains(s),
                                          onChanged: (v) {
                                            if (v) {
                                              aes.midi.selectSource(s);
                                            } else {
                                              aes.midi.unselectSource(s);
                                            }
                                            setState(() {});
                                            widget.onChanged?.call();
                                          },
                                          child: Text(
                                              '${s.name} [${s.number + 1}]',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextTheme.of(context)
                                                  .bodySmall))),
                                  if (aes.midi.selectedSources.contains(s))
                                    MidiChannels(source: s, onChanged: () {
                                      widget.onChanged?.call();
                                    })
                                  else
                                    IgnorePointer(
                                        child: Opacity(
                                            opacity: 0.2,
                                            child: MidiChannels(source: s)))
                                ]))),
                        if (messages.isNotEmpty) ...[
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text('Messages',
                                  style: TextTheme.of(context).bodySmall)),
                          Container(
                              height: 0.5, color: ColorScheme.of(context).primary),
                          const SizedBox(height: 5),
                          ...messages.map((m) => Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(m.message.description,
                                  style: TextTheme.of(context).bodySmall!.apply(
                                      color: ColorScheme.of(context)
                                          .onSurface
                                          .withValues(alpha:0.6)))))
                        ],
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(children: [
                              SizedBox(
                                  width: 162,
                                  child: Text('Outputs',
                                      style: TextTheme.of(context).bodySmall))
                            ])),
                        Container(
                            height: 0.5, color: ColorScheme.of(context).primary),
                        const SizedBox(height: 5),
                        ...BB.separator(
                            separatorBuilder: () => const SizedBox(height: 2),
                            items:
                                aes.midi.destinations.map((d) => Row(children: [
                                      Expanded(
                                          child: UISelectItem(
                                              selected: aes
                                                  .midi.selectedDestinations
                                                  .contains(d),
                                              onChanged: (v) {
                                                if (v) {
                                                  aes.midi.selectDestination(d);
                                                } else {
                                                  aes.midi
                                                      .unselectDestination(d);
                                                }
                                                setState(() {});
                                                widget.onChanged?.call();
                                              },
                                              child: Text(
                                                  '${d.name} [${d.number + 1}]',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextTheme.of(context)
                                                      .bodySmall)))
                                    ]))),
                      ]))))
        ]));
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiChannels extends StatefulWidget {
  final MidiIOSource source;
  final VoidCallback? onChanged;
  const MidiChannels({super.key, required this.source, this.onChanged});
  @override
  State<MidiChannels> createState() => _MidiChannelsState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _MidiChannelsState extends State<MidiChannels> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (int i = 1; i <= 16; i++) ...[
        const SizedBox(width: 2),
        UISelectItem(
            mainAxisSize: MainAxisSize.min,
            selected:
                aes.midi.sourceChannelFilters[widget.source]!.isEnabled(i - 1),
            onChanged: (v) {
              aes.midi.sourceChannelFilters[widget.source]!.set(i - 1, v);
              setState(() {});
              widget.onChanged?.call();
            },
            child: Text('$i', style: TextTheme.of(context).bodySmall))
      ]
    ]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
