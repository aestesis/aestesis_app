# Aestesis (aestesis_app)

<div align="center">

[![GitHub release](https://img.shields.io/badge/version-0.1.0+1-blue.svg)](https://github.com/aestesis/aestesis_app/releases)
[![Flutter version](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-%2302569B.svg)](https://flutter.dev)
[![Dart version](https://img.shields.io/badge/Dart-%3E%3D3.10.0-green.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

<div align="center">

[![GitHub Stars](https://img.shields.io/github/stars/aestesis/aestesis_app?style=flat&label=%E2%B8%8D)](https://github.com/aestesis/aestesis_app/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/aestesis/aestesis_app?style=flat&label=%E2%8B%AF)](https://github.com/aestesis/aestesis_app/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/aestesis/aestesis_app?style=flat&label=🐛)](https://github.com/aestesis/aestesis_app/issues)
[![GitHub Closed Issues](https://img.shields.io/github/issues-closed/aestesis/aestesis_app?style=flat&label=✅)](https://github.com/aestesis/aestesis_app/issues?q=is%3Aissue+is%3Aclosed)
[![GitHub Size](https://img.shields.io/github/repo-size/aestesis/aestesis_app?style=flat&label=📦)](https://github.com/aestesis/aestesis_app)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/aestesis/aestesis_app?style=flat&label=🕐)](https://github.com/aestesis/aestesis_app/commits/main)

</div>

<div align="center">

[![GitHub Code Size](https://img.shields.io/github/languages/code-size/aestesis/aestesis_app?style=flat&label=📏)](https://github.com/aestesis/aestesis_app)
[![GitHub Contributions](https://img.shields.io/github/contributors/aestesis/aestesis_app?style=flat&label=👥)](https://github.com/aestesis/aestesis_app/graphs/contributors)

</div>

<div align="center">
<div style="border: 2px solid #333; border-radius: 10px; padding: 15px; margin: 30px 0;">
<div style="font-family: monospace; font-size: 14px;">
<div>▀▄▀▄▀▄▀▄▀▄▀█▓▒▒░░░ (c) AESTESIS 2023 ░░░▒▒▓█▀▄▀▄▀▄▀▄▀▄▀</div>
</div>
</div>
</div>


## 🎬 About

**Aestesis** is a professional desktop application designed for [VJing](https://en.wikipedia.org/wiki/VJing) and live visual performance. Built with Flutter, it serves as the user interface and orchestration layer for building real-time visual compositions.

Aestesis allows artists to:
- 🎥 Manage video and audio assets
- ✨ Apply real-time effects via modular nodes
- 🎛️ Map UI controls to MIDI hardware
- 🌈 Create audio-reactive visuals
- 💾 Save and load custom compositions (`.aes` format)


## 🎨 Features

### Core Capabilities

- ✅ **Modular Architecture** - Add/remove modules at runtime
- ✅ **MIDI Integration** - Map hardware controllers (knobs, buttons, faders)
- ✅ **Asset Management** - Drag & drop video files (.mp4, .mov, .mv4, etc.)
- ✅ **Real-time Effects** - GLSL shaders, LUTs, video filters
- ✅ **Multi-module Pipeline** - Chain multiple modules in a composition
- ✅ **Composition System** - Save/load custom setups (.aes)
- ✅ **Theme Support** - Light/dark mode switching
- ✅ **Platform Support** - macOS
- ✅ **Audio Visualization** - Real-time audio level meters
- ✅ **Camera Routing** - Virtual/external camera support

### Visual Modules

| Module   | Description                                  |
| -------- | -------------------------------------------- |
| `Player` | MV4/MP4/MOV/3GP media playback with controls |
| `FX`     | Video filters and visual effects             |
| `LUT`    | Color grading with LUT support               |
| `Shader` | Real-time GLSL shader execution              |
| `Analog` | Analog-inspired Mixer                        |
| `Syn`    | Audio-reactive synthesizer visuals           |
| `Camera` | Virtual/external camera input routing        |


## 🎼 MIDI Integration

Aestesis supports MIDI controller mapping for live performance:

- **Hardware Mapping** - Connect knobs, buttons, and faders
- **Channel Filtering** - Filter MIDI channels per device
- **Multi-device** - Support for multiple MIDI sources

## 📖 Usage

### Creating a Composition

1. **Open the app**
2. **Add modules** (right click > Add Module menu)
3. **Load assets** (drag & drop video files or use File > Add Assets)
4. **Configure modules** (select assets, set controls)
5. **Map MIDI** (connect your controller and map controls)
6. **Save** your composition (File > Save)

## 📄 License

This project is licensed under the [Apache 2.0 License](LICENSE).


## 📞 Support

<div align="center">

[![Website](https://img.shields.io/badge/Website-aestesis.org-blue)](https://aestesis.org)
[![Bluesky](https://img.shields.io/badge/Bluesky-aestesis.bsky.social-1DA1F2?style=flat&logo=bluesky&logoColor=white)](https://bsky.app/profile/aestesis.bsky.social)

</div>

<div align="center">
Made with ❤️ by the Aestesis team
</div>
