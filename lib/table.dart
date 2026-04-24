import 'dart:async';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import 'about.dart';
import 'aestesis.dart';
import 'midi/midi.mapping.editor.dart';
import 'module.dart';
import 'core/presets.editor.dart';
import 'status/status.bar.dart';
import 'ui/menu.context.dart';
import 'ui/menu.dart';
import 'ui/sliver.grid.delegate.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class TableView extends StatefulWidget {
  const TableView({super.key});
  @override
  State<TableView> createState() => TableViewState();
  static TableViewState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<TableViewState>();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class TableViewState extends State<TableView> {
  final scrollController = ScrollController();
  late final StreamSubscription compositionChangedSubscription;
  late final StreamSubscription aboutSubscription;
  TableOption option = TableOption.none;
  bool about = false;
  String? dragging;
  String? selected;
  List<Module> get modules =>
      aes.composition!.modules.whereType<Module>().toList();
  @override
  void initState() {
    super.initState();
    compositionChangedSubscription = aes.bus
        .on<CompositionChangedEvent>()
        .listen((event) {
          setState(() {
            dragging = null;
          });
        });
    aboutSubscription = aes.bus.on<MenuEvent>().listen((event) {
      if (event.selection == MenuSelection.about) {
        setState(() {
          about = true;
        });
      }
    });
    loadComposition();
  }

  void loadComposition() async {
    await Future.delayed(const Duration(seconds: 1));
    await aes.loadLastComposition();
  }

  @override
  void dispose() {
    compositionChangedSubscription.cancel();
    aboutSubscription.cancel();
    super.dispose();
  }

  void select(TableOption option) {
    setState(() {
      this.option = option;
    });
    if (option != TableOption.none) {
      Timer(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: aes.fadeDuration,
          curve: Curves.decelerate,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UIContextMenu(
      isRoot: true,
      menu: [
        ...ModuleType.values.map(
          (type) => UIMenuItem(
            text: 'Add ${type.name.toLowerCase()}',
            icon: type.icon,
            onTap: () {
              aes.bus.fire(AddModuleEvent(type: type));
            },
          ),
        ),
      ],
      child: Column(
        children: [
          if (about)
            Expanded(
              child: About(
                onClose: () {
                  setState(() {
                    about = false;
                  });
                },
              ),
            )
          else
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    if (modules.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverReorderableGrid(
                          gridDelegate:
                              SliverGridDelegateWithMinMaxCrossAxisExtent(
                                maxCrossAxisCount: modules.length,
                                minCrossAxisExtent: 840,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 300,
                              ),
                          itemBuilder: (BuildContext context, int index) =>
                              ModuleView(
                                key: Key(modules[index].id),
                                moduleIndex: index,
                                moduleId: modules[index].id,
                                dragging: dragging == modules[index].id,
                                selected: selected == modules[index].id,
                                onSelected: (sel) {
                                  if (sel && selected == modules[index].id) {
                                    return;
                                  }
                                  setState(() {
                                    selected = sel ? modules[index].id : null;
                                  });
                                },
                              ),
                          itemCount: modules.length,
                          onReorder: reorderModule,
                        ),
                      ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const Spacer(),
                          if (option == TableOption.mapping)
                            MidiMappingEditor(
                              onClose: () {
                                setState(() {
                                  option = TableOption.none;
                                });
                              },
                            ),
                          if (option == TableOption.presets)
                            PresetsEditor(
                              onClose: () {
                                setState(() {
                                  option = TableOption.none;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          StatusBar(
            option: option,
            onChanged: (option) {
              select(option);
            },
          ),
        ],
      ),
    );
  }

  void reorderModule(int oldIndex, int newIndex) async {
    final modules = this.modules;
    final id = modules[oldIndex].id;
    final item = modules.removeAt(oldIndex);
    modules.insert(newIndex, item);
    setState(() {
      dragging = id;
    });
    aes.composition!.modules = modules;
    aes.composition = await aes.alib.updateComposition(aes.composition!);
    aes.bus.fire(CompositionChangedEvent());
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
enum TableOption { none, mapping, presets }

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
