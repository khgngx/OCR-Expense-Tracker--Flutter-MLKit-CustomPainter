import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app_scope.dart';

/// Shows a stored thumbnail by its storage reference (file path or data URI).
class ThumbnailImage extends StatefulWidget {
  const ThumbnailImage({super.key, required this.reference, this.height = 160});

  final String reference;
  final double height;

  @override
  State<ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<ThumbnailImage> {
  Future<Uint8List?>? _bytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bytes ??= AppScope.of(context).imageStorage.load(widget.reference);
  }

  @override
  void didUpdateWidget(ThumbnailImage old) {
    super.didUpdateWidget(old);
    if (old.reference != widget.reference) {
      _bytes = AppScope.of(context).imageStorage.load(widget.reference);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _bytes,
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (bytes == null) {
        return SizedBox(height: widget.height);
      }
      return Image.memory(
        bytes,
        height: widget.height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => SizedBox(height: widget.height),
      );
    },
  );
}
