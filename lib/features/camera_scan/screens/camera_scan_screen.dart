import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app_scope.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../services/receipt_image_cropper.dart';
import '../widgets/crop_overlay.dart';
import '../widgets/flash_toggle_button.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;
  String? _error;
  bool _processing = false;
  FlashMode _flash = FlashMode.off;
  Rect _crop = const Rect.fromLTRB(0.08, 0.12, 0.92, 0.88);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      if (mounted) {
        setState(
          () => _error =
              'Camera unavailable (${e.code}). Check camera permission in Settings.',
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller?.setFlashMode(next);
    if (mounted) setState(() => _flash = next);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _processing) return;
    setState(() => _processing = true);
    final deps = AppScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shot = await controller.takePicture();
      final tmp = await getTemporaryDirectory();
      final cropped = await cropReceiptImage(
        File(shot.path),
        _crop,
        p.join(
          tmp.path,
          'receipt_${DateTime.now().microsecondsSinceEpoch}.jpg',
        ),
      );
      final text = await deps.ocrService.recognize(cropped);
      if (!mounted) return;
      if (text.trim().isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No text found. Adjust the frame and try again.'),
          ),
        );
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewScreen.fromScan(
            parsed: deps.parseReceiptText(text),
            image: cropped,
          ),
        ),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Scan failed: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan receipt'),
        actions: [
          if (controller != null)
            FlashToggleButton(mode: _flash, onPressed: _toggleFlash),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1 / controller.value.aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller),
                          CropOverlay(
                            rect: _crop,
                            onChanged: (r) => setState(() => _crop = r),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _processing
                        ? const SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(),
                          )
                        : GestureDetector(
                            onTap: _capture,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white54,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
