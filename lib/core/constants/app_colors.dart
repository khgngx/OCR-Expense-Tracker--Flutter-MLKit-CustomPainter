import 'package:material_ui/material_ui.dart';

import '../../domain/models/category.dart';

class AppColors {
  AppColors._();

  static const Color forest = Color(0xFF1D4A3A);
  static const Color forestDeep = Color(0xFF14392C);
  static const Color lime = Color(0xFFCDE5B5);
  static const Color mint = Color(0xFFE4EEE1);
  static const Color background = Color(0xFFF6F4ED);
  static const Color surface = Color(0xFFFDFCF9);

  /// Beige tile behind quick-action icons and the header pill.
  static const Color tile = Color(0xFFEFEDE5);
  static const Color ink = Color(0xFF14261E);
  static const Color muted = Color(0xFF7A8A80);
  static const Color line = Color(0xFFE6E4DB);
  static const Color danger = Color(0xFFC0503F);

  /// Greens like the design reference; legends carry labels and percentages,
  /// so categories never rely on color alone.
  static const Map<Category, Color> category = {
    Category.food: Color(0xFF1D4A3A),
    Category.study: Color(0xFF4C9A6C),
    Category.travel: Color(0xFF93C7A5),
    Category.gear: Color(0xFFA7B0A9),
    Category.entertainment: Color(0xFFC6CCC5),
  };

  static Color of(Category c) => category[c]!;
}
