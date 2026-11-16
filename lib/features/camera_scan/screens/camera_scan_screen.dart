import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../app_scope.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../data/sample_receipts.dart';
import '../services/receipt_image_processor.dart';
import '../widgets/crop_overlay.dart';
import '../widgets/flash_toggle_button.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;
  String? _cameraError;
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
        setState(() => _cameraError = 'No camera found on this device.');
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
      if (!kIsWeb) {
        await controller.setFlashMode(FlashMode.off);
      }
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      if (mounted) {
        setState(
          () => _cameraError =
              'Camera unavailable (${e.code}). Allow camera access, '
              'or import an image instead.',
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
    try {
      await _controller?.setFlashMode(next);
      if (mounted) {
        setState(() => _flash = next);
      }
    } on CameraException catch (e) {
      _toast('Flash unavailable (${e.code}).');
    }
  }

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _processing) {
      return;
    }
    try {
      final shot = await controller.takePicture();
      await _process(await shot.readAsBytes(), crop: _crop);
    } on CameraException catch (e) {
      _toast('Capture failed (${e.code}).');
    }
  }

  Future<void> _import() async {
    if (_processing) {
      return;
    }
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) {
      return;
    }
    await _process(await file.readAsBytes());
  }

  Future<void> _pickSample() async {
    final sample = await showModalBottomSheet<SampleReceipt>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Sample receipts'),
              subtitle: Text('Demo data for trying the OCR and parser'),
            ),
            for (final s in sampleReceipts)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(s.label),
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    if (sample == null) {
      return;
    }
    final data = await rootBundle.load(sample.assetPath);
    await _process(data.buffer.asUint8List());
  }

  /// Normalizes [raw], runs OCR, parses the text and opens the review screen.
  Future<void> _process(Uint8List raw, {Rect? crop}) async {
    setState(() => _processing = true);
    final deps = AppScope.of(context);
    final navigator = Navigator.of(context);
    try {
      final prepared = await prepareReceiptImage(raw, cropRect: crop);
      final text = await deps.ocrService.recognize(prepared);
      if (!mounted) {
        return;
      }
      if (text.trim().isEmpty) {
        _toast('No text found. Adjust the frame or try another image.');
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewScreen.fromScan(
            parsed: deps.parseReceiptText(text),
            imageBytes: prepared,
          ),
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        _toast('Scan failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Widget _preview(CameraController controller) {
    // Mobile cameras report the sensor's landscape ratio; the preview is
    // shown upright, so invert it there. Web reports the video ratio as is.
    final ratio = controller.value.aspectRatio;
    return Center(
      child: AspectRatio(
        aspectRatio: kIsWeb ? ratio : 1 / ratio,
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
    );
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final Widget body;
    if (_processing) {
      body = _message(
        'Reading receipt…\n'
        '${kIsWeb ? 'The first scan downloads the OCR language data and can take a while.' : ''}',
      );
    } else if (_cameraError != null) {
      body = _message(_cameraError!);
    } else if (controller == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _preview(controller);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan receipt'),
        actions: [
          if (controller != null && !kIsWeb)
            FlashToggleButton(mode: _flash, onPressed: _toggleFlash),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: body),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Import',
                    onPressed: _processing ? null : _import,
                  ),
                  GestureDetector(
                    onTap: controller == null || _processing ? null : _capture,
                    child: Opacity(
                      opacity: controller == null || _processing ? 0.3 : 1,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white54, width: 4),
                        ),
                      ),
                    ),
                  ),
                  _SourceButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Samples',
                    onPressed: _processing ? null : _pickSample,
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

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  );
}
