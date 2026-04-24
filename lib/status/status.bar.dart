import 'package:flutter/material.dart';

import '../table.dart';
import '../ui/icon.dart';
import '../ui/select.dart';
import 'status.audio.dart';
import 'status.midi.dart';
import 'status.record.dart';
import 'status.stats.dart';
import 'status.video.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusBar extends StatelessWidget {
  final TableOption option;
  final ValueChanged<TableOption> onChanged;
  const StatusBar({super.key, required this.option, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: ColorScheme.of(context).inversePrimary,
        child: Row(children: [
          Tooltip(
              message: 'Midi Mapping',
              child: UISelectItem(
                  mainAxisSize: MainAxisSize.min,
                  selected: option == TableOption.mapping,
                  color: ColorScheme.of(context).primaryContainer,
                  onChanged: (v) {
                    if (v) {
                      onChanged(TableOption.mapping);
                    } else {
                      onChanged(TableOption.none);
                    }
                  },
                  child: UIIcon.mapping.widget(
                      size: UISize.medium,
                      color: ColorScheme.of(context).onPrimaryContainer))),
          const SizedBox(width: 10),
          Tooltip(
              message: 'Presets',
              child: UISelectItem(
                  mainAxisSize: MainAxisSize.min,
                  selected: option == TableOption.presets,
                  color: ColorScheme.of(context).primaryContainer,
                  onChanged: (v) {
                    if (v) {
                      onChanged(TableOption.presets);
                    } else {
                      onChanged(TableOption.none);
                    }
                  },
                  child: UIIcon.presets.widget(
                      size: UISize.medium,
                      color: ColorScheme.of(context).onPrimaryContainer))),
          const Spacer(),
          const StatusAudio(),
          const SizedBox(width: 10),
          const StatusMidi(),
          const SizedBox(width: 10),
          const StatusVideo(),
          const SizedBox(width: 10),
          const StatusStats(),
          const SizedBox(width: 10),
          const StatusRecord(),
        ]));
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
