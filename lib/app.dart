import 'dart:async';

import 'package:flutter/material.dart';

import 'aestesis.dart';
import 'home.dart';
import 'ui/color.scheme.dart';
import 'window.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AppState extends State<App> {
  late final StreamSubscription themeChangedSubscription;
  @override
  void initState() {
    super.initState();
    themeChangedSubscription = aes.bus.on<ThemeChangeEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    themeChangedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AEWindowManager(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'aestesis',
      themeMode: aes.theme,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          tooltipTheme: TooltipThemeData(
              textStyle: TextTheme.of(context).bodySmall!.apply(
                  color:
                      lightColorScheme.onSecondaryContainer.withValues(alpha:0.8)),
              decoration: BoxDecoration(
                  color: lightColorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10))),
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                  lightColorScheme.inversePrimary.withValues(alpha:0.5)))),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          tooltipTheme: TooltipThemeData(
              textStyle: TextTheme.of(context).bodySmall!.apply(
                  color: darkColorScheme.onSecondaryContainer.withValues(alpha:0.8)),
              decoration: BoxDecoration(
                  color: darkColorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10))),
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                  darkColorScheme.inversePrimary.withValues(alpha:0.5)))),
      home: const Home(),
    ));
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
