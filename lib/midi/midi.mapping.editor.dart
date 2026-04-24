import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../ui/button.dart';
import '../ui/menu.button.dart';
import '../ui/menu.grid.dart';
import '../ui/icon.dart';
import '../ui/menu.dart';
import '../ui/select.dart';
import '../module.dart';
import 'midi.io.message.dart';
import 'midi.mapping.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingEditor extends StatefulWidget {
  final VoidCallback? onClose;
  const MidiMappingEditor({super.key, this.onClose});
  @override
  State<MidiMappingEditor> createState() => _MidiMappingEditorState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _MidiMappingEditorState extends State<MidiMappingEditor> {
  late final StreamSubscription controlChangeSubscription;
  bool midiActivated = true;
  Control? selected;
  @override
  void initState() {
    super.initState();
    controlChangeSubscription =
        aes.bus.on<ControlChangeEvent>().listen((event) {
      if (!midiActivated && event.source != ControlChangeSource.ui) {
        return;
      }
      setState(() {
        selected = event.control;
      });
    });
  }

  @override
  void dispose() {
    controlChangeSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          height: 30,
          decoration: BoxDecoration(
              color: ColorScheme.of(context).primaryContainer,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            UIIcon.mapping.widget(
                size: UISize.medium,
                color: ColorScheme.of(context).onPrimaryContainer),
            const SizedBox(width: 10),
            const Text('MIDI Mapping'),
            const Spacer(),
            UIIconButton(
                tooltip: 'External selection',
                asset: midiActivated ? UIIcon.input : UIIcon.tv,
                onTap: () {
                  setState(() {
                    midiActivated = !midiActivated;
                  });
                }),
            const SizedBox(width: 10),
            UIIconButton(
                tooltip: 'Close',
                asset: UIIcon.close,
                onTap: () {
                  widget.onClose?.call();
                })
          ])),
      Container(
          color: ColorScheme.of(context).primaryContainer.withValues(alpha:0.5),
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...aes.composition!.modules
                  .whereType<Module>()
                  .map((m) => ModuleControls(
                      module: m,
                      selected: selected,
                      onChanged: (c) {
                        setState(() {
                          selected = c;
                        });
                      }))
            ]),
            if (selected != null)
              Expanded(
                  child:
                      Center(child: ModuleControlMapping(control: selected!)))
          ]))
    ]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ModuleControlMapping extends StatefulWidget {
  final Control control;
  const ModuleControlMapping({super.key, required this.control});
  @override
  State<ModuleControlMapping> createState() => _ModuleControlMappingState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ModuleControlMappingState extends State<ModuleControlMapping> {
  late final StreamSubscription midiMessageSubscription;
  late final Timer timer;
  final List<MidiMessageTimed> messages = [];
  double get time => DateTime.now().millisecondsSinceEpoch / 1000;
  @override
  void initState() {
    const keptMessages = 8;
    super.initState();
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
      while (messages.isNotEmpty && messages.first.time < time - 10) {
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
    midiMessageSubscription.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapping = aes.midi.mapping.get(control: widget.control);
    return Container(
        width: 500,
        decoration: BoxDecoration(
            color: ColorScheme.of(context).primaryContainer.withValues(alpha:0.5),
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 30,
              decoration: BoxDecoration(
                  color: ColorScheme.of(context).primaryContainer,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                Expanded(
                    child: Text(widget.control.name,
                        style: TextTheme.of(context).bodyMedium))
              ])),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mapping == null)
                      padding(Row(children: [
                        Text('No mapping', style: TextTheme.of(context).bodySmall),
                        const Spacer(),
                        UIIconButton(
                            asset: UIIcon.add,
                            onTap: () {
                              aes.midi.mapping.create(control: widget.control);
                              setState(() {});
                            })
                      ]))
                    else
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [...mapWidgets(mapping)]),
                    if (messages.isNotEmpty) ...[
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 5, bottom: 5, top: 10),
                          child: Text('Messages',
                              style: TextTheme.of(context).bodySmall)),
                      Container(
                          height: 0.5, color: ColorScheme.of(context).primary),
                      const SizedBox(height: 5),
                      ...messages.map((m) => InkWell(
                          onTap: widget.control.type.canHandle(m.message)
                              ? () {
                                  final map = mapping ??
                                      aes.midi.mapping
                                          .create(control: widget.control);
                                  map.midiMap(m.message);
                                  setState(() {});
                                }
                              : null,
                          child: padding(Text(m.message.description,
                              style: TextTheme.of(context).bodySmall!.apply(
                                  color: ColorScheme.of(context)
                                      .onSurface
                                      .withValues(alpha:0.6))))))
                    ],
                  ]))
        ]));
  }

  List<Widget> mapWidgets(MidiMappingControl mapping) {
    return [
      padding(Row(children: [
        Text('Channels', style: TextTheme.of(context).bodySmall),
        const Spacer(),
        ...List.generate(16, (i) => i).map((i) => UISelectItem(
            mainAxisSize: MainAxisSize.min,
            selected: mapping.channel == i,
            onChanged: (v) {
              if (v) {
                mapping.channel = i;
              }
              setState(() {});
              mapping.map();
            },
            child: Text('${i + 1}', style: TextTheme.of(context).bodySmall)))
      ])),
      const SizedBox(height: 10),
      Row(children: [
        ModuleMidiMappingType(
            controlType: widget.control.type,
            mappingType: mapping.mappingType,
            onChanged: (v) {
              mapping.mappingType = v;
              setState(() {});
              mapping.map();
            }),
        const Spacer(),
        if (mapping.mappingType == MidiMappingType.control) ...[
          UIGridMenu<int>(
              items: [
                ...List.generate(
                    128, (i) => UIMenuItem<int>(value: i, text: '$i'))
              ],
              value: mapping.mappingValue,
              onChanged: (v) {
                mapping.mappingValue = v;
                setState(() {});
                mapping.map();
              })
        ],
        if (mapping.mappingType == MidiMappingType.note) ...[
          UIGridMenu<int>(
              items: [
                ...List.generate(128,
                    (i) => UIMenuItem<int>(value: i, text: midiNoteName(i)))
              ],
              value: mapping.mappingValue,
              onChanged: (v) {
                mapping.mappingValue = v;
                setState(() {});
                mapping.map();
              })
        ]
      ]),
      if (mapping is MidiMappingControlInteger) ...[],
      if (mapping is MidiMappingControlUnit) ...[],
      if (mapping is MidiMappingControlFloat) ...[],
      if (mapping is MidiMappingControlBoolean) ...[],
      if (mapping is MidiMappingControlColor) ...[
        const SizedBox(height: 10),
        Row(children: [
          Text('Color', style: TextTheme.of(context).bodySmall),
          const Spacer(),
          for (final mode in MidiMappingControlColorMode.values)
            UISelectItem(
                mainAxisSize: MainAxisSize.min,
                selected: mapping.mode == mode,
                onChanged: (v) {
                  if (v) {
                    mapping.mode = mode;
                  }
                  setState(() {});
                  mapping.map();
                },
                child: Text(mode.name.capitalized,
                    style: TextTheme.of(context).bodySmall))
        ])
      ],
    ];
  }

  Widget padding(Widget child) {
    return Padding(padding: const EdgeInsets.only(left: 5), child: child);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ModuleMidiMappingType extends StatelessWidget {
  final ControlType controlType;
  final MidiMappingType mappingType;
  final Function(MidiMappingType)? onChanged;
  const ModuleMidiMappingType(
      {super.key,
      required this.mappingType,
      this.onChanged,
      required this.controlType});

  @override
  Widget build(BuildContext context) {
    return UIMenuTextButton<MidiMappingType>(
        menu: [
          ...controlType.availableMappings
              .map((e) => UIMenuItem(value: e, text: e.name.capitalized))
        ],
        value: mappingType,
        onChanged: (v) {
          onChanged?.call(v);
        });
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ModuleControls extends StatelessWidget {
  final Module module;
  final Control? selected;
  final void Function(Control?)? onChanged;
  const ModuleControls(
      {super.key, required this.module, this.selected, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        module.type.icon.widget(size: UISize.medium),
        const SizedBox(width: 5),
        Text(module.name, style: TextTheme.of(context).bodyMedium)
      ]),
      ...module.controls!.map((c) => Row(children: [
            const SizedBox(width: 30),
            UISelectItem(
                mainAxisSize: MainAxisSize.min,
                selected: c!.equals(selected),
                onChanged: (v) {
                  onChanged!(v ? c : null);
                },
                child: Text(c.name, style: TextTheme.of(context).bodySmall))
          ]))
    ]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
