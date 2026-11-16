import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Four beige rounded squares with a label underneath (Add Money / Send /
/// Convert / More in the reference).
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (final a in actions)
        Semantics(
          button: true,
          label: a.label,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: a.onTap,
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.tile,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(a.icon, color: AppColors.ink, size: 24),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    a.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
