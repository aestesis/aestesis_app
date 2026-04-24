import 'dart:async';
import 'dart:math';

import 'package:aestesis_engine/aestesis_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../aestesis.dart';
import '../core/native.view.dart';

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class AssetView extends StatefulWidget {
  final String moduleId;
  final Asset asset;
  final bool selected;
  final VoidCallback? onTap;
  final bool? live;
  final Control? control;
  final BorderRadiusGeometry borderRadius;
  final Color color;
  final double gain;
  const AssetView(
      {super.key,
      required this.asset,
      this.selected = false,
      this.onTap,
      required this.moduleId,
      this.live,
      this.control,
      this.color = Colors.white,
      this.gain = 1,
      this.borderRadius = const BorderRadius.all(Radius.circular(5))});
  @override
  State<AssetView> createState() => _AssetViewState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _AssetViewState extends State<AssetView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final animation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final key = "${widget.moduleId}.${widget.asset.id}";
  late final StreamSubscription previewSubscription;
  @override
  void initState() {
    //Debug.info("AssetView.initState: ${widget.moduleId} ${widget.asset.id}");
    super.initState();
    previewSubscription = aes.previews.listen(
        moduleId: widget.moduleId,
        assetId: widget.asset.id,
        onData: (preview) {
          setState(() {});
          if (!(widget.live == true || widget.selected)) {
            animation.reverse();
          }
        });
    animation.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.live == true || widget.selected) {
      animation.forward();
    } else {
      animation.reverse();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    previewSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AssetView oldWidget) {
    if (widget.live == true || widget.selected) {
      animation.forward();
    } else {
      animation.reverse();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final color = widget.selected
        ? ColorScheme.of(context).tertiary
        : ColorScheme.of(context).primaryContainer;
    final textColor = widget.selected
        ? ColorScheme.of(context).onTertiary
        : ColorScheme.of(context).onPrimaryContainer.withValues(alpha:0.6);
    return Center(
        child: GestureDetector(
            onTap: widget.onTap,
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ClipRRect(
                    borderRadius: widget.borderRadius,
                    child: Container(
                        width: 160,
                        height: 90,
                        color: color.withValues(alpha:0.4),
                        child: Center(
                            child: Stack(children: [
                          if (aes.previews[key] != null && animation.value < 1)
                            aes.previews[key]!,
                          if (animation.value > 0)
                            Opacity(
                                opacity: animation.value,
                                child: NativeView(
                                    color: widget.color, // not used with FlutterTexture
                                    gain: widget.gain,  // not used with FlutterTexture
                                    moduleId: widget.moduleId,
                                    assetId: widget.asset.id)),
                          if (widget.selected)
                            Positioned(
                                top: 0,
                                child: ControlProgress(
                                    control: widget.control, color: color)),
                          Positioned(
                              bottom: 0,
                              child: Container(
                                  width: 160,
                                  height: 15,
                                  color: color.withValues(alpha:0.6),
                                  child: Text(widget.asset.name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.clip,
                                      style: TextTheme.of(context)
                                          .bodySmall!
                                          .apply(color: textColor))))
                        ])))))));
  }

  @override
  bool get wantKeepAlive => true;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
class ControlProgress extends StatefulWidget {
  final Control? control;
  final Color color;
  const ControlProgress({super.key, this.control, required this.color});
  @override
  State<ControlProgress> createState() => _ControlProgressState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
class _ControlProgressState extends State<ControlProgress>
    with TickerProviderStateMixin {
  StreamSubscription? controlSubscription;
  double progress = 0;
  double setProgress = 0;
  Ticker? ticker;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setControlSubscription();
    });
  }

  @override
  void dispose() {
    controlSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ControlProgress oldWidget) {
    if (widget.control != oldWidget.control) {
      controlSubscription?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setControlSubscription();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void setTicker(bool activated) {
    if (activated) {
      widget.control?.value = setProgress;
      widget.control?.change(source: ControlChangeSource.ui);
      if (ticker != null) return;
      ticker = createTicker((_) {
        widget.control?.value = setProgress;
        widget.control?.change(source: ControlChangeSource.ui);
      });
      ticker!.start();
    } else {
      ticker?.dispose();
      ticker = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double width = 160;
    return GestureDetector(
        onTapDown: (d) {
          setProgress = d.localPosition.dx / width;
          setTicker(true);
        },
        onLongPressMoveUpdate: (d) {
          setProgress = d.localPosition.dx / width;
          setTicker(true);
        },
        onHorizontalDragUpdate: (d) {
          setProgress = d.localPosition.dx / width;
          setTicker(true);
        },
        onTapUp: (details) {
          setTicker(false);
        },
        onLongPressUp: () {
          setTicker(false);
        },
        onHorizontalDragEnd: (_) {
          setTicker(false);
        },
        child: SizedBox(
            width: width,
            height: 15,
            child: Row(children: [
              if (progress > 0)
                Container(
                  width: width * progress,
                  height: 15,
                  color: widget.color.withValues(alpha:0.9),
                ),
              Expanded(
                  child: Container(
                height: 15,
                color: widget.color.withValues(alpha:0.6),
              ))
            ])));
  }

  void setControlSubscription() {
    if (widget.control != null) {
      controlSubscription = widget.control!.listen((control) {
        if (!mounted) return;
        setState(() {
          progress = max(min(control.value, 1), 0);
        });
      });
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
