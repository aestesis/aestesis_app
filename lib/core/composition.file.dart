import 'dart:convert';
import 'dart:typed_data';

import 'package:aestesis/midi/midi.manager.dart';
import 'package:aestesis_engine/aestesis_engine.dart';

import '../aestesis.dart';
import 'presets.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class CompositionFile {
  Composition composition;
  Presets presets;
  CompositionFile({required this.composition, required this.presets});
  Map<String, dynamic> toJson() => {
    'application': 'aestesis',
    'applicationVersion': aes.package.version,
    'type': 'composition',
    'version': '1.0',
    'composition': composition.toJson(),
    'presets': presets.toJson(),
  };
  factory CompositionFile.fromJson(Map json) => CompositionFile(
    presets: Presets.fromJson(json['presets'] ?? {}),
    composition: CompositionExtension.fromJson(json['composition']),
  );

  factory CompositionFile.fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes));
    return CompositionFile.fromJson(json);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class Settings {
  CompositionSettings composition;
  MidiManagerSettings midi;
  Settings({required this.composition, required this.midi});
  Map<String, dynamic> toJson() => {
    'composition': composition.toJson(),
    'midi': midi.toJson(),
  };
  factory Settings.fromJson(Map json) => Settings(
    composition: CompositionSettingsExtension.fromJson(
      json['composition'] ?? {},
    ),
    midi: MidiManagerSettings.fromJson(json['midi'] ?? {}),
  );
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/*

        midiSettings: json.containsKey('midi')
            ? MidiManagerSettings.fromJson(json['midi'])
            : MidiManagerSettings.defaultSettings


*/
