import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations;
import 'package:material_ui/material_ui.dart';

import 'app_scope.dart';
import 'core/layout/responsive_frame.dart';
import 'core/layout/view_mode.dart';
import 'core/settings/settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/shell/home_shell.dart';
import 'l10n/app_localizations.dart';

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
  Widget build(BuildContext context) {
    final settings = widget.dependencies.settings;
    return AppScope(
      dependencies: widget.dependencies,
      child: ViewModeScope(
        controller: _viewMode,
        // Rebuilds on language change and when onboarding finishes.
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            supportedLocales: SettingsController.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => ResponsiveFrame(child: child!),
            home: settings.onboardingDone
                ? const HomeShell()
                : const OnboardingScreen(),
          ),
        ),
      ),
    );
  }
}
