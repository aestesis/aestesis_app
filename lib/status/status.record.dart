import 'dart:async';
import 'dart:io';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';

import '../aestesis.dart';
import '../ui/icon.dart';
import '../ui/select.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class StatusRecord extends StatefulWidget {
  const StatusRecord({super.key});
  @override
  State<StatusRecord> createState() => _StatusRecordState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _StatusRecordState extends State<StatusRecord> {
  late final StreamSubscription statesSubscription;
  CompositionStates states = CompositionStates(
    recording: false,
    streaming: false,
    previewing: false,
  );
  @override
  void initState() {
    super.initState();
    statesSubscription = aes.message.listenStates((states) {
      this.states = states;
      setState(() {});
    });
  }

  @override
  void dispose() {
    statesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //    final color = ColorScheme.of(context).onBackground.withOpacity(0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Record',
          child: UISelectItem(
            mainAxisSize: MainAxisSize.min,
            selected: states.recording,
            color: ColorScheme.of(context).primaryContainer,
            onChanged: (v) {
              if (v) {
                final home = Platform.environment['HOME']!;
                aes.alib.startRecording('$home/Desktop/${aes.title}.mov');
              } else {
                aes.alib.stopRecording();
              }
            },
            child:
                (states.recording ? UIIcon.recordActive : UIIcon.recordInactive)
                    .widget(
                      size: UISize.medium,
                      color: ColorScheme.of(context).onPrimaryContainer,
                    ),
          ),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Stream',
          child: UISelectItem(
            mainAxisSize: MainAxisSize.min,
            selected: false,
            color: ColorScheme.of(context).primaryContainer,
            onChanged: (v) {},
            child: UIIcon.stream.widget(
              size: UISize.medium,
              color: ColorScheme.of(context).onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Tooltip(
          message: 'Window',
          child: UISelectItem(
            mainAxisSize: MainAxisSize.min,
            selected: states.previewing,
            color: ColorScheme.of(context).primaryContainer,
            onChanged: (v) {
              aes.alib.outputView(v);
            },
            child: UIIcon.previewWindow.widget(
              size: UISize.medium,
              color: ColorScheme.of(context).onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
