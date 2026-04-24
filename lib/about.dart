import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'aestesis.dart';
import 'ui/button.dart';
import 'ui/icon.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class About extends StatefulWidget {
  final VoidCallback? onClose;
  const About({super.key, this.onClose});
  @override
  State<About> createState() => _AboutState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AboutState extends State<About> {
  bool license = false;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (license)
        const Center(child: SizedBox(width: 1200, child: LicensePage()))
      else
        Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 400,
              height: 240,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha:0.2),
                      width: 1.0)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SvgPicture.asset(
                    'assets/svg/brands/aestesis.logo.color.bis.svg',
                    width: 150,
                    height: 150),
                const SizedBox(width: 20),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('aestesis',
                        style: Theme.of(context).textTheme.headlineLarge!.apply(
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 20),
                    Text('Version ${aes.package.version}',
                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 20),
                    Text('© 2023 aestesis',
                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                            color: Theme.of(context).colorScheme.primary)),
                  ],
                ))
              ])),
          const SizedBox(height: 20),
          
          InkWell(
              child: Text('Licenses',
                  style: TextTheme.of(context)
                      .bodySmall!
                      .apply(color: ColorScheme.of(context).tertiary)),
              onTap: () {
                setState(() {
                  license = true;
                });
              })
        ])),
      Positioned(
          top: 20,
          right: 20,
          child: UIIconButton(
              asset: UIIcon.close,
              size: UISize.large,
              onTap: () {
                widget.onClose?.call();
              }))
    ]);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
