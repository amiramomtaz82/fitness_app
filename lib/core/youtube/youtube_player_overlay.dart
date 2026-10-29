import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_playback_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlayerOverlay extends StatefulWidget {
  const PlayerOverlay({
    super.key,
    required this.showBackButton,
    required this.onBack,
    required this.playFailed,
    required this.onRetry,
  });

  final bool showBackButton;
  final VoidCallback? onBack;
  final bool playFailed;
  final VoidCallback onRetry;

  @override
  State<PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<PlayerOverlay> {
  final LayerLink layerLink = LayerLink();
  final OverlayPortalController portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        portal.show();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: portal,
      overlayChildBuilder: (context, info) {
        return CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          child: SizedBox(
            width: info.childSize.width,
            height: info.childSize.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.playFailed) PlaybackFailure(onRetry: widget.onRetry),
                if (widget.showBackButton) BackOverlay(onBack: widget.onBack),
              ],
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class BackOverlay extends StatelessWidget {
  const BackOverlay({super.key, required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 12.h,
      start: 12.w,
      child: VideoBackButton(onPressed: onBack),
    );
  }
}

class VideoBackButton extends StatelessWidget {
  const VideoBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface.withValues(alpha: 0.72),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('app_youtube_video_back'),
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40.r,
          height: 40.r,
          child: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primary,
            size: 18.r,
          ),
        ),
      ),
    );
  }
}
