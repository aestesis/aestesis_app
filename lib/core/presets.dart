import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:uuid/uuid.dart';

import '../aestesis.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class Presets {
  final List<Preset> presets = [];
  Presets() {
    clear();
  }
  void set(Presets presets) {
    this.presets.clear();
    this.presets.addAll(presets.presets);
  }

  void clear() {
    presets.clear();
    for (int i = 0; i < 128; i++) {
      presets.add(Preset(name: ''));
    }
  }

  void reorder(int oldIndex, int newIndex) {
    final p = presets.removeAt(oldIndex);
    presets.insert(newIndex, p);
  }

  int get count => presets.length;
  Preset operator [](int index) => presets[index];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> r = {};
    int i = 0;
    for (final p in presets) {
      if (!p.isEmpty) {
        r['$i'] = p.toJson();
      }
      i++;
    }
    return r;
  }

  factory Presets.fromJson(Map<String, dynamic> json) {
    final p = Presets();
    json.forEach((ii, s) {
      final i = int.parse(ii);
      p.presets[i] = Preset.fromJson(s);
    });
    return p;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class Preset {
  String name;
  String id;
  bool get isEmpty => states.isEmpty;
  Map<String, List<ControlState>> states = {};
  Preset(
      {required this.name, String? id, Map<String, List<ControlState>>? states})
      : id = id ?? const Uuid().v4(),
        states = states ?? {};
  void save() {
    states = {};
    for (final m in aes.composition!.modules.whereType<Module>()) {
      states[m.id] = m.getControlStates();
    }
  }

  void load() {
    states.forEach((mid, mst) {
      final m = aes.composition?.getModule(mid);
      if (m == null) return;
      final controls = m.setControlStates(mst);
      for (final c in controls) {
        c.change(source: ControlChangeSource.preset);
      }
    });
  }

  void clear() {
    states = {};
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'states': states.map((mid, mst) =>
          MapEntry<String, List>(mid, [...mst.map((st) => st.toJson())])),
    };
  }

  factory Preset.fromJson(Map<String, dynamic> map) {
    return Preset(
      name: map['name'] ?? '',
      id: map['id'] ?? '',
      states: (map['states'] as Map? ?? {}).map((mid, mst) =>
          MapEntry<String, List<ControlState>>(
              mid, [...mst.map((st) => ControlState.fromJson(st))])),
    );
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
