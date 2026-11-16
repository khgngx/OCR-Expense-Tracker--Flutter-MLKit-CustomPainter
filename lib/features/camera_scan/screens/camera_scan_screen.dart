import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../../receipt_review/screens/review_screen.dart';
import '../data/sample_receipts.dart';
import '../services/scan_pipeline.dart';
import '../widgets/crop_overlay.dart';
import '../widgets/flash_toggle_button.dart';

/// Opens the live scan screen.
void openScanScreen(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const CameraScanScreen()));

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  CameraController? _controller;

  /// Why the camera is unusable: [_noCamera] or a [CameraException] code.
  bool _noCamera = false;
  String? _cameraErrorCode;
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
        setState(() => _noCamera = true);
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
        setState(() => _cameraErrorCode = e.code);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _toggleFlash() async {
    final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller?.setFlashMode(next);
      if (mounted) {
        setState(() => _flash = next);
      }
    } on CameraException catch (e) {
      if (mounted) {
        _toast(AppLocalizations.of(context).flashUnavailable(e.code));
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _processing) {
      return;
    }
    try {
      final shot = await controller.takePicture();
      await _process(await shot.readAsBytes(), crop: _crop);
    } on CameraException catch (e) {
      if (mounted) {
        _toast(AppLocalizations.of(context).captureFailed(e.code));
      }
    }
  }

  Future<void> _import() async {
    if (_processing) {
      return;
    }
    final raw = await pickReceiptImage();
    if (raw != null) {
      await _process(raw);
    }
  }

  Future<void> _pickSample() async {
    final l10n = AppLocalizations.of(context);
    final sample = await showModalBottomSheet<SampleReceipt>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.sampleReceiptsTitle),
              subtitle: Text(l10n.sampleReceiptsSubtitle),
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

  /// Runs OCR + parsing on [raw] and opens the review screen.
  Future<void> _process(Uint8List raw, {Rect? crop}) async {
    setState(() => _processing = true);
    final deps = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    try {
      final result = await scanReceipt(deps, raw, crop: crop);
      if (!mounted) {
        return;
      }
      if (result == null) {
        _toast(l10n.noTextFound);
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewScreen.fromScan(
            parsed: result.parsed,
            imageBytes: result.image,
          ),
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        _toast(l10n.scanFailed('$e'));
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
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final Widget body;
    if (_processing) {
      body = _message(
        kIsWeb
            ? '${l10n.readingReceipt}\n${l10n.firstScanWeb}'
            : l10n.readingReceipt,
      );
    } else if (_noCamera) {
      body = _message(l10n.noCamera);
    } else if (_cameraErrorCode != null) {
      body = _message(l10n.cameraUnavailable(_cameraErrorCode!));
    } else if (controller == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _preview(controller);
    }
    final canCapture = controller != null && !_processing;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          l10n.scanTitle,
          style: const TextStyle(color: Colors.white),
        ),
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
                    label: l10n.importImage,
                    onPressed: _processing ? null : _import,
                  ),
                  Semantics(
                    button: true,
                    label: l10n.navScan,
                    child: GestureDetector(
                      onTap: canCapture ? _capture : null,
                      child: Opacity(
                        opacity: canCapture ? 1 : 0.3,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white54, width: 4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _SourceButton(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.samples,
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
