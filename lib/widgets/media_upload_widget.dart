import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaUploadWidget extends StatefulWidget {
  final Function(File) onMediaSelected;

  const MediaUploadWidget({
    Key? key,
    required this.onMediaSelected,
  }) : super(key: key);

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  File? _mediaFile;
  bool _isVideo = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
    if (_isVideo) {
      await Permission.microphone.request();
    }
  }

  Future<void> _showMediaOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Unggah Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera untuk mengambil foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.blue),
                ),
                title: const Text('Rekam Video'),
                subtitle: const Text('Gunakan kamera untuk merekam video'),
                onTap: () {
                  Navigator.pop(context);
                  _recordVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    await _requestPermissions();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (photo != null) {
        setState(() {
          _mediaFile = File(photo.path);
          _isVideo = false;
        });
        widget.onMediaSelected(_mediaFile!);
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  Future<void> _recordVideo() async {
    await _requestPermissions();
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );
      if (video != null) {
        setState(() {
          _mediaFile = File(video.path);
          _isVideo = true;
        });
        widget.onMediaSelected(_mediaFile!);
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
    }
  }

  Widget _buildPreview() {
    if (_mediaFile == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: InkWell(
          onTap: _showMediaOptions,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Klik untuk unggah foto/video',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isVideo
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: Colors.black87,
                        child: const Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    _mediaFile!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'File: ${_mediaFile!.path.split('/').last}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _mediaFile = null;
                  _isVideo = false;
                });
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Hapus'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPreview(),
        if (_mediaFile == null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showMediaOptions,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Unggah Foto/Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
} 