import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:mesmots/features/onboarding/presentation/widgets/onboarding_top_bar.dart';
import 'package:mesmots/features/onboarding/presentation/widgets/tour_games_illustration.dart';
import 'package:mesmots/features/onboarding/presentation/widgets/tour_list_illustration.dart';
import 'package:mesmots/features/onboarding/presentation/widgets/tour_stars_illustration.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_entry.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/icon_badge.dart';
import 'package:mesmots/shared/widgets/letter_tiles_title.dart';
import 'package:mesmots/shared/widgets/page_dots.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

enum _OnboardingStep { welcome, tour, createPin, confirmPin }

/// First launch, for the adult: welcome, a 3-page tour of how the app
/// works, then creating the parent PIN. Ends in the parent space.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  static const _tourLength = 3;

  final _pageController = PageController();
  var _step = _OnboardingStep.welcome;
  var _tourPage = 0;
  var _goingBack = false;
  String _pin = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(_OnboardingStep step) {
    setState(() {
      _goingBack = step.index < _step.index;
      _step = step;
    });
  }

  void _back() {
    switch (_step) {
      case _OnboardingStep.welcome:
        break;
      case _OnboardingStep.tour:
        if (_tourPage > 0) {
          _animateToPage(_tourPage - 1);
        } else {
          _goTo(_OnboardingStep.welcome);
        }
      case _OnboardingStep.createPin:
        _goTo(_OnboardingStep.tour);
      case _OnboardingStep.confirmPin:
        _goTo(_OnboardingStep.createPin);
    }
  }

  void _nextTourPage() {
    if (_tourPage < _tourLength - 1) {
      _animateToPage(_tourPage + 1);
    } else {
      _goTo(_OnboardingStep.createPin);
    }
  }

  void _animateToPage(int page) {
    if (context.reduceMotion) {
      _pageController.jumpToPage(page);
      return;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  /// Opens the parent space, then saves the PIN.
  ///
  /// Saving the PIN makes AppInitializer swap this screen for the home
  /// screen. Doing it once the parent space fully covers the screen keeps
  /// that swap invisible (otherwise the home screen flashes in between).
  Future<void> _completeSetup() async {
    final operations = ref.read(parentalOperationsProvider.notifier);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final route = MaterialPageRoute<void>(
      builder: (_) => const ParentSpaceScreen(),
    );

    navigator.push(route);
    await Future<void>.delayed(route.transitionDuration);

    try {
      await operations.configurePin(_pin);
    } catch (e) {
      if (route.isActive) navigator.removeRoute(route);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(const Duration(milliseconds: 400));
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: duration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: _slideTransition,
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slideTransition(Widget child, Animation<double> animation) {
    final isIncoming = child.key == ValueKey(_step);
    // Incoming slides in from the side we are going to,
    // outgoing leaves towards the other side.
    final direction = (_goingBack ? -1.0 : 1.0) * (isIncoming ? 1 : -1);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: Offset(0.25 * direction, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _OnboardingStep.welcome:
        return _buildWelcome();
      case _OnboardingStep.tour:
        return _buildTour();
      case _OnboardingStep.createPin:
        return _buildPinStep(
          title: AppStrings.createPinTitle,
          text: AppStrings.createPinText,
          entry: PinEntry(
            key: const ValueKey('create'),
            validate: (_) async => true,
            onAccepted: (pin) {
              _pin = pin;
              _goTo(_OnboardingStep.confirmPin);
            },
            errorMessage: '',
            dotColor: context.palette.onBackground,
            emptyDotColor: context.palette.onBackground.withValues(alpha: 0.4),
          ),
        );
      case _OnboardingStep.confirmPin:
        return _buildPinStep(
          title: AppStrings.confirmPinTitle,
          text: AppStrings.confirmPinText,
          entry: PinEntry(
            key: const ValueKey('confirm'),
            validate: (pin) async => pin == _pin,
            onAccepted: (_) => _completeSetup(),
            errorMessage: AppStrings.pinMismatch,
            dotColor: context.palette.onBackground,
            emptyDotColor: context.palette.onBackground.withValues(alpha: 0.4),
            errorColor: context.palette.onBackground,
          ),
        );
    }
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        children: [
          const Spacer(flex: 3),
          const LetterTilesTitle(text: AppStrings.welcomeTiles, tileSize: 64),
          const SizedBox(height: AppDimensions.spacingXl),
          PopIn.rise(
            delay: Duration(milliseconds: 1000),
            child: Text(
              AppStrings.welcomeTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: context.palette.onBackground,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          PopIn.rise(
            delay: Duration(milliseconds: 1100),
            child: Text(
              AppStrings.welcomeAudience,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: context.palette.onBackground,
              ),
            ),
          ),
          const Spacer(flex: 4),
          PopIn.rise(
            delay: const Duration(milliseconds: 1300),
            child: ColorfulButton.orange(
              text: AppStrings.start,
              icon: Icons.arrow_forward,
              width: double.infinity,
              onTap: () => _goTo(_OnboardingStep.tour),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
        ],
      ),
    );
  }

  Widget _buildTour() {
    final isLastPage = _tourPage == _tourLength - 1;
    return Column(
      children: [
        OnboardingTopBar(
          onBack: _back,
          trailing: TextButton(
            onPressed: () => _goTo(_OnboardingStep.createPin),
            child: Text(
              AppStrings.skip,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.bold,
                color: context.palette.onBackground,
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _tourPage = page),
            children: const [
              OnboardingSlide(
                illustration: TourListIllustration(),
                title: AppStrings.tourListTitle,
                text: AppStrings.tourListText,
              ),
              OnboardingSlide(
                illustration: TourGamesIllustration(),
                title: AppStrings.tourGamesTitle,
                text: AppStrings.tourGamesText,
              ),
              OnboardingSlide(
                illustration: TourStarsIllustration(),
                title: AppStrings.tourStarsTitle,
                text: AppStrings.tourStarsText,
              ),
            ],
          ),
        ),
        PageDots(count: _tourLength, current: _tourPage),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: ColorfulButton.orange(
            text: isLastPage ? AppStrings.createMyCode : AppStrings.next,
            icon: isLastPage ? Icons.lock_outline : Icons.arrow_forward,
            width: double.infinity,
            onTap: _nextTourPage,
          ),
        ),
      ],
    );
  }

  Widget _buildPinStep({
    required String title,
    required String text,
    required Widget entry,
  }) {
    return Column(
      children: [
        OnboardingTopBar(onBack: _back),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXl,
              ),
              child: Column(
                children: [
                  const PopIn(child: IconBadge.blue(icon: Icons.lock_outline)),
                  const SizedBox(height: AppDimensions.spacingL),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.headingLarge,
                      fontWeight: AppTypography.bold,
                      color: context.palette.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.semiBold,
                      color: context.palette.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  entry,
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
