import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../enums/media_enums.dart';
import '../config/super_media_picker_config.dart';
import '../models/super_media_item.dart';

VideoPlayerController videoControllerFor(SuperMediaItem item) {
  if (item.url != null || kIsWeb) {
    return VideoPlayerController.networkUrl(Uri.parse(item.url ?? item.path!));
  }
  return VideoPlayerController.file(File(item.path!));
}

/// Full-screen image and video preview used by [SuperMediaPicker].
class SuperMediaPreview extends StatelessWidget {
  const SuperMediaPreview({
    super.key,
    required this.item,
    this.text,
    this.locale,
    this.textDirection,
  });

  final SuperMediaItem item;
  final SuperMediaTextConfig? text;
  final Locale? locale;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final effectiveLocale =
        locale ?? View.of(context).platformDispatcher.locale;
    final content = switch (item.type) {
      SuperMediaType.image => _ImagePreview(
        item: item,
        text: _resolvedText(context),
      ),
      SuperMediaType.video => _VideoPreview(
        item: item,
        text: _resolvedText(context),
      ),
      SuperMediaType.file => Scaffold(
        appBar: AppBar(title: Text(item.name)),
        body: const Center(
          child: Icon(Icons.insert_drive_file_outlined, size: 64),
        ),
      ),
    };
    const rtlLanguages = {'ar', 'fa', 'he', 'ur'};
    return Directionality(
      textDirection:
          textDirection ??
          (rtlLanguages.contains(effectiveLocale.languageCode.toLowerCase())
              ? TextDirection.rtl
              : TextDirection.ltr),
      child: content,
    );
  }

  SuperMediaTextConfig _resolvedText(BuildContext context) {
    return text ??
        SuperMediaTextConfig.forLocale(
          locale ?? View.of(context).platformDispatcher.locale,
        );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.item, required this.text});

  final SuperMediaItem item;
  final SuperMediaTextConfig text;

  @override
  Widget build(BuildContext context) {
    final image =
        item.url != null
            ? Image.network(
              item.url!,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, _, _) =>
                      _PreviewError(message: text.unableToDisplayMedia),
            )
            : Image.file(
              File(item.path!),
              fit: BoxFit.contain,
              errorBuilder:
                  (_, _, _) =>
                      _PreviewError(message: text.unableToDisplayMedia),
            );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(item.name),
      ),
      body: Center(
        child: InteractiveViewer(minScale: 0.5, maxScale: 5, child: image),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.item, required this.text});

  final SuperMediaItem item;
  final SuperMediaTextConfig text;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialize;

  @override
  void initState() {
    super.initState();
    _controller = videoControllerFor(widget.item);
    _initialize = _controller.initialize().then((_) => _controller.play());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.item.name),
      ),
      body: FutureBuilder<void>(
        future: _initialize,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _PreviewError(message: widget.text.unableToPlayVideo);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder:
                (context, value, _) => Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio:
                              value.aspectRatio == 0
                                  ? 16 / 9
                                  : value.aspectRatio,
                          child: GestureDetector(
                            onTap: _togglePlayback,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller),
                                if (!value.isPlaying)
                                  const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white,
                                    size: 72,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          IconButton(
                            color: Colors.white,
                            onPressed: _togglePlayback,
                            icon: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              colors: const VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.white38,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }

  void _togglePlayback() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
