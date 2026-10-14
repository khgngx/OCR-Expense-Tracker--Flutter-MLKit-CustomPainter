import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashToggleButton extends StatelessWidget {
  const FlashToggleButton({
    super.key,
    required this.mode,
    required this.onPressed,
  });

  final FlashMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final on = mode != FlashMode.off;
    return IconButton(
      tooltip: on ? 'Flash on' : 'Flash off',
      onPressed: onPressed,
      icon: Icon(on ? Icons.flash_on : Icons.flash_off, color: Colors.white),
    );
  }
}
