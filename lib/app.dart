import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/layout/breakpoints.dart';
import 'core/layout/responsive_frame.dart';
import 'core/layout/view_mode.dart';
import 'core/layout/view_mode_toggle.dart';
import 'core/theme/app_theme.dart';
import 'features/bill_stack/screens/daily_bill_stack_screen.dart';
import 'features/camera_scan/screens/camera_scan_screen.dart';
import 'features/charts/screens/dashboard_screen.dart';
import 'features/transaction_list/screens/transaction_list_screen.dart';

class App extends StatefulWidget {
  const App({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ViewModeController _viewMode = ViewModeController();

  @override
  void dispose() {
    _viewMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: widget.dependencies,
    child: ViewModeScope(
      controller: _viewMode,
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ResponsiveFrame(child: child!),
        home: const HomeShell(),
      ),
    ),
  );
}

void _openScan(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const CameraScanScreen()));

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    TransactionListScreen(),
    DashboardScreen(),
    DailyBillStackScreen(),
  ];

  static const _destinations = <({IconData icon, String label})>[
    (icon: Icons.receipt_long_outlined, label: 'Transactions'),
    (icon: Icons.pie_chart_outline, label: 'Dashboard'),
    (icon: Icons.layers_outlined, label: 'Bills'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final content = IndexedStack(index: _index, children: _pages);

    if (width >= Breakpoints.desktop) {
      final extended = width >= Breakpoints.extendedRail;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: extended
                    ? FloatingActionButton.extended(
                        onPressed: () => _openScan(context),
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Scan'),
                      )
                    : FloatingActionButton(
                        tooltip: 'Scan receipt',
                        onPressed: () => _openScan(context),
                        child: const Icon(Icons.document_scanner_outlined),
                      ),
              ),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ViewModeToggle(compact: true),
                  ),
                ),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    label: Text(d.label),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScan(context),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}
