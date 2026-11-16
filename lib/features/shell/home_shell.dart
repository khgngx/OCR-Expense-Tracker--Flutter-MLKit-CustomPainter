import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_colors.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/layout/view_mode_toggle.dart';
import '../../core/widgets/language_toggle.dart';
import '../../l10n/app_localizations.dart';
import '../bill_stack/screens/daily_bill_stack_screen.dart';
import '../camera_scan/screens/camera_scan_screen.dart';
import '../charts/screens/analytics_screen.dart';
import '../home/screens/home_screen.dart';
import '../settings/screens/settings_screen.dart';
import 'widgets/app_bottom_bar.dart';

/// Adaptive shell: bottom bar with a central scan button on narrow screens,
/// side rail on wide ones.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    AnalyticsScreen(),
    DailyBillStackScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      NavItem(Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      NavItem(
        Icons.bar_chart_outlined,
        Icons.bar_chart_rounded,
        l10n.navAnalytics,
      ),
      NavItem(Icons.layers_outlined, Icons.layers_rounded, l10n.navBills),
      NavItem(
        Icons.settings_outlined,
        Icons.settings_rounded,
        l10n.navSettings,
      ),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final content = IndexedStack(index: _index, children: _pages);

    if (width >= Breakpoints.desktop) {
      final extended = width >= Breakpoints.extendedRail;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surface,
              extended: extended,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              indicatorColor: AppColors.mint,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: extended
                    ? FloatingActionButton.extended(
                        onPressed: () => openScanScreen(context),
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: Text(l10n.quickScan),
                      )
                    : FloatingActionButton(
                        tooltip: l10n.navScan,
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        onPressed: () => openScanScreen(context),
                        child: const Icon(Icons.document_scanner_outlined),
                      ),
              ),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LanguageToggle(),
                        SizedBox(height: 8),
                        ViewModeToggle(compact: true),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: AppBottomBar(
        items: items,
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        onCenterPressed: () => openScanScreen(context),
      ),
    );
  }
}
