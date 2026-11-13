import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/home/controllers/advertisement_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:video_player/video_player.dart';

const double _kControlButtonSize = 36;
const double _kControlIconSize = 20;
const double _kProgressBarHeight = 3;
const double _kScrubberTouchPadding = 10;
const Duration _kControlsHideDelay = Duration(seconds: 3);
const Duration _kControlsFadeDuration = Duration(milliseconds: 200);
const double _kUnmutedVolume = 1;

final VideoProgressColors _kProgressColors = VideoProgressColors(
  playedColor: Colors.white,
  bufferedColor: Colors.white.withOpacity(0.35),
  backgroundColor: Colors.white.withOpacity(0.18),
);

/// Autoplaying, muted advertisement video.
class AdVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double aspectRatioMultiplier;

  const AdVideoPlayerWidget({super.key, required this.videoUrl, this.aspectRatioMultiplier = 1});

  @override
  State<AdVideoPlayerWidget> createState() => _AdVideoPlayerWidgetState();
}

class _AdVideoPlayerWidgetState extends State<AdVideoPlayerWidget> {
  VideoPlayerController? _controller;
  Timer? _hideControlsTimer;
  bool _initialized = false;
  bool _hasError = false;
  bool _muted = true;
  bool _controlsVisible = false;
  bool _completionReported = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = controller;
    controller.addListener(_onVideoTick);
    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(0);
      await controller.play();
      _initialized = true;
    } catch (_) {
      _hasError = true;
      _completionReported = true;
      _resumeCarouselAutoPlay();
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant AdVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      _hideControlsTimer?.cancel();
      _initialized = false;
      _hasError = false;
      _muted = true;
      _controlsVisible = false;
      _completionReported = false;
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    _controller = null;
  }

  void _onVideoTick() {
    final VideoPlayerController? controller = _controller;
    if (controller == null || _completionReported) return;

    final VideoPlayerValue value = controller.value;
    final bool reachedEnd = value.isCompleted
        || (value.duration > Duration.zero && value.position >= value.duration);
    if (!reachedEnd) return;

    _completionReported = true;
    _resumeCarouselAutoPlay();
  }

  void _resumeCarouselAutoPlay() {
    if (GetPlatform.isWeb) {
      Future.delayed(const Duration(seconds: 4), () {
        Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
      });
    } else {
      Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
    }
  }

  void _handleTap() {
    if (_controlsVisible) {
      _hideControlsTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      setState(() => _controlsVisible = true);
      _restartHideTimer();
    }
  }

  void _restartHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(_kControlsHideDelay, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _togglePlayPause() {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _restartHideTimer();
  }

  void _toggleMute() {
    final VideoPlayerController? controller = _controller;
    if (controller == null) return;
    setState(() => _muted = !_muted);
    controller.setVolume(_muted ? 0 : _kUnmutedVolume);
    _restartHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;

    if (_hasError) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 28)),
      );
    }
    if (controller == null || !_initialized) {
      return const ColoredBox(color: Colors.black, child: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Stack(fit: StackFit.expand, children: [
        const ColoredBox(color: Colors.black),
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio * widget.aspectRatioMultiplier,
            child: VideoPlayer(controller),
          ),
        ),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (BuildContext context, VideoPlayerValue value, Widget? child) {
            return Stack(fit: StackFit.expand, children: [
              if (value.isBuffering) const Center(
                child: SizedBox(
                  height: _kControlIconSize, width: _kControlIconSize,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
              IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: _kControlsFadeDuration,
                  child: Stack(fit: StackFit.expand, children: [
                    Center(
                      child: _AdVideoControlButton(
                        icon: value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        onTap: _togglePlayPause,
                      ),
                    ),
                    PositionedDirectional(
                      top: Dimensions.paddingSizeSmall, end: Dimensions.paddingSizeSmall,
                      child: _AdVideoControlButton(
                        icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        onTap: _toggleMute,
                      ),
                    ),
                  ]),
                ),
              ),
            ]);
          },
        ),
        PositionedDirectional(
          start: 0, end: 0, bottom: 0,
          child: AnimatedSize(
            duration: _kControlsFadeDuration,
            alignment: Alignment.bottomCenter,
            child: _controlsVisible
              ? Listener(
                  onPointerDown: (_) => _hideControlsTimer?.cancel(),
                  onPointerUp: (_) => _restartHideTimer(),
                  onPointerCancel: (_) => _restartHideTimer(),
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: _kScrubberTouchPadding),
                    colors: _kProgressColors,
                  ),
                )
              : IgnorePointer(
                  child: SizedBox(
                    height: _kProgressBarHeight,
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: false,
                      padding: EdgeInsets.zero,
                      colors: _kProgressColors,
                    ),
                  ),
                ),
          ),
        ),
      ]),
    );
  }
}

class _AdVideoControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdVideoControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: _kControlButtonSize, width: _kControlButtonSize,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: Colors.white, size: _kControlIconSize),
        ),
      ),
    );
  }
}
