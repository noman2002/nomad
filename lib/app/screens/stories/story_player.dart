import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({super.key, required this.videoUrl, this.onDoubleTap});

  final String videoUrl;
  final VoidCallback? onDoubleTap;

  @override
  State<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void didUpdateWidget(covariant StoryPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          _controller?.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: widget.onDoubleTap,
      child: _controller != null && _controller!.value.isInitialized
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
