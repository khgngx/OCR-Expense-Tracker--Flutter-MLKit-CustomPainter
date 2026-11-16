import 'package:material_ui/material_ui.dart';

import '../../domain/models/category.dart';
import '../../l10n/app_localizations.dart';
import 'app_colors.dart';

/// Presentation details of a [Category], kept out of the domain model.
extension CategoryStyle on Category {
  Color get color => AppColors.of(this);

  IconData get icon => switch (this) {
    Category.food => Icons.restaurant_outlined,
    Category.study => Icons.menu_book_outlined,
    Category.travel => Icons.directions_car_outlined,
    Category.gear => Icons.devices_other_outlined,
    Category.entertainment => Icons.movie_outlined,
  };

  /// Solid tile behind the category icon in transaction rows (the reference
  /// uses brand-colored tiles; ours are neutral category colors).
  Color get tileColor => switch (this) {
    Category.food => AppColors.forest,
    Category.study => const Color(0xFF15191A),
    Category.travel => const Color(0xFFF5C944),
    Category.gear => const Color(0xFF4C9A6C),
    Category.entertainment => const Color(0xFF15191A),
  };

  Color get tileIconColor => switch (this) {
    Category.travel => const Color(0xFF2B2410),
    Category.entertainment => const Color(0xFFE5484D),
    _ => Colors.white,
  };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    Category.food => l10n.catFood,
    Category.study => l10n.catStudy,
    Category.travel => l10n.catTravel,
    Category.gear => l10n.catGear,
    Category.entertainment => l10n.catEntertainment,
  };
}
