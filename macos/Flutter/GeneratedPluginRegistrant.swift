//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import aestesis_engine
import desktop_drop
import midi_io
import open_file_macos
import package_info_plus
import screen_retriever_macos
import shared_preferences_foundation
import url_launcher_macos
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AestesisEnginePlugin.register(with: registry.registrar(forPlugin: "AestesisEnginePlugin"))
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  MidiIoPlugin.register(with: registry.registrar(forPlugin: "MidiIoPlugin"))
  OpenFileMacosPlugin.register(with: registry.registrar(forPlugin: "OpenFileMacosPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
