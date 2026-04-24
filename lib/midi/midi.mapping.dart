import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb.flutter/bb.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../aestesis.dart';
import 'midi.io.message.dart';
import 'midi.manager.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMapping {
  final MidiManager midi;
  final Map<String, Set<MidiMappingControl>> _inMapping = {};
  final Map<String, MidiMappingControl> _mappedControls = {};
  MidiMapping({required this.midi}) {
    midi.onMidiMessage.listen((mm) {
      final controls = _inMapping[mm.key] ?? {};
      for (final c in controls) {
        c.updateFrom(mm);
      }
    });
  }

  void dispose() {
    clear();
  }

  void clear() {
    for (final control in _mappedControls.values) {
      control.dispose();
    }
    _inMapping.clear();
    _mappedControls.clear();
  }

  void update(Control control) {
    final mmc = get(control: control);
    if (mmc == null) return;
    mmc.update(control: control);
  }

  void add(String key, MidiMappingControl mmc) {
    _inMapping[key] ??= {};
    _inMapping[key]!.add(mmc);
    _mappedControls[mmc.control.key] = mmc;
  }

  void remove(MidiMappingControl mmc) {
    for (final key in _inMapping.keys) {
      _inMapping[key]!.remove(mmc);
    }
    _mappedControls.remove(mmc.control.key);
  }

  MidiMappingControl create({required Control control}) {
    if (existsMapping(control: control)) {
      throw Exception('MidiMapping: control mapping already exists');
    }
    final mmc = MidiMappingControl.from(mapping: this, control: control);
    mmc.map();
    return mmc;
  }

  MidiMappingControl? get({required Control control}) =>
      _mappedControls[control.key];

  bool existsMapping({required Control control}) =>
      _mappedControls.containsKey(control.key);

  Map<String, dynamic> get settings {
    return {
      'controls': _inMapping.values
          .expand((e) => e)
          .map((e) => e.toJson())
          .toList(growable: false)
    };
  }

  set settings(Map<String, dynamic> map) {
    clear();
    if (map['controls'] == null) {
      return;
    }
    for (final control in map['controls']) {
      final mmc = MidiMappingControl.fromJson(this, control);
      mmc.map();
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum MidiMappingType {
  note,
  control;

  bool canHandle(MidiIOMessage mm) {
    switch (this) {
      case MidiMappingType.note:
        return mm is MidiIOMessageNoteOn || mm is MidiIOMessageNoteOff;
      case MidiMappingType.control:
        return mm is MidiIOMessageControlChange;
    }
  }

  String toJson() {
    switch (this) {
      case MidiMappingType.note:
        return 'note';
      case MidiMappingType.control:
        return 'control';
    }
  }

  factory MidiMappingType.fromJson(String json) {
    switch (json) {
      case 'note':
        return MidiMappingType.note;
      case 'control':
        return MidiMappingType.control;
    }
    throw Exception('MidiMappingType: unknown json value');
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
extension MappingControlTypeExtension on ControlType {
  List<MidiMappingType> get availableMappings {
    switch (this) {
      case ControlType.float:
        return [MidiMappingType.note, MidiMappingType.control];
      case ControlType.unit:
        return [MidiMappingType.note, MidiMappingType.control];
      case ControlType.integer:
        return [MidiMappingType.note, MidiMappingType.control];
      case ControlType.boolean:
        return [MidiMappingType.note, MidiMappingType.control];
      case ControlType.color:
        return [MidiMappingType.note, MidiMappingType.control];
    }
  }

  bool canHandle(MidiIOMessage mm) {
    final availableMappings = this.availableMappings;
    if (availableMappings.isEmpty) {
      return false;
    }
    for (final map in availableMappings) {
      if (map.canHandle(mm)) {
        return true;
      }
    }
    return false;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControl {
  final String id = BB.alphaID();
  final MidiMapping mapping;
  final Control control;
  int channel;
  MidiMappingType mappingType;
  int mappingValue; // note or control
  MidiIOMessage? _lastMidiMessage;
  MidiMappingControl(
      {required this.mapping,
      required this.control,
      this.channel = 0,
      this.mappingType = MidiMappingType.control,
      this.mappingValue = 0});
  void dispose() {
    mapping.remove(this);
  }

  void updateFrom(MidiIOMessage mm) {
    _lastMidiMessage = mm;
  }

  void update({required Control control}) {
    this.control.value = control.value;
    this.control.count = control.count;
    for (final message in midiMessages) {
      if (_lastMidiMessage == message) {
        continue;
      }
      mapping.midi.sendMessage(message);
      _lastMidiMessage = message;
    }
  }

  List<MidiIOMessage> get midiMessages {
    throw UnimplementedError();
  }

  void map({int count = 1}) {
    mapping.remove(this);
    for (int i = 0; i < count; i++) {
      switch (mappingType) {
        case MidiMappingType.note:
          mapping.add(
              MidiIOMessage.keyFrom(
                  type: MidiIOMessageType.noteOn,
                  channel: channel,
                  number: mappingValue + i),
              this);
          mapping.add(
              MidiIOMessage.keyFrom(
                  type: MidiIOMessageType.noteOff,
                  channel: channel,
                  number: mappingValue + i),
              this);
        case MidiMappingType.control:
          mapping.add(
              MidiIOMessage.keyFrom(
                  type: MidiIOMessageType.controlChange,
                  channel: channel,
                  number: mappingValue + i),
              this);
      }
    }
  }

  ControlType get type => control.type;

  static MidiMappingControl from(
      {required MidiMapping mapping, required Control control}) {
    switch (control.type) {
      case ControlType.float:
        return MidiMappingControlFloat(mapping: mapping, control: control);
      case ControlType.unit:
        return MidiMappingControlUnit(mapping: mapping, control: control);
      case ControlType.integer:
        return MidiMappingControlInteger(mapping: mapping, control: control);
      case ControlType.boolean:
        return MidiMappingControlBoolean(mapping: mapping, control: control);
      case ControlType.color:
        return MidiMappingControlColor(mapping: mapping, control: control);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is MidiMappingControl) {
      return other.id == id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;

  void midiMap(MidiIOMessage mm) {
    if (!control.type.canHandle(mm)) {
      throw Exception('MidiMapping: control type mismatch');
    }
    if (mm is MidiIOChannelMessage) {
      channel = mm.channel;
    }
    if (mm is MidiIOMessageNote) {
      mappingType = MidiMappingType.note;
      mappingValue = mm.note;
    } else if (mm is MidiIOMessageControlChange) {
      mappingType = MidiMappingType.control;
      mappingValue = mm.control;
    }
    map();
  }

  Map<String, dynamic> toJson() {
    return {
      'control': control.key,
      'channel': channel,
      'mappingType': mappingType.toJson(),
      'mappingValue': mappingValue,
    };
  }

  factory MidiMappingControl.fromJson(
      MidiMapping mapping, Map<String, dynamic> map) {
    final control = ControlAppExtension.fromKey(map['control']);
    final mmc = MidiMappingControl.from(mapping: mapping, control: control);
    mmc.channel = map['channel'] ?? 0;
    mmc.mappingType = MidiMappingType.fromJson(map['mappingType']);
    mmc.mappingValue = map['mappingValue'];
    return mmc;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControlInteger extends MidiMappingControl {
  late final StreamSubscription _subscription;
  MidiMappingControlInteger(
      {required super.mapping,
      required super.control,
      super.channel = 0,
      super.mappingType = MidiMappingType.note,
      super.mappingValue = 0}) {
    _subscription = control.listen((control) {
      if (this.control.count != control.count) {
        this.control.count = control.count;
        map(count: control.count);
      }
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void map({int count = 1}) {
    switch (mappingType) {
      case MidiMappingType.note:
        super.map(count: control.count);
      case MidiMappingType.control:
        super.map(count: 1);
    }
  }

  @override
  void updateFrom(MidiIOMessage mm) {
    if (mm is MidiIOMessageControlChange) {
      control.value = (control.count * mm.value / 128).floorToDouble();
    } else if (mm is MidiIOMessageNoteOn) {
      control.value = (mm.note - mappingValue).toDouble();
    } else if (mm is MidiIOMessageNoteOff) {
      // do nothing
    } else {
      Debug.warning('MidiMapping: control type mismatch');
    }
    control.change(source: ControlChangeSource.midi);
    super.updateFrom(mm);
  }

  @override
  List<MidiIOMessage> get midiMessages {
    switch (mappingType) {
      case MidiMappingType.note:
        return [
          MidiIOMessageNoteOn(
              channel: channel,
              note: mappingValue,
              velocity: 128 * control.value ~/ control.count)
        ];
      case MidiMappingType.control:
        return [
          MidiIOMessageControlChange(
              channel: channel,
              control: mappingValue,
              value: 128 * control.value ~/ control.count)
        ];
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControlFloat extends MidiMappingControl {
  MidiMappingControlFloat(
      {required super.mapping,
      required super.control,
      super.channel,
      super.mappingType = MidiMappingType.control,
      super.mappingValue = 0});
  @override
  void updateFrom(MidiIOMessage mm) {
    if (mm is MidiIOMessageControlChange) {
      control.value = 2 * mm.value / 127 - 1;
    } else if (mm is MidiIOMessageNoteOn) {
      control.value = 2 * mm.velocity / 127 - 1;
    } else if (mm is MidiIOMessageNoteOff) {
      control.value = 2 * mm.velocity / 127 - 1;
    } else {
      Debug.warning('MidiMapping: control type mismatch');
    }
    control.change(source: ControlChangeSource.midi);
    super.updateFrom(mm);
  }

  @override
  List<MidiIOMessage> get midiMessages {
    Debug.info('MidiMappingControlFloat: midiMessages ${control.value}');
    switch (mappingType) {
      case MidiMappingType.note:
        return [
          MidiIOMessageNoteOn(
              channel: channel,
              note: mappingValue,
              velocity: 127 * (control.value + 1) ~/ 2)
        ];
      case MidiMappingType.control:
        return [
          MidiIOMessageControlChange(
              channel: channel,
              control: mappingValue,
              value: 127 * (control.value + 1) ~/ 2)
        ];
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControlUnit extends MidiMappingControl {
  //int? note;
  MidiMappingControlUnit(
      {required super.mapping,
      required super.control,
      super.channel,
      super.mappingType = MidiMappingType.control,
      super.mappingValue = 0});
  @override
  void updateFrom(MidiIOMessage mm) {
    if (mm is MidiIOMessageControlChange) {
      control.value = mm.value / 127;
    } else if (mm is MidiIOMessageNoteOn) {
      control.value = mm.velocity / 127;
    } else if (mm is MidiIOMessageNoteOff) {
      control.value = mm.velocity / 127;
    } else {
      Debug.warning('MidiMapping: control type mismatch');
    }
    control.change(source: ControlChangeSource.midi);
    super.updateFrom(mm);
  }

  @override
  List<MidiIOMessage> get midiMessages {
    if (!control.value.isFinite) {
      return [];
    }
    switch (mappingType) {
      case MidiMappingType.note:
        return [
          MidiIOMessageNoteOn(
              channel: channel,
              note: mappingValue,
              velocity: (127 * control.value).toInt())
        ];
      case MidiMappingType.control:
        return [
          MidiIOMessageControlChange(
              channel: channel,
              control: mappingValue,
              value: (127 * control.value).toInt())
        ];
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControlBoolean extends MidiMappingControl {
  MidiMappingControlBoolean(
      {required super.mapping,
      required super.control,
      super.channel = 0,
      super.mappingType = MidiMappingType.control,
      super.mappingValue = 0});
  @override
  void updateFrom(MidiIOMessage mm) {
    if (mm is MidiIOMessageControlChange) {
      control.value = mm.value >= 64 ? 1 : 0;
    } else if (mm is MidiIOMessageNoteOn) {
      control.value = mm.velocity > 0 ? 1 : 0;
    } else if (mm is MidiIOMessageNoteOff) {
      control.value = 0;
    } else {
      Debug.warning('MidiMapping: control type mismatch');
    }
    control.change(source: ControlChangeSource.midi);
    super.updateFrom(mm);
  }

  @override
  List<MidiIOMessage> get midiMessages {
    switch (mappingType) {
      case MidiMappingType.note:
        return [
          MidiIOMessageNoteOn(
              channel: channel,
              note: mappingValue,
              velocity: control.value > 0 ? 127 : 0)
        ];
      case MidiMappingType.control:
        return [
          MidiIOMessageControlChange(
              channel: channel,
              control: mappingValue,
              value: control.value > 0 ? 127 : 0)
        ];
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
enum MidiMappingControlColorMode { rgb, hsv, hsl }

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMappingControlColor extends MidiMappingControl {
  MidiMappingControlColorMode mode = MidiMappingControlColorMode.hsl;
  dynamic value;
  MidiMappingControlColor(
      {required super.mapping,
      required super.control,
      super.channel = 0,
      super.mappingType = MidiMappingType.control,
      super.mappingValue = 0});
  @override
  void map({int count = 3}) {
    super.map(count: count);
  }

  @override
  void updateFrom(MidiIOMessage mm) {
    switch (mode) {
      case MidiMappingControlColorMode.hsl:
        HSLColor hsl =
            (value is HSLColor) ? value : HSLColor.fromColor(control.color);
        if (mm is MidiIOMessageControlChange) {
          hsl = processHSL(hsl, mm.control - mappingValue, mm.value);
        } else if (mm is MidiIOMessageNote) {
          hsl = processHSL(hsl, mm.note - mappingValue, mm.velocity);
        } else {
          Debug.warning('MidiMapping: control type mismatch');
        }
        value = hsl;
        control.color = hsl.toColor();
      case MidiMappingControlColorMode.hsv:
        HSVColor hsv =
            (value is HSVColor) ? value : HSVColor.fromColor(control.color);
        if (mm is MidiIOMessageControlChange) {
          hsv = processHSV(hsv, mm.control - mappingValue, mm.value);
        } else if (mm is MidiIOMessageNote) {
          hsv = processHSV(hsv, mm.note - mappingValue, mm.velocity);
        } else {
          Debug.warning('MidiMapping: control type mismatch');
        }
        value = hsv;
        control.color = hsv.toColor();
      case MidiMappingControlColorMode.rgb:
        Color color = control.color;
        if (mm is MidiIOMessageControlChange) {
          color = processRGB(color, mm.control - mappingValue, mm.value);
        } else if (mm is MidiIOMessageNote) {
          color = processRGB(color, mm.note - mappingValue, mm.velocity);
        } else {
          Debug.warning('MidiMapping: control type mismatch');
        }
        value = color;
        control.color = color;
        break;
    }
    control.change(source: ControlChangeSource.midi);
    super.updateFrom(mm);
  }

  Color processRGB(Color color, int chan, int value) {
    switch (chan) {
      case 0:
        color = color.withRed(value * 2);
        break;
      case 1:
        color = color.withGreen(value * 2);
        break;
      case 2:
        color = color.withBlue(value * 2);
        break;
    }
    return color;
  }

  HSVColor processHSV(HSVColor hsv, int chan, int value) {
    switch (chan) {
      case 0:
        hsv = hsv.withHue(360 * value / 127);
        break;
      case 1:
        hsv = hsv.withSaturation(value / 127);
        break;
      case 2:
        hsv = hsv.withValue(value / 127);
        break;
    }
    return hsv;
  }

  HSLColor processHSL(HSLColor hsv, int chan, int value) {
    switch (chan) {
      case 0:
        hsv = hsv.withHue(360 * value / 127);
        break;
      case 1:
        hsv = hsv.withSaturation(value / 127);
        break;
      case 2:
        hsv = hsv.withLightness(value / 127);
        break;
    }
    return hsv;
  }

  @override
  List<MidiIOMessage> get midiMessages {
    switch (mode) {
      case MidiMappingControlColorMode.hsl:
        final hsl = HSLColor.fromColor(control.color);
        value = hsl;
        switch (mappingType) {
          case MidiMappingType.note:
            return [
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue,
                  velocity: 127 * hsl.hue ~/ 360),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 1,
                  velocity: (127 * hsl.saturation).toInt()),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 2,
                  velocity: (127 * hsl.lightness).toInt()),
            ];
          case MidiMappingType.control:
            return [
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue,
                  value: 127 * hsl.hue ~/ 360),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 1,
                  value: (127 * hsl.saturation).toInt()),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 2,
                  value: (127 * hsl.lightness).toInt()),
            ];
        }
      case MidiMappingControlColorMode.hsv:
        final hsv = HSVColor.fromColor(control.color);
        value = hsv;
        switch (mappingType) {
          case MidiMappingType.note:
            return [
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue,
                  velocity: 127 * hsv.hue ~/ 360),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 1,
                  velocity: (127 * hsv.saturation).toInt()),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 2,
                  velocity: (127 * hsv.value).toInt()),
            ];
          case MidiMappingType.control:
            return [
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue,
                  value: 127 * hsv.hue ~/ 360),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 1,
                  value: (127 * hsv.saturation).toInt()),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 2,
                  value: (127 * hsv.value).toInt()),
            ];
        }
      case MidiMappingControlColorMode.rgb:
        value = control.color;
        switch (mappingType) {
          case MidiMappingType.note:
            return [
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue,
                  velocity: (control.color.r * 127).toInt()),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 1,
                  velocity: (control.color.g * 127).toInt()),
              MidiIOMessageNoteOn(
                  channel: channel,
                  note: mappingValue + 2,
                  velocity: (control.color.b * 127).toInt()),
            ];
          case MidiMappingType.control:
            return [
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue,
                  value: (control.color.r * 127).toInt()),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 1,
                  value: (control.color.g * 127).toInt()),
              MidiIOMessageControlChange(
                  channel: channel,
                  control: mappingValue + 2,
                  value: (control.color.b * 127).toInt()),
            ];
        }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
