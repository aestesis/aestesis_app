import 'dart:io';

import 'package:flutter/material.dart';

import 'aestesis.dart';

/// Flutter code sample for [AEMenuBar].

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class AEMenuBar extends StatelessWidget {
  final Widget child;
  const AEMenuBar({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return MacMenuBar(child: child);
    }
    return child;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class MacMenuBar extends StatefulWidget {
  final Widget child;
  const MacMenuBar({super.key, required this.child});
  @override
  State<MacMenuBar> createState() => _MacMenuBarState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _MacMenuBarState extends State<MacMenuBar> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(menus: <PlatformMenuItem>[
      PlatformMenu(
        label: 'Aestesis',
        menus: <PlatformMenuItem>[
          PlatformMenuItemGroup(
            members: <PlatformMenuItem>[
              PlatformMenuItem(
                label: 'About',
                onSelected: () {
                  aes.bus.fire(MenuEvent(MenuSelection.about));
                },
              ),
            ],
          ),
          if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit))
            const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit),
        ],
      ),
      PlatformMenu(label: 'File', menus: [
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformMenuItem(
                label: 'New composition',
                shortcut: const CharacterActivator('n', meta: true),
                onSelected: () {
                  aes.bus.fire(MenuEvent(MenuSelection.newComposition));
                }),
          ],
        ),
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformMenuItem(
                label: 'Open composition',
                shortcut: const CharacterActivator('o', meta: true),
                onSelected: () {
                  aes.bus.fire(MenuEvent(MenuSelection.openComposition));
                }),
          ],
        ),
        PlatformMenuItemGroup(
          members: <PlatformMenuItem>[
            PlatformMenuItem(
                label: 'Save composition',
                shortcut: const CharacterActivator('s', meta: true),
                onSelected: () {
                  aes.bus.fire(MenuEvent(MenuSelection.saveComposition));
                }),
            PlatformMenuItem(
                label: 'Save composition as...',
                shortcut: const CharacterActivator('S', meta: true),
                onSelected: () {
                  aes.bus.fire(MenuEvent(MenuSelection.saveCompositionAs));
                }),
          ],
        ),
      ])
    ], child: widget.child);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
