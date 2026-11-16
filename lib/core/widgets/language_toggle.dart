import 'package:material_ui/material_ui.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_colors.dart';

/// Pill showing the current language ("EN" / "VI"); tap swaps it.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final code = settings.locale.languageCode.toUpperCase();
    final fg = onDark ? Colors.white : AppColors.forest;
    return Tooltip(
      message: AppLocalizations.of(context).switchLanguage,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: settings.toggleLocale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: onDark ? Colors.white38 : AppColors.line),
            color: onDark ? Colors.white10 : AppColors.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.translate, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                code,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
