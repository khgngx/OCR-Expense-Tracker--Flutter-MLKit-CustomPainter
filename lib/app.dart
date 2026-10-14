import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/bill_stack/screens/daily_bill_stack_screen.dart';
import 'features/camera_scan/screens/camera_scan_screen.dart';
import 'features/charts/screens/dashboard_screen.dart';
import 'features/transaction_list/screens/transaction_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => AppScope(
    dependencies: dependencies,
    child: MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    ),
  );
}

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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _index, children: _pages),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const CameraScanScreen())),
      icon: const Icon(Icons.document_scanner_outlined),
      label: const Text('Scan'),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Transactions',
        ),
        NavigationDestination(
          icon: Icon(Icons.pie_chart_outline),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.layers_outlined),
          label: 'Bills',
        ),
      ],
    ),
  );
}
