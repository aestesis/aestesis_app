import 'dart:async';

import 'package:bb_dart/bb_dart.dart';
import 'package:midi_io/midi_io.dart';

import 'midi.io.message.dart';

// TODO: replace flutter midi by internal swift midi https://github.com/orchetect/MIDIKit
// cause midi lagging when flutter UI is stall (ex: resizing window)
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIO {
  final onDevicesChanged = Event<MidiIODeviceConnectionEvent>();
  final _midi = Midi();
  late final StreamSubscription _deviceChangedSubscription;
  MidiIO() {
    _deviceChangedSubscription = _midi.onDevicesChanged.listen((event) {
      onDevicesChanged.fire(event.state == MidiPortDeviceState.connected
          ? MidiIODeviceConnectionEvent.connected
          : MidiIODeviceConnectionEvent.disconnected);
    });
  }
  void dispose() {
    onDevicesChanged.dispose();
    _deviceChangedSubscription.cancel();
  }

  Future<List<MidiIOSource>> get sources async {
    return (await _midi.getSources()).map((e) => MidiIOSource(e)).toList();
  }

  Future<List<MidiIODestination>> get destinations async {
    return (await _midi.getDestinations())
        .map((e) => MidiIODestination(e))
        .toList();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOSource extends MidiIOPort {
  final onMessage = Event<MidiIOMessage>();
  MidiSourcePort get _source => port as MidiSourcePort;
  StreamSubscription? _subscription;
  MidiIOSource(super.port);
  @override
  void open() {
    super.open();
    if (_subscription != null) {
      _subscription?.cancel();
    }
    _subscription = _source.messages.listen((event) {
      onMessage.fire(MidiIOMessage.from(data: event));
    });
  }

  @override
  close() {
    _subscription?.cancel();
    _subscription = null;
    super.close();
  }

  @override
  dispose() {
    close();
    onMessage.dispose();
    super.dispose();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIODestination extends MidiIOPort {
  MidiDestinationPort get destination => port as MidiDestinationPort;
  MidiIODestination(super.port);
  void send(MidiIOMessage message) {
    destination.send(message.data);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOPort {
  final onConncectionChanged = Event<MidiIOConnectionState>();
  final onDeviceChanged = Event<MidiIODeviceState>();
  final MidiPort port;
  late final StreamSubscription connectionSubscription;
  late final StreamSubscription deviceSubscription;
  MidiIOPort(this.port) {
    connectionSubscription = port.connection.listen((event) {
      onConncectionChanged.fire(MidiIOConnectionState.from(event));
    });
    deviceSubscription = port.state.listen((event) {
      onDeviceChanged.fire(MidiIODeviceState.from(event));
    });
  }
  void dispose() {
    close();
    onConncectionChanged.dispose();
    onDeviceChanged.dispose();
    connectionSubscription.cancel();
    deviceSubscription.cancel();
    port.dispose();
  }

  String get name => port.name ?? 'No name MIDI Device';
  int get number => port.number ?? 0;
  String get id => port.id;
  MidiIOPortType get type => port.type == MidiPortType.source
      ? MidiIOPortType.source
      : MidiIOPortType.destination;

  void open() {
    port.open();
  }

  void close() {
    port.close();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MidiIOPort &&
        port.id == other.port.id &&
        port.type == other.port.type;
  }

  @override
  int get hashCode {
    return port.id.hashCode ^ port.type.hashCode;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum MidiIODeviceConnectionEvent { connected, disconnected }
/////////////////////////////////////////////////////////////////////////////////////////////////

enum MidiIOPortType { source, destination }

/////////////////////////////////////////////////////////////////////////////////////////////////
enum MidiIOConnectionState {
  open,
  closed,
  pending;

  static MidiIOConnectionState from(MidiPortConnectionState state) {
    switch (state) {
      case MidiPortConnectionState.open:
        return MidiIOConnectionState.open;
      case MidiPortConnectionState.closed:
        return MidiIOConnectionState.closed;
      case MidiPortConnectionState.pending:
        return MidiIOConnectionState.pending;
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
enum MidiIODeviceState {
  connected,
  disconnected;

  static MidiIODeviceState from(MidiPortDeviceState state) {
    switch (state) {
      case MidiPortDeviceState.connected:
        return MidiIODeviceState.connected;
      case MidiPortDeviceState.disconnected:
        return MidiIODeviceState.disconnected;
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
