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

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    Category.food => l10n.catFood,
    Category.study => l10n.catStudy,
    Category.travel => l10n.catTravel,
    Category.gear => l10n.catGear,
    Category.entertainment => l10n.catEntertainment,
  };
}
