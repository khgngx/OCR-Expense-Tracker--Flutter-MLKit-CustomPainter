import 'package:flutter/material.dart';

import '../../domain/models/category.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF2E7D6B);

  static const Map<Category, Color> category = {
    Category.food: Color(0xFFEF6C57),
    Category.study: Color(0xFF4A7BD0),
    Category.travel: Color(0xFF3FAE8C),
    Category.gear: Color(0xFF8E6BC9),
    Category.entertainment: Color(0xFFF2B33D),
  };

  static Color of(Category c) => category[c]!;
}
