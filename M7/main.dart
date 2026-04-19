import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Camera App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _capturedImage;

  Future<void> _openCamera() async {
    final controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();

    if (!mounted) return;

    final xFile = await showDialog<XFile>(
      context: context,
      builder: (_) => _CameraDialog(controller: controller),
    );

    await controller.dispose();

    if (xFile != null) {
      setState(() => _capturedImage = File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_capturedImage != null)
              Image.file(_capturedImage!, height: 200)
            else
              const Text('Belum ada gambar yang diambil.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        tooltip: 'Buka Kamera',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class _CameraDialog extends StatelessWidget {
  final CameraController controller;

  const _CameraDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () async {
                  final xFile = await controller.takePicture();
                  if (context.mounted) Navigator.pop(context, xFile);
                },
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
