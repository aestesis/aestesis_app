import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
enum UISize {
  small(12),
  medium(16),
  large(24);

  final double value;
  const UISize(this.value);

  TextStyle? bodyStyle(BuildContext context) {
    switch (this) {
      case UISize.small:
        return TextTheme.of(context).labelSmall;
      case UISize.medium:
        return TextTheme.of(context).bodyMedium;
      case UISize.large:
        return TextTheme.of(context).bodyLarge;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case UISize.small:
        return const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2);
      case UISize.medium:
        return const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2);
      case UISize.large:
        return const EdgeInsets.all(5);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
enum UIIcon {
  close(icon: Icons.close),
  arrowDownSoft(svg: 'ui/arrow.down.soft.svg'),
  arrowDownStrong(svg: 'ui/arrow.down.strong.svg'),
  chevronLeft(svg: 'ui/chevron.left.svg'),
  menu(icon: Icons.menu),
  files(icon: Icons.save),
  filesNew(icon: Icons.note_add),
  filesOpen(icon: Icons.file_open),
  filesSave(icon: Icons.save),
  filesSaveAs(icon: Icons.save_as),
  pin(icon: Icons.push_pin),
  help(icon: Icons.help_outline),
  add(icon: Icons.add),
  search(icon: Icons.search),
  notifications(icon: Icons.notifications_off_outlined),
  import(icon: Icons.download),
  remove(icon: Icons.remove),
  delete(icon: Icons.delete),
  darkTheme(icon: Icons.brightness_2),
  lightTheme(icon: Icons.brightness_7),
  feedback(icon: Icons.feedback),
  contactUs(icon: Icons.contact_support),
  discord(icon: Icons.discord),
  wikipedia(icon: LineIcons.wikipediaW),
  social(icon: Icons.share),
  twitch(icon: LineIcons.twitch),
  moduleAnalog(icon: Icons.equalizer),
  moduleCamera(icon: Icons.camera_alt),
  moduleFx(icon: Icons.filter),
  moduleLut(icon: Icons.palette),
  modulePlayer(icon: Icons.play_arrow),
  moduleShader(icon: Icons.filter_vintage),
  moduleSyn(icon: Icons.music_note),
  apple(svg: 'brands/apple.svg'),
  google(svg: 'brands/google.svg', applyColor: false),
  aestesis(svg: 'brands/aestesis.icon.black.svg'),
  aestesisGray(svg: 'brands/aestesis.icon.svg', applyColor: false),
  aestesisColor(svg: 'brands/aestesis.icon.color.svg', applyColor: false),
  aestesisColorBis(
      svg: 'brands/aestesis.icon.color.bis.svg', applyColor: false),
  cameraBack(svg: 'ui/camera.back.svg'),
  cameraBuiltin(svg: 'ui/camera.builtin.svg'),
  cameraContinuity(svg: 'ui/camera.continuity.svg'),
  cameraDeskview(svg: 'ui/camera.deskview.svg'),
  cameraExternal(svg: 'ui/camera.external.svg'),
  cameraFront(svg: 'ui/camera.front.svg'),
  cameraVirtual(svg: 'ui/camera.virtual.svg'),
  midiPort(svg: 'ui/midi.port.svg'),
  edit(icon: Icons.edit),
  mapping(svg: 'ui/mapping.svg'),
  input(icon: Icons.input),
  tv(icon: Icons.tv),
  about(icon: Icons.info_outline),
  recordInactive(svg: 'ui/record.circle.svg'),
  recordActive(svg: 'ui/record.circle.filled.svg'),
  stream(svg: 'ui/stream.svg'),
  previewWindow(svg: 'ui/preview.window.svg'),
  presets(icon: Icons.list),
  finder(icon: Icons.open_in_browser),
  ;

  final IconData? icon;
  final String? svg;
  final bool applyColor;
  const UIIcon({this.icon, this.svg, this.applyColor = true});

  Widget widget({required UISize size, Color? color}) => Container(
      width: size.value,
      height: size.value,
      alignment: Alignment.center,
      child: svg != null
          ? SvgPicture.asset('assets/svg/$svg',
              colorFilter: color == null || !applyColor
                  ? null
                  : ColorFilter.mode(color, BlendMode.srcIn),
              width: size.value,
              height: size.value)
          : Icon(icon, color: applyColor ? color : null, size: size.value));
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

