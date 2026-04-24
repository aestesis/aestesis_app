import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:bb_dart/bb_dart.dart';
import 'package:flutter/foundation.dart';

import 'midi.io.dart';
import 'midi.io.message.dart';
import 'midi.mapping.dart';

// TODO: add virtual midi device MIDIInputPortCreateWithProtocol https://developer.apple.com/documentation/coremidi/3566488-midiinputportcreatewithprotocol
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiManager {
  final MidiIO midiIO = MidiIO();
  late final MidiMapping mapping;
  final List<MidiIOSource> sources = [];
  final Map<MidiIOSource, MidiChannelFilter> sourceChannelFilters = {};
  final List<MidiIODestination> destinations = [];
  final List<MidiIOSource> selectedSources = [];
  final List<MidiIODestination> selectedDestinations = [];
  final Set<MidiIOPort> selectedPorts =
      {}; // backup if device temporary disconnected
  final Map<MidiIOSource, StreamSubscription<MidiIOMessage>>
      sourceSubscriptions = {};
  final onMidiMessage = Event<MidiIOMessage>();
  final onDevicesChanged = Event<MidiIODeviceConnectionEvent>();
  MidiManager() {
    midiIO.onDevicesChanged.listen((event) async {
      await _updateDevices();
      onDevicesChanged.fire(event);
    });
    _updateDevices().then((_) {
      onDevicesChanged.fire(MidiIODeviceConnectionEvent.connected);
    });
    mapping = MidiMapping(midi: this);
  }
  void dispose() async {
    for (final source in [...selectedSources]) {
      unselectSource(source);
    }
    for (final destination in [...selectedDestinations]) {
      unselectDestination(destination);
    }
    midiIO.dispose();
  }

  Future<void> _updateDevices() async {
    final src = await midiIO.sources;
    final dst = await midiIO.destinations;
    sources.clear();
    destinations.clear();
    sources.addAll(src);
    destinations.addAll(dst);
    for (final source in [...selectedSources]) {
      if (!sources.contains(source)) {
        unselectSource(source, manually: false);
      }
    }
    for (final destination in [...selectedDestinations]) {
      if (!destinations.contains(destination)) {
        unselectDestination(destination, manually: false);
      }
    }
    for (final source in src) {
      if (selectedPorts.contains(source) && !selectedSources.contains(source)) {
        selectSource(source);
      }
    }
    for (final source in sources) {
      if (!sourceChannelFilters.containsKey(source)) {
        sourceChannelFilters[source] = MidiChannelFilter.all;
      }
    }
  }

  void selectSource(MidiIOSource source) {
    if (!selectedSources.contains(source)) {
      selectedSources.add(source);
      source.open();
      sourceSubscriptions[source] = source.onMessage.listen((event) {
        if (event is MidiIOChannelMessage) {
          if (!sourceChannelFilters[source]!.isEnabled(event.channel)) {
            return;
          }
        }
        onMidiMessage.fire(event);
      });
    }
    selectedPorts.add(source);
  }

  void unselectSource(MidiIOSource source, {bool manually = true}) {
    if (selectedSources.contains(source)) {
      sourceSubscriptions[source]?.cancel();
      sourceSubscriptions.remove(source);
      selectedSources.remove(source);
      source.close();
    }
    if (manually) selectedPorts.remove(source);
  }

  void selectDestination(MidiIODestination destination) {
    if (!selectedDestinations.contains(destination)) {
      selectedDestinations.add(destination);
      destination.open();
    }
    selectedPorts.add(destination);
  }

  void unselectDestination(MidiIODestination destination,
      {bool manually = true}) {
    if (selectedDestinations.contains(destination)) {
      selectedDestinations.remove(destination);
      destination.close();
    }
    if (manually) selectedPorts.remove(destination);
  }

  void sendMessage(MidiIOMessage message) {
    for (final destination in selectedDestinations) {
      destination.send(message);
    }
  }

  void send(Control control) {
    
  }

  set settings(MidiManagerSettings settings) {
    selectedPorts.clear();
    for (final source in [...selectedSources]) {
      unselectSource(source);
    }
    for (final destination in [...selectedDestinations]) {
      unselectDestination(destination);
    }
    for (final source in sources) {
      if (settings.sources.contains(source.name)) {
        selectSource(source);
        sourceChannelFilters[source] =
            settings.sourceChannelFilters[source.name] ?? MidiChannelFilter.all;
      }
    }
    for (final destination in destinations) {
      if (settings.destinations.contains(destination.name)) {
        selectDestination(destination);
      }
    }
    mapping.settings = settings.mapping;
  }

  MidiManagerSettings get settings {
    final settings = MidiManagerSettings(
        sources: selectedSources.map((e) => e.name).toList(),
        destinations: selectedDestinations.map((e) => e.name).toList(),
        sourceChannelFilters: {},
        mapping: mapping.settings);
    for (final source in selectedSources) {
      settings.sourceChannelFilters[source.name] =
          sourceChannelFilters[source] ?? MidiChannelFilter.all;
    }
    return settings;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiChannelFilter {
  final Set<int> channels = {};
  MidiChannelFilter();
  bool get isAll => channels.length == 16;
  bool get isNone => channels.isEmpty;
  bool isEnabled(int channel) => channels.contains(channel);
  bool isDisabled(int channel) => !isEnabled(channel);
  void enable(int channel) {
    channels.add(channel);
  }

  void disable(int channel) {
    channels.remove(channel);
  }

  void toggle(int channel) {
    if (isEnabled(channel)) {
      disable(channel);
    } else {
      enable(channel);
    }
  }

  void set(int channel, bool enabled) {
    if (enabled) {
      enable(channel);
    } else {
      disable(channel);
    }
  }

  static MidiChannelFilter get all =>
      MidiChannelFilter()..channels.addAll([for (int i = 0; i <= 15; i++) i]);
  static MidiChannelFilter get none => MidiChannelFilter();

  Map<String, dynamic> toJson() => {
        'channels': channels.toList(),
      };
  factory MidiChannelFilter.fromJson(Map json) {
    final filter = MidiChannelFilter();
    filter.channels.addAll([...json['channels'].whereType<int>()]);
    return filter;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiManagerSettings {
  final List<String> sources;
  final List<String> destinations;
  final Map<String, MidiChannelFilter> sourceChannelFilters;
  final Map<String, dynamic> mapping;
  MidiManagerSettings(
      {required this.sources,
      required this.sourceChannelFilters,
      required this.destinations,
      required this.mapping});

  Map<String, dynamic> toJson() {
    return {
      'sources': sources,
      'destinations': destinations,
      'sourceChannelFilters': sourceChannelFilters,
      'mapping': mapping
    };
  }

  factory MidiManagerSettings.fromJson(Map<String, dynamic> map) {
    return MidiManagerSettings(
        sources: List<String>.from(map['sources']),
        destinations: List<String>.from(map['destinations']),
        sourceChannelFilters:
            (map['sourceChannelFilters'] as Map<String, dynamic>).map(
                (key, value) =>
                    MapEntry(key, MidiChannelFilter.fromJson(value))),
        mapping: map['mapping'] ?? {'controls': []});
  }

  @override
  String toString() =>
      'MidiManagerInfo(sources: $sources, sourceChannelFilters: $sourceChannelFilters)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MidiManagerSettings &&
        listEquals(other.sources, sources) &&
        mapEquals(other.sourceChannelFilters, sourceChannelFilters);
  }

  @override
  int get hashCode => sources.hashCode ^ sourceChannelFilters.hashCode;

  static MidiManagerSettings get defaultSettings => MidiManagerSettings(
      sources: [], destinations: [], sourceChannelFilters: {}, mapping: {});
}
////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
