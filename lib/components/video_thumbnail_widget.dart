import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onTap;

  const VideoThumbnailWidget({Key? key, required this.videoUrl, this.onTap}) : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.PNG,
      maxWidth: 60, // thumbnail width
      quality: 75,
    );
    if (mounted) {
      setState(() {
        _thumbnail = uint8list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Video URL: ${widget.videoUrl}');
    return GestureDetector(
      onTap: widget.onTap,
      child: _thumbnail != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.memory(_thumbnail!, width: 60, height: 60, fit: BoxFit.cover),
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.black26,
                    child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                  ),
                ],
              ),
            )
          : Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
    );
  }
}
