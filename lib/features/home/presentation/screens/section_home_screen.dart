import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/features/home/presentation/widgets/section_card.dart';
import 'package:jerevise/features/parental/presentation/providers/parental_providers.dart';
import 'package:jerevise/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:jerevise/features/word_lists/presentation/screens/home_screen.dart';
import 'package:jerevise/features/conjugation/presentation/screens/conjugation_home_screen.dart';
import 'package:jerevise/features/maths/presentation/screens/maths_home_screen.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class SectionHomeScreen extends ConsumerWidget {
  const SectionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentalSettings = ref.watch(parentalSettingsProvider);
    final isParentalMode = ref.watch(parentalModeProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AppHeader(
                title: AppStrings.appName,
                subtitle: 'APPRENDS EN T\'AMUSANT',
                trailing: LockIconButton(
                  isUnlocked: isParentalMode,
                  onTap: () =>
                      _handleParentalMode(context, ref, parentalSettings),
                ),
              ),

              // Section cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  children: [
                    const SizedBox(height: AppDimensions.spacingL),

                    // Orthographe
                    SectionCard(
                      title: AppStrings.sectionOrtho,
                      description: AppStrings.sectionOrthoDesc,
                      icon: Icons.spellcheck,
                      color: AppColors.sectionOrtho,
                      shadowColor: AppColors.sectionOrthoShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrthoHomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Conjugaison
                    SectionCard(
                      title: AppStrings.sectionConjug,
                      description: AppStrings.sectionConjugDesc,
                      icon: Icons.auto_stories,
                      color: AppColors.sectionConjug,
                      shadowColor: AppColors.sectionConjugShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ConjugationHomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Maths
                    SectionCard(
                      title: AppStrings.sectionMaths,
                      description: AppStrings.sectionMathsDesc,
                      icon: Icons.calculate,
                      color: AppColors.sectionMaths,
                      shadowColor: AppColors.sectionMathsShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MathsHomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleParentalMode(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> parentalSettingsAsync,
  ) async {
    final isParentalMode = ref.read(parentalModeProvider);

    if (isParentalMode) {
      ref.read(parentalModeProvider.notifier).deactivate();
      return;
    }

    parentalSettingsAsync.whenData((settings) async {
      if (!settings.isPinConfigured) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configure le code PIN d\'abord'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const PinInputDialog(),
      );

      if (result == true) {
        ref.read(parentalModeProvider.notifier).activate();
      }
    });
  }
}
