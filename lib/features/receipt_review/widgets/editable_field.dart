import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class EditableField extends StatelessWidget {
  const EditableField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.helperText,
    this.textStyle,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;

  /// Hint under the field, e.g. "Not detected, please fill in".
  final String? helperText;
  final TextStyle? textStyle;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: textStyle,
    autovalidateMode: autovalidateMode,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffixText,
      helperText: helperText,
      helperStyle: const TextStyle(color: Color(0xFFB26A00)),
    ),
  );
}
