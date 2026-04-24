import 'dart:typed_data';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiMessageTimed {
  final MidiIOMessage message;
  final double time;
  MidiMessageTimed({required this.message, double? time})
      : time = time ?? DateTime.now().millisecondsSinceEpoch / 1000;
  @override
  String toString() => 'MidiIOTimedMessage(message: $message, time: $time)';
  String get description => '${message.description} at $time';
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOMessage {
  final MidiIOMessageType type;
  const MidiIOMessage({required this.type});
  factory MidiIOMessage.from({required Uint8List data}) {
    final type = MidiIOMessageType.from(data[0]);
    switch (type) {
      case MidiIOMessageType.noteOff:
        return MidiIOMessageNoteOff.from(data: data);
      case MidiIOMessageType.noteOn:
        return MidiIOMessageNoteOn.from(data: data);
      case MidiIOMessageType.afterTouch:
        return MidiIOMessageAftertouch.from(data: data);
      case MidiIOMessageType.controlChange:
        return MidiIOMessageControlChange.from(data: data);
      case MidiIOMessageType.programChange:
        return MidiIOMessageProgramChange.from(data: data);
      case MidiIOMessageType.channelPressure:
        return MidiIOMessageChannelPressure.from(data: data);
      case MidiIOMessageType.pitchBend:
        return MidiIOMessagePitch.from(data: data);
      case MidiIOMessageType.sysExStart:
        return MidiIOMessageSysEx.from(data: data);
      case MidiIOMessageType.mtcQuaterFrame:
        return MidiIOMessageMtcQuaterFrame.from(data: data);
      case MidiIOMessageType.songPosition:
        return MidiIOMessageSongPosition.from(data: data);
      case MidiIOMessageType.songSelect:
        return MidiIOMessageSongSelect.from(data: data);
      case MidiIOMessageType.tuningRequested:
        return MidiIOMessageTuneRequested.from(data: data);
      case MidiIOMessageType.clock:
        return MidiIOMessageClock.from(data: data);
      case MidiIOMessageType.tick:
        return MidiMessageTick.from(data: data);
      case MidiIOMessageType.start:
        return MidiMessageStart.from(data: data);
      case MidiIOMessageType.midiContinue:
        return MidiMessageContinue.from(data: data);
      case MidiIOMessageType.stop:
        return MidiMessageStop.from(data: data);
      case MidiIOMessageType.activeSense:
        return MidiMessageActiveSense.from(data: data);
      case MidiIOMessageType.reset:
        return MidiMessageReset.from(data: data);
      default:
        throw Exception('Invalid MidiIOMessageType: $type');
    }
  }
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiIOMessage(type: $type)';
  String get description => 'Message: $type';
  String get key => '$type';

  static String keyFrom(
      {required MidiIOMessageType type,
      required int channel,
      required int number}) {
    return '$type.$channel.$number';
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOChannelMessage extends MidiIOMessage {
  final int channel;
  const MidiIOChannelMessage({required super.type, required this.channel});
  @override
  Uint8List get data => Uint8List.fromList([type.value | channel]);
  @override
  String toString() => 'MidiIOChannelMessage(type: $type, channel: $channel)';
  String get channelName =>
      channel < 9 ? 'Channel  ${channel + 1}' : 'Channel ${channel + 1}';
  @override
  String get description => '$channelName: $type';
  @override
  String get key => '$type.$channel';
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOMessageNote extends MidiIOChannelMessage {
  final int note;
  final int velocity;
  const MidiIOMessageNote(
      {required super.channel,
      required this.note,
      required this.velocity,
      required super.type});
  @override
  Uint8List get data =>
      Uint8List.fromList([type.value | channel, note, velocity]);
  @override
  String toString() =>
      'MidiIOMessageNoteOn(channel: $channel, note: $note, velocity: $velocity)';
  @override
  String get description =>
      '$channelName: Note On/Off ${midiNoteName(note)} $velocity';
  @override
  String get key => '$type.$channel.$note';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessageNote &&
          type == other.type &&
          channel == other.channel &&
          note == other.note &&
          velocity == other.velocity;
  @override
  int get hashCode =>
      type.hashCode ^ channel.hashCode ^ note.hashCode ^ velocity.hashCode;
}

class MidiIOMessageNoteOn extends MidiIOMessageNote {
  const MidiIOMessageNoteOn({
    required super.channel,
    required super.note,
    required super.velocity,
    super.type = MidiIOMessageType.noteOn,
  });
  factory MidiIOMessageNoteOn.from({required Uint8List data}) {
    final note = data[1];
    final velocity = data[2];
    return MidiIOMessageNoteOn(
        channel: data[0] & 0xf, note: note, velocity: velocity);
  }
  @override
  String toString() =>
      'MidiIOMessageNoteOn(channel: $channel, note: $note, velocity: $velocity)';
  @override
  String get description =>
      '$channelName: Note On ${midiNoteName(note)} $velocity';
}

class MidiIOMessageNoteOff extends MidiIOMessageNote {
  const MidiIOMessageNoteOff({
    required super.channel,
    required super.note,
    required super.velocity,
    super.type = MidiIOMessageType.noteOff,
  });
  factory MidiIOMessageNoteOff.from({required Uint8List data}) {
    final note = data[1];
    final velocity = data[2];
    return MidiIOMessageNoteOff(
        channel: data[0] & 0xf, note: note, velocity: velocity);
  }
  @override
  String toString() =>
      'MidiIOMessageNoteOff(channel: $channel, note: $note, velocity: $velocity)';
  @override
  String get description =>
      '$channelName: Note Off ${midiNoteName(note)} $velocity';
}

class MidiIOMessageAftertouch extends MidiIOChannelMessage {
  final int note;
  final int pressure;
  const MidiIOMessageAftertouch({
    required super.channel,
    required this.note,
    required this.pressure,
    super.type = MidiIOMessageType.afterTouch,
  });
  factory MidiIOMessageAftertouch.from({required Uint8List data}) {
    final note = data[1];
    final pressure = data[2];
    return MidiIOMessageAftertouch(
        channel: data[0] & 0xf, note: note, pressure: pressure);
  }
  @override
  Uint8List get data =>
      Uint8List.fromList([type.value | channel, note, pressure]);
  @override
  String toString() =>
      'MidiIOMessageAftertouch(channel: $channel, note: $note, pressure: $pressure)';
  @override
  String get description =>
      '$channelName: Note On/Off ${midiNoteName(note)} $pressure';

  @override
  String get key => '$type.$channel.$note';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessageAftertouch &&
          type == other.type &&
          channel == other.channel &&
          note == other.note &&
          pressure == other.pressure;
  @override
  int get hashCode =>
      type.hashCode ^ channel.hashCode ^ note.hashCode ^ pressure.hashCode;
}

class MidiIOMessageControlChange extends MidiIOChannelMessage {
  final int control;
  final int value;
  const MidiIOMessageControlChange({
    required super.channel,
    required this.control,
    required this.value,
    super.type = MidiIOMessageType.controlChange,
  });
  factory MidiIOMessageControlChange.from({required Uint8List data}) {
    final control = data[1];
    final value = data[2];
    return MidiIOMessageControlChange(
        channel: data[0] & 0xf, control: control, value: value);
  }
  @override
  Uint8List get data =>
      Uint8List.fromList([type.value | channel, control, value]);
  @override
  String toString() =>
      'MidiIOMessageControlChange(channel: $channel, control: $control, value: $value)';
  @override
  String get description => '$channelName: Control Change $control $value';
  @override
  String get key => '$type.$channel.$control';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessageControlChange &&
          type == other.type &&
          channel == other.channel &&
          control == other.control &&
          value == other.value;
  @override
  int get hashCode =>
      type.hashCode ^ channel.hashCode ^ control.hashCode ^ value.hashCode;
}

class MidiIOMessageProgramChange extends MidiIOChannelMessage {
  final int program;
  const MidiIOMessageProgramChange({
    required super.channel,
    required this.program,
    super.type = MidiIOMessageType.programChange,
  });
  factory MidiIOMessageProgramChange.from({required Uint8List data}) {
    final program = data[1];
    return MidiIOMessageProgramChange(channel: data[0] & 0xf, program: program);
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value | channel, program]);
  @override
  String toString() =>
      'MidiIOMessageProgramChange(channel: $channel, program: $program)';
  @override
  String get description => '$channelName: Program Change $program';
  @override
  String get key => '$type.$channel';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessageProgramChange &&
          type == other.type &&
          channel == other.channel &&
          program == other.program;
  @override
  int get hashCode => type.hashCode ^ channel.hashCode ^ program.hashCode;
}

class MidiIOMessageChannelPressure extends MidiIOChannelMessage {
  final int pressure;
  const MidiIOMessageChannelPressure({
    required super.channel,
    required this.pressure,
    super.type = MidiIOMessageType.channelPressure,
  });
  factory MidiIOMessageChannelPressure.from({required Uint8List data}) {
    final pressure = data[1];
    return MidiIOMessageChannelPressure(
        channel: data[0] & 0xf, pressure: pressure);
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value | channel, pressure]);
  @override
  String toString() =>
      'MidiIOMessageChannelPressure(channel: $channel, pressure: $pressure)';
  @override
  String get description => '$channelName: Channel Pressure $pressure';
  @override
  String get key => '$type.$channel';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessageChannelPressure &&
          type == other.type &&
          channel == other.channel &&
          pressure == other.pressure;
  @override
  int get hashCode => type.hashCode ^ channel.hashCode ^ pressure.hashCode;
}

class MidiIOMessagePitch extends MidiIOChannelMessage {
  final int pitch;
  const MidiIOMessagePitch({
    required super.channel,
    required this.pitch,
    super.type = MidiIOMessageType.pitchBend,
  });
  factory MidiIOMessagePitch.from({required Uint8List data}) {
    final pitch = data[1];
    return MidiIOMessagePitch(channel: data[0] & 0xf, pitch: pitch);
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value | channel, pitch]);
  @override
  String toString() => 'MidiIOMessagePitch(channel: $channel, pitch: $pitch)';
  @override
  String get description => '$channelName: Pitch Bend $pitch';
  @override
  String get key => '$type.$channel';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiIOMessagePitch &&
          type == other.type &&
          channel == other.channel &&
          pitch == other.pitch;
  @override
  int get hashCode => type.hashCode ^ channel.hashCode ^ pitch.hashCode;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOSystemMessage extends MidiIOMessage {
  const MidiIOSystemMessage({required super.type});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MidiIOMessageSysEx extends MidiIOSystemMessage {
  final Uint8List sysex;
  const MidiIOMessageSysEx({
    required super.type,
    required this.sysex,
  });
  factory MidiIOMessageSysEx.from({required Uint8List data}) {
    return MidiIOMessageSysEx(
        type: MidiIOMessageType.sysExStart,
        sysex: data.sublist(1, data.length - 1));
  }
  @override
  Uint8List get data => Uint8List.fromList([
        MidiIOMessageType.sysExStart.value,
        ...sysex,
        MidiIOMessageType.sysExEnd.value
      ]);
  @override
  String toString() => 'MidiIOMessageSysEx(data: $data)';
  @override
  String get description => 'SysEx: $data';
}

class MidiIOMessageMtcQuaterFrame extends MidiIOSystemMessage {
  final int value;
  const MidiIOMessageMtcQuaterFrame({
    required this.value,
    super.type = MidiIOMessageType.mtcQuaterFrame,
  });
  factory MidiIOMessageMtcQuaterFrame.from({required Uint8List data}) {
    final value = data[1];
    return MidiIOMessageMtcQuaterFrame(value: value);
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value, value]);
  @override
  String toString() => 'MidiIOMessageMtcQuaterFrame(value: $value)';
  @override
  String get description => 'MtcQuaterFrame: $value';
}

class MidiIOMessageSongPosition extends MidiIOSystemMessage {
  final int position;
  const MidiIOMessageSongPosition({
    required this.position,
    super.type = MidiIOMessageType.songPosition,
  });
  factory MidiIOMessageSongPosition.from({required Uint8List data}) {
    final position = data[1] | (data[2] << 7);
    return MidiIOMessageSongPosition(position: position);
  }
  @override
  Uint8List get data =>
      Uint8List.fromList([type.value, position & 0x7f, (position >> 7) & 0x7f]);
  @override
  String toString() => 'MidiIOMessageSongPosition(position: $position)';
  @override
  String get description => 'SongPosition: $position';
}

class MidiIOMessageSongSelect extends MidiIOSystemMessage {
  final int song;
  const MidiIOMessageSongSelect({
    required this.song,
    super.type = MidiIOMessageType.songSelect,
  });
  factory MidiIOMessageSongSelect.from({required Uint8List data}) {
    final song = data[1];
    return MidiIOMessageSongSelect(song: song);
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value, song]);
  @override
  String toString() => 'MidiIOMessageSongSelect(song: $song)';
  @override
  String get description => 'SongSelect: $song';
}

class MidiIOMessageTuneRequested extends MidiIOSystemMessage {
  const MidiIOMessageTuneRequested({
    super.type = MidiIOMessageType.tuningRequested,
  });
  factory MidiIOMessageTuneRequested.from({required Uint8List data}) {
    return const MidiIOMessageTuneRequested();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiIOMessageTuneRequested()';
  @override
  String get description => 'TuneRequested';
}

class MidiIOMessageClock extends MidiIOSystemMessage {
  const MidiIOMessageClock({
    super.type = MidiIOMessageType.clock,
  });
  factory MidiIOMessageClock.from({required Uint8List data}) {
    return const MidiIOMessageClock();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiIOMessageClock()';
  @override
  String get description => 'Clock';
}

class MidiMessageTick extends MidiIOSystemMessage {
  const MidiMessageTick({
    super.type = MidiIOMessageType.tick,
  });
  factory MidiMessageTick.from({required Uint8List data}) {
    return const MidiMessageTick();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageTick()';
  @override
  String get description => 'Tick';
}

class MidiMessageStart extends MidiIOSystemMessage {
  const MidiMessageStart({
    super.type = MidiIOMessageType.start,
  });
  factory MidiMessageStart.from({required Uint8List data}) {
    return const MidiMessageStart();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageStart()';
  @override
  String get description => 'Start';
}

class MidiMessageContinue extends MidiIOSystemMessage {
  const MidiMessageContinue({
    super.type = MidiIOMessageType.midiContinue,
  });
  factory MidiMessageContinue.from({required Uint8List data}) {
    return const MidiMessageContinue();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageContinue()';
  @override
  String get description => 'Continue';
}

class MidiMessageStop extends MidiIOSystemMessage {
  const MidiMessageStop({
    super.type = MidiIOMessageType.stop,
  });
  factory MidiMessageStop.from({required Uint8List data}) {
    return const MidiMessageStop();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageStop()';
  @override
  String get description => 'Stop';
}

class MidiMessageActiveSense extends MidiIOSystemMessage {
  const MidiMessageActiveSense({
    super.type = MidiIOMessageType.activeSense,
  });
  factory MidiMessageActiveSense.from({required Uint8List data}) {
    return const MidiMessageActiveSense();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageActiveSense()';
  @override
  String get description => 'ActiveSense';
}

class MidiMessageReset extends MidiIOSystemMessage {
  const MidiMessageReset({
    super.type = MidiIOMessageType.reset,
  });
  factory MidiMessageReset.from({required Uint8List data}) {
    return const MidiMessageReset();
  }
  @override
  Uint8List get data => Uint8List.fromList([type.value]);
  @override
  String toString() => 'MidiMessageReset()';
  @override
  String get description => 'Reset';
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
// https://medium.com/@keybaudio/understanding-midi-messages-a1d1dba0296e
enum MidiIOMessageType {
  // channel messages
  noteOff(0x80),
  noteOn(0x90),
  afterTouch(0xa0),
  controlChange(0xb0),
  programChange(0xc0),
  channelPressure(0xd0),
  pitchBend(0xe0),
  system(0xf0),
  // system messages
  sysExStart(0xF0), // Start of SysEx stream
  sysExEnd(0xF7), // End of SysEx stream
  mtcQuaterFrame(0xF1), // MTC quarter frame time code
  songPosition(0xF2), // Ask slave to position playback cue
  songSelect(0xF3), // Select a certain song and cue to beginning
  tuningRequested(0xF6), // Being asked to self-tune
  clock(0xF8), // sync with a tempo (24 clocks per quarter note)
  tick(0xF9), // Being kept in sync with a tick (every 10ms)
  start(0xFA), // Master asking for playback from the beginning
  midiContinue(0xFB), // Master asked that we continue playback from cue
  stop(0xFC), // Master asked to stop playback and retain cue point
  activeSense(0xFE), // Keepalive data to let us know things are still connected
  reset(0xFF); // Reset to default, no keys pressed, cue to beginning

  final int value;
  const MidiIOMessageType(this.value);

  static MidiIOMessageType from(int value) {
    switch (value & 0xf0) {
      case 0x80:
        return MidiIOMessageType.noteOff;
      case 0x90:
        return MidiIOMessageType.noteOn;
      case 0xa0:
        return MidiIOMessageType.afterTouch;
      case 0xb0:
        return MidiIOMessageType.controlChange;
      case 0xc0:
        return MidiIOMessageType.programChange;
      case 0xd0:
        return MidiIOMessageType.channelPressure;
      case 0xe0:
        return MidiIOMessageType.pitchBend;
      case 0xf0:
        return fromSysEx(value);
      default:
        throw Exception('Invalid MidiIOMessageType value: $value');
    }
  }

  static MidiIOMessageType fromSysEx(int value) {
    switch (value) {
      case 0xF0:
        return MidiIOMessageType.sysExStart;
      case 0xF7:
        return MidiIOMessageType.sysExEnd;
      case 0xF1:
        return MidiIOMessageType.mtcQuaterFrame;
      case 0xF2:
        return MidiIOMessageType.songPosition;
      case 0xF3:
        return MidiIOMessageType.songSelect;
      case 0xF6:
        return MidiIOMessageType.tuningRequested;
      case 0xF8:
        return MidiIOMessageType.clock;
      case 0xF9:
        return MidiIOMessageType.tick;
      case 0xFA:
        return MidiIOMessageType.start;
      case 0xFB:
        return MidiIOMessageType.midiContinue;
      case 0xFC:
        return MidiIOMessageType.stop;
      case 0xFE:
        return MidiIOMessageType.activeSense;
      case 0xFF:
        return MidiIOMessageType.reset;
      default:
        throw Exception('Invalid MidiIOMessageType value: $value');
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
String midiNoteName(int note) {
  const noteNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B'
  ];
  final octave = (note / 12).floor() - 1;
  final noteName = noteNames[note % 12];
  return '$noteName$octave';
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

