import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/providers/appearance_providers.dart';
import 'package:mesmots/features/appearance/presentation/widgets/high_contrast_tile.dart';
import 'package:mesmots/features/appearance/presentation/widgets/theme_choice_card.dart';

/// Parent setting of the app look: theme and high contrast text.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceProvider);
    final appearance = ref.read(appearanceProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.appearance,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.bold,
            color: context.palette.onBackground,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final choice in ThemeChoice.values) ...[
              if (choice != ThemeChoice.values.first)
                const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: ThemeChoiceCard(
                  choice: choice,
                  isSelected: settings.theme == choice,
                  onTap: () => appearance.setTheme(choice),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.spacingL),
        HighContrastTile(
          value: settings.highContrast,
          onChanged: appearance.setHighContrast,
        ),
      ],
    );
  }
}
