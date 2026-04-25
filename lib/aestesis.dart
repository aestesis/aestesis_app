import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:aestesis_engine/aestesis_engine.dart' as alib;
import 'package:bb_dart/bb_dart.dart';
import 'package:event_bus/event_bus.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

import 'core/composition.file.dart';
import 'core/flutter.extensions.dart';
import 'midi/midi.manager.dart';
import 'core/presets.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
final Aestesis aes = Aestesis();

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class Aestesis {
  final aestesisUrl = 'https://aestesis.org';
  final wikipediaVJ = 'https://en.wikipedia.org/wiki/VJing';
  final feedback = 'https://aestesis.org';
  final contactUs = 'mailto:renan@aestesis.org';
  final discord = 'https://discord.gg/fnWEmvU6qY';
  final bluesky = 'https://bsky.app/profile/aestesis.bsky.social';
  final alib = AestesisEngine();
  late final message = alib.message;
  late final SharedPreferences prefs;
  late final PackageInfo package;
  final bus = EventBus();
  late final StreamSubscription controlChangedSubscription;
  late final StreamSubscription settingsChangedSubscription;
  late final StreamSubscription addModuleSubscription;
  late final StreamSubscription insertModuleSubscription;
  late final StreamSubscription removetModuleSubscription;
  late final StreamSubscription addAssetsSubscription;
  late final StreamSubscription removeAssetsSubscription;
  late final StreamSubscription previewSubscription;
  late final StreamSubscription textureSubscription;
  late final StreamSubscription statisticsSubscription;
  late final StreamSubscription audioSubscription;
  late final StreamSubscription controlSubscription;
  late final StreamSubscription menuSubscription;
  late final StreamSubscription dbgMessagesSubscription;
  final Map<String, StreamController<Control>> controlUpdateEvents = {};

  final compositionFile = GetSet<String>(
    didSet: (v) {
      aes.bus.fire(CompositionTitleChangedEvent());
    },
  );

  AudioLevel? audio;
  Composition? composition;
  CompositionStatistics? statistics;
  CompositionSettings? compositionSettings;
  ThemeMode _theme = ThemeMode.dark;
  ThemeMode get theme => _theme;
  set theme(ThemeMode value) {
    _theme = value;
    this['theme'] = {'value': value.index};
    bus.fire(ThemeChangeEvent(value));
  }

  String get title {
    if (compositionFile.value != null) {
      return path.basenameWithoutExtension(compositionFile.value!);
    }
    return 'aestesis';
  }

  final previews = PreviewManager();
  final textures = TextureManager();
  final midi = MidiManager();
  final Presets presets = Presets();

  Future<void> initialize() async {
    try {
      prefs = await SharedPreferences.getInstance();
      package = await PackageInfo.fromPlatform();
      composition = await aes.alib.newComposition();
      compositionSettings = await aes.alib.settings(null);
      await windowSetup();
      settingsChangedSubscription = bus.on<SettingsChangeEvent>().listen((
        _,
      ) async {
        compositionSettings = await alib.settings(compositionSettings);
        final s = Settings(
          composition: compositionSettings!,
          midi: midi.settings,
        );
        this['settings'] = s.toJson();
        bus.fire(SettingsUpdateEvent());
      });
      controlChangedSubscription = bus.on<ControlChangeEvent>().listen((
        event,
      ) async {
        await alib.updateControl(event.control);
        event.control.update();
        if (event.source == ControlChangeSource.ui) {
          midi.mapping.update(event.control);
        }
      });
      addModuleSubscription = bus.on<AddModuleEvent>().listen((event) async {
        if (composition != null) {
          if (event.at != null) {
            composition = await alib.insertModule(
              event.type.create(),
              composition!.modules.indexOf(event.at) + 1,
            );
          } else {
            composition = await alib.addModule(event.type.create());
          }
          bus.fire(CompositionChangedEvent());
        }
      });
      insertModuleSubscription = aes.bus.on<InsertModuleEvent>().listen((
        InsertModuleEvent event,
      ) async {
        if (composition != null) {
          composition = await aes.alib.insertModule(
            event.type.create(),
            aes.composition!.modules.indexOf(event.at),
          );
          bus.fire(CompositionChangedEvent());
        }
      });
      removetModuleSubscription = aes.bus.on<RemoveModuleEvent>().listen((
        event,
      ) async {
        if (composition != null) {
          composition = await aes.alib.removeModule(event.module.id);
          bus.fire(CompositionChangedEvent());
        }
      });
      addAssetsSubscription = aes.bus.on<AddAssetsEvent>().listen((
        event,
      ) async {
        if (composition != null) {
          composition = await aes.alib.addAssets(event.module.id, event.assets);
          bus.fire(ModuleChangeEvent(event.module));
        }
      });
      removeAssetsSubscription = aes.bus.on<RemoveAssetsEvent>().listen((
        event,
      ) async {
        if (composition != null) {
          composition = await aes.alib.removeAssets(event.module.id, [
            ...event.assets.map((e) => e.id),
          ]);
          bus.fire(ModuleChangeEvent(event.module));
        }
      });
      previewSubscription = message.listenPreview((preview) {
        if (preview.assetId != null) {
          previews.add(preview);
        } else {
          Debug.error('preview.assetId is null');
        }
      });
      textureSubscription = message.listenTexture((texture) {
        //Debug.info('new texture: ${texture.debugDescription}');
        textures.add(texture);
      });
      statisticsSubscription = message.listenStatistics((statistics) {
        this.statistics = statistics;
        bus.fire(StatisticsUpdateEvent(statistics: statistics));
      });
      audioSubscription = message.listenAudio((audio) {
        this.audio = audio;
        bus.fire(AudioEvent(audio));
      });
      controlSubscription = message.listenControl((control) {
        final module = composition![control.moduleId];
        module[control.id] = control;
        control.update();
        midi.mapping.update(control);
      });
      final theme = this['theme'];
      if (theme != null) {
        _theme = ThemeMode.values[theme['value']];
      }
      menuSubscription = aes.bus.on<MenuEvent>().listen((event) async {
        switch (event.selection) {
          case MenuSelection.newComposition:
            composition = await alib.newComposition();
            presets.clear();
            bus.fire(CompositionChangedEvent());
            compositionFile.value = null;
          case MenuSelection.openComposition:
            final r = this['composition.files.directory'];
            //final directory = r != null ? r['path'] : null;
            final result = await picker.FilePicker.platform.pickFiles(
              type: picker.FileType.custom,
              withData: true,
              allowedExtensions: ['aes'],
            );
            if (result != null) {
              try {
                final cfile = CompositionFile.fromBytes(
                  result.files.first.bytes!,
                );
                composition = await alib.newComposition();
                composition = await alib.updateComposition(cfile.composition);
                presets.set(cfile.presets);
                compositionFile.value = result.files.first.path;
                bus.fire(CompositionChangedEvent());
                this['composition.files.composition'] = {
                  'file': result.files.first.path!,
                };
                this['composition.files.directory'] = {
                  'path': path.dirname(result.files.first.path!),
                };
              } catch (e) {
                Debug.error(e);
                // TODO: display error message
              }
            }
          case MenuSelection.saveComposition:
            if (compositionFile.value == null) {
              continue saveAs;
            }
            final cfile = CompositionFile(
              composition: composition!,
              presets: presets,
            );
            final file = File(compositionFile.value!);
            final json = jsonEncode(cfile.toJson());
            await file.writeAsString(json);
          saveAs:
          case MenuSelection.saveCompositionAs:
          // TODO: replace FilePicker
          /*
            final filename = await picker.FilePicker.platform.saveFile(
              dialogTitle: 'Save composition',
              type: picker.FileType.custom,
              allowedExtensions: ['aes'],
              fileName: 'composition.aes',
            );
            if (filename != null) {
              try {
                final realname =
                    '${path.dirname(filename)}/${path.basenameWithoutExtension(filename)}.aes';
                final file = File(realname);
                composition = await alib.composition();
                composition!.name = path.basenameWithoutExtension(realname);
                final cfile = CompositionFile(
                  composition: composition!,
                  presets: presets,
                );
                final json = jsonEncode(cfile.toJson());
                await file.writeAsString(json);
                compositionFile.value = realname;
                this['composition.files.composition'] = {'file': realname};
                this['composition.files.directory'] = {
                  'path': path.dirname(file.path),
                };
                alib.updateComposition(composition!);
                bus.fire(
                  CompositionChangedEvent(),
                ); // update UI and display problem in case of error
              } catch (e) {
                Debug.error(e);
                // TODO:
              }
            }
            */
          default:
        }
      });
      dbgMessagesSubscription = aes.message.listenMessage((message) {
        // 4debug
        Debug.warning(message);
      });
      final s = this['settings'];
      if (s != null) {
        final ss = Settings.fromJson(s);
        compositionSettings = ss.composition;
        midi.settings = ss.midi;
        bus.fire(SettingsChangeEvent());
      }
    } catch (e) {
      Debug.error(e);
    }
  }

  Future<void> loadLastComposition() async {
    final r = this['composition.files.composition'];
    if (r == null) return;
    final file = File(r['file']);
    if (!await file.exists()) return;
    try {
      final cfile = CompositionFile.fromJson(
        jsonDecode(await file.readAsString()),
      );
      composition = await alib.updateComposition(cfile.composition);
      presets.set(cfile.presets);
      compositionFile.value = file.path;
      bus.fire(CompositionChangedEvent());
    } catch (e) {
      Debug.error(e);
    }
  }

  Future<void> windowSetup() async {
    if (Platform.isMacOS) {
      final bounds = this['windowBounds'];
      const minWindowSize = Size(900, 600);
      final windowSize = bounds != null
          ? RectExt.fromJson(bounds).size
          : minWindowSize;
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        size: windowSize,
        minimumSize: minWindowSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  Map<String, dynamic>? operator [](String key) {
    final v = prefs.getString(key);
    if (v != null) {
      try {
        return jsonDecode(v);
      } catch (e) {
        Debug.error(e);
      }
    }
    return null;
  }

  void operator []=(String key, Map value) {
    prefs.setString(key, jsonEncode(value));
  }

  Duration fadeDuration = const Duration(milliseconds: 200);
  Duration animDuration = const Duration(milliseconds: 100);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class PreviewManager {
  final Map<String, StreamController<PreviewInfo>> streamController = {};
  final Map<String, Image> images = {};

  StreamSubscription<PreviewInfo> listen({
    required String moduleId,
    String? assetId,
    required void Function(PreviewInfo) onData,
  }) {
    final key = "$moduleId.$assetId";
    if (!streamController.containsKey(key)) {
      streamController[key] = StreamController<PreviewInfo>.broadcast();
    }
    return streamController[key]!.stream.listen(onData);
  }

  void add(alib.Preview preview) async {
    final key = "${preview.moduleId}.${preview.assetId}";
    if (!streamController.containsKey(key)) {
      streamController[key] = StreamController<PreviewInfo>.broadcast();
    }
    final image = Image.memory(
      preview.data,
      fit: BoxFit.cover,
      cacheHeight: 90,
      height: 90,
    );
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((info, _) {
            images[key] = image;
            streamController[key]!.add(preview.info);
          }),
        );
  }

  Image? operator [](String key) => images[key];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class TextureManager {
  final Map<String, StreamController<AssetTexture>> streamController = {};
  final Map<String, AssetTexture> textures = {};
  StreamSubscription<AssetTexture> listen({
    required String moduleId,
    String? assetId,
    required void Function(AssetTexture) onData,
  }) {
    final key = "$moduleId.$assetId";
    if (!streamController.containsKey(key)) {
      streamController[key] = StreamController<AssetTexture>.broadcast();
    }
    return streamController[key]!.stream.listen(onData);
  }

  void add(AssetTexture texture) async {
    final key = "${texture.moduleId}.${texture.assetId}";
    if (!streamController.containsKey(key)) {
      streamController[key] = StreamController<AssetTexture>.broadcast();
    }
    textures[key] = texture;
    streamController[key]!.add(texture);
  }

  AssetTexture? operator [](String key) => textures[key];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum MenuSelection {
  about,
  newComposition,
  openComposition,
  saveComposition,
  saveCompositionAs,
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class MenuEvent {
  final MenuSelection selection;
  MenuEvent(this.selection);
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

class CompositionChangedEvent {}

class CompositionTitleChangedEvent {}

/////////////////////////////////////////////////////////////////////////////////////////////////
class ModuleChangeEvent {
  final Module module;
  ModuleChangeEvent(this.module);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class AddModuleEvent {
  final ModuleType type;
  final Module? at;
  AddModuleEvent({required this.type, this.at});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class InsertModuleEvent {
  final ModuleType type;
  final Module at;
  InsertModuleEvent({required this.type, required this.at});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class RemoveModuleEvent {
  final Module module;
  RemoveModuleEvent({required this.module});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class AddAssetsEvent {
  final Module module;
  final List<Asset> assets;
  AddAssetsEvent({required this.module, required this.assets});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class RemoveAssetsEvent {
  final Module module;
  final List<Asset> assets;
  RemoveAssetsEvent({required this.module, required this.assets});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class StatisticsUpdateEvent {
  final CompositionStatistics statistics;
  StatisticsUpdateEvent({required this.statistics});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class AudioEvent {
  final AudioLevel audio;
  AudioEvent(this.audio);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class ThemeChangeEvent {
  final ThemeMode theme;
  ThemeChangeEvent(this.theme);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum ControlChangeSource { ui, midi, preset }

class ControlChangeEvent {
  // app -> engine
  final Control control;
  final ControlChangeSource source;
  ControlChangeEvent({required this.control, required this.source});
}

/////////////////////////////////////////////////////////////////////////////////////////////////
extension ControlAppExtension on Control {
  String get key => "$moduleId.$id";
  void change({required ControlChangeSource source}) {
    aes.bus.fire(ControlChangeEvent(control: this, source: source));
  }

  StreamSubscription<Control> listen(void Function(Control) onData) {
    if (!aes.controlUpdateEvents.containsKey(key)) {
      aes.controlUpdateEvents[key] = StreamController<Control>.broadcast();
    }
    return aes.controlUpdateEvents[key]!.stream.listen(onData);
  }

  void update() {
    if (!aes.controlUpdateEvents.containsKey(key)) {
      aes.controlUpdateEvents[key] = StreamController<Control>.broadcast();
    }
    aes.controlUpdateEvents[key]!.add(this);
  }

  static Control fromKey(String key) {
    final parts = key.split('.');
    final moduleId = parts[0];
    final controlId = parts.sublist(1).join('.');
    return aes.composition![moduleId][controlId];
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class SettingsChangeEvent {} // app -> engine

class SettingsUpdateEvent {} // engine -> app

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
