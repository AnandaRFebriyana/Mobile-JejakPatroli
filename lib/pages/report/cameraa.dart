import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print('Error: ${e.code}');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final image = await controller.takePicture();
      print('Foto diambil: ${image.path}');
    } catch (e) {
      print('Gagal ambil foto: $e');
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_isRecording) {
      final video = await controller.stopVideoRecording();
      print('Video selesai: ${video.path}');
    } else {
      await controller.startVideoRecording();
      print('Mulai rekam video');
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            CameraPreview(controller),
            Positioned(
              bottom: 30,
              left: 30,
              child: FloatingActionButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera),
              ),
            ),
            Positioned(
              bottom: 30,
              right: 30,
              child: FloatingActionButton(
                backgroundColor: _isRecording ? Colors.red : null,
                onPressed: _toggleVideoRecording,
                child: Icon(_isRecording ? Icons.stop : Icons.videocam),
              ),
            ),
          ],
        ),
      ),
    );
  }
}