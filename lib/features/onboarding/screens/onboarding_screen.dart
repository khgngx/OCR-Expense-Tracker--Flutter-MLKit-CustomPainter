import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../l10n/app_localizations.dart';

/// First-launch intro, styled after the dark green reference: big headline,
/// progress bar, Skip, and a pill button at the bottom.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 3;
  final PageController _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _finish() => AppScope.of(context).settings.completeOnboarding();

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (
        Icons.document_scanner_outlined,
        l10n.onboardingTitle1,
        l10n.onboardingBody1,
      ),
      (Icons.donut_large_outlined, l10n.onboardingTitle2, l10n.onboardingBody2),
      (Icons.savings_outlined, l10n.onboardingTitle3, l10n.onboardingBody3),
    ];
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.forest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '0${_page + 1} / 0$_pageCount',
                        style: text.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            for (var i = 0; i < _pageCount; i++)
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 3,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: i <= _page
                                        ? AppColors.lime
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const LanguageToggle(onDark: true),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _pageCount,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, i) {
                        final (icon, title, body) = slides[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            Text(
                              title,
                              style: text.displaySmall?.copyWith(
                                color: AppColors.lime,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              body,
                              style: text.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 88,
                                    color: AppColors.lime,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _page == _pageCount - 1 ? l10n.getStarted : l10n.next,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
