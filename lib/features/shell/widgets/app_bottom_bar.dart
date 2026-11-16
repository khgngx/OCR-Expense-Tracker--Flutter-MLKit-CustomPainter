import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class NavItem {
  const NavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom navigation with a raised round action button in the middle, like the
/// reference. [items] are split around the button (first half left, rest right).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCenterPressed,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onCenterPressed;

  @override
  Widget build(BuildContext context) {
    final half = items.length ~/ 2;
    final l10n = AppLocalizations.of(context);
    Widget item(int i) => Expanded(
      child: _BarItem(
        item: items[i],
        selected: i == selectedIndex,
        onTap: () => onSelected(i),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < half; i++) item(i),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: l10n.navScan,
                    child: Tooltip(
                      message: l10n.navScan,
                      child: Material(
                        color: AppColors.forest,
                        shape: const CircleBorder(),
                        elevation: 4,
                        shadowColor: AppColors.forest.withValues(alpha: 0.4),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onCenterPressed,
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (var i = half; i < items.length; i++) item(i),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? item.selectedIcon : item.icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
