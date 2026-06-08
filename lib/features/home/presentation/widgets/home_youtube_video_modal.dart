import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoModal extends StatefulWidget {
  final String videoUrl;

  const YoutubeVideoModal({super.key, required this.videoUrl});

  static void show(BuildContext context, String videoUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => YoutubeVideoModal(videoUrl: videoUrl),
    );
  }

  @override
  State<YoutubeVideoModal> createState() => _YoutubeVideoModalState();
}

class _YoutubeVideoModalState extends State<YoutubeVideoModal> {
  late YoutubePlayerController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    } else {
      _isValid = false;
    }
  }

  @override
  void dispose() {
    if (_isValid) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VIDEO',
                  style: TextStyle(
                    color: context.primaryGold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Player
          Expanded(
            child: Center(
              child: _isValid
                  ? YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: context.primaryGold,
                      onReady: () {
                        // _controller.addListener(listener);
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Enlace de video no válido',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.videoUrl,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
