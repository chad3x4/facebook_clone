import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCard extends StatefulWidget {
  static Duration videoDuration = Duration.zero;
  final File video;

  const VideoPlayerCard({super.key, required this.video});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late VideoPlayerController controller;


  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {
          controller.setVolume(1.0);
          controller.play();
        });
      });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    controller.dispose();
    VideoPlayerCard.videoDuration = Duration.zero;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlickManager flickManager = FlickManager(videoPlayerController: controller);
    return Stack(
      alignment: Alignment.center,
      children: [
        controller.value.isInitialized
        ? AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: FlickVideoPlayer(flickManager: flickManager),
        )
        : const CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 5,
        )
      ],
    );
  }
}
