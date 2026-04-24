import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:url_launcher/url_launcher.dart';

import 'aestesis.dart';
import 'menu.bar.dart';
import 'table.dart';
import 'ui/button.dart';
import 'ui/menu.button.dart';
import 'ui/icon.dart';
import 'ui/menu.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _HomeState extends State<Home> {
  late final StreamSubscription titleSubscription;
  @override
  void initState() {
    super.initState();
    titleSubscription =
        aes.bus.on<CompositionTitleChangedEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    titleSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
        child: Scaffold(
            appBar: AppBar(
                toolbarHeight: 30,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Row(children: [
                  const SizedBox(width:80),
                  Expanded(
                      child: Center(
                          child: Text(aes.title,
                              style: TextTheme.of(context).titleSmall!.apply(
                                  color: ColorScheme.of(context)
                                      .onSurface
                                      .withValues(alpha:0.8))))),
                  filesButton(),
                  const SizedBox(width: 10),
                  UIIconButton(
                      tooltip: 'Theme mode',
                      asset: aes.theme == ThemeMode.dark
                          ? UIIcon.darkTheme
                          : UIIcon.lightTheme,
                      onTap: () {
                        aes.theme = aes.theme == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                      }),
                  const SizedBox(width: 10),
                  aestesisButton(),
                  const SizedBox(width: 10),
                ])),
            body: const AEMenuBar(child: TableView())));
  }

  Widget aestesisButton() => UIMenuIconButton(
          itemWidth: 120,
          asset: UIIcon.aestesis,
          tooltip: 'Aestesis links',
          menu: [
            UIMenuItem(
                icon: UIIcon.aestesis,
                text: 'Aestesis',
                onTap: () {
                  launchUrl(Uri.parse(aes.aestesisUrl));
                }),
            const UIDivider(),
            UIMenuItem(
                icon: UIIcon.wikipedia,
                text: 'History',
                onTap: () {
                  launchUrl(Uri.parse(aes.wikipediaVJ));
                }),
            const UIDivider(),
            UIMenuItem(
                icon: UIIcon.discord,
                text: 'Discord',
                onTap: () {
                  launchUrl(Uri.parse(aes.discord));
                }),
            UIMenuItem(
                icon: UIIcon.social,
                text: 'Bluesky',
                onTap: () {
                  launchUrl(Uri.parse(aes.bluesky));
                }),
            UIMenuItem(
                icon: UIIcon.contactUs,
                text: 'Contact us',
                onTap: () {
                  launchUrl(Uri.parse(aes.contactUs));
                }),
            const UIDivider(),
            UIMenuItem(
                icon: UIIcon.about,
                text: 'About',
                onTap: () {
                  aes.bus.fire(MenuEvent(MenuSelection.about));
                }),
          ]);

  Widget filesButton() => UIMenuIconButton(
          itemWidth: 180,
          asset: UIIcon.files,
          tooltip: 'File',
          menu: [
            UIMenuItem(
                icon: UIIcon.filesNew,
                text: 'New composition',
                onTap: () {
                  aes.bus.fire(MenuEvent(MenuSelection.newComposition));
                }),
            const UIDivider(),
            UIMenuItem(
                icon: UIIcon.filesOpen,
                text: 'Open composition',
                onTap: () {
                  aes.bus.fire(MenuEvent(MenuSelection.openComposition));
                }),
            const UIDivider(),
            UIMenuItem(
                icon: UIIcon.filesSave,
                text: 'Save composition',
                onTap: () {
                  aes.bus.fire(MenuEvent(MenuSelection.saveComposition));
                }),
            UIMenuItem(
                icon: UIIcon.filesSaveAs,
                text: 'Save composition as...',
                onTap: () {
                  aes.bus.fire(MenuEvent(MenuSelection.saveCompositionAs));
                }),
          ]);
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
