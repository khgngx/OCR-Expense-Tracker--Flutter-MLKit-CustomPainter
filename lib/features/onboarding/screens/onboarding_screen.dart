import 'package:material_ui/material_ui.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../painters/onboarding_illustration_painter.dart';

/// First-launch intro laid out like the reference: step counter with a segmented
/// progress bar and Skip, a two-tone headline, a subtitle, an illustration over
/// a podium, and a white "Get Started" button.
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
        l10n.onboardingTitle1a,
        l10n.onboardingTitle1b,
        l10n.onboardingBody1,
        IllustrationKind.wallet,
      ),
      (
        l10n.onboardingTitle2a,
        l10n.onboardingTitle2b,
        l10n.onboardingBody2,
        IllustrationKind.receipt,
      ),
      (
        l10n.onboardingTitle3a,
        l10n.onboardingTitle3b,
        l10n.onboardingBody3,
        IllustrationKind.chart,
      ),
    ];
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.forest,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, 0.55),
            radius: 1.0,
            colors: [Color(0xFF2F6A52), Color(0xFF1D4A3A), Color(0xFF143629)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '0${_page + 1} / 0$_pageCount',
                          style: text.labelLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Row(
                            children: [
                              for (var i = 0; i < _pageCount; i++)
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: 3,
                                    margin: EdgeInsets.only(
                                      right: i == _pageCount - 1 ? 0 : 6,
                                    ),
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
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _finish,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n.skip,
                              style: text.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
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
                          final (line1, line2, body, kind) = slides[i];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 44),
                              Text(
                                line1,
                                style: text.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                ),
                              ),
                              Text(
                                line2,
                                style: text.displaySmall?.copyWith(
                                  color: AppColors.lime,
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                body,
                                style: text.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: SizedBox.expand(
                                    child: CustomPaint(
                                      painter: OnboardingIllustrationPainter(
                                        kind,
                                      ),
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
                        minimumSize: const Size.fromHeight(58),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _page == _pageCount - 1
                                ? l10n.getStarted
                                : l10n.next,
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
      ),
    );
  }
}
