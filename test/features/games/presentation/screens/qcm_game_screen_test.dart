import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/widgets/qcm_option_card.dart';

import '../../../../goldens/golden_harness.dart';

final _list = goldenList(id: 'qcm');

void main() {
  Future<List<Rect>> optionsOn(WidgetTester tester, Size size) async {
    await pumpGoldenScreen(
      tester,
      QcmGameScreen(listId: _list.id),
      theme: AppTheme.of(AppPalette.light),
      overrides: goldenOverrides([_list]),
      size: size,
    );
    return [
      for (final element in find.byType(QcmOptionCard).evaluate())
        tester.getRect(find.byWidget(element.widget)),
    ];
  }

  for (final device in const {
    'a phone': Size(390, 844),
    'an iPad': Size(1032, 1376),
    'an iPad held sideways': Size(1376, 1032),
    'an Android tablet held sideways': Size(1280, 800),
  }.entries) {
    testWidgets('shows every option whole on ${device.key}', (tester) async {
      // Arrange
      final screen = Offset.zero & device.value;

      // Act
      final options = await optionsOn(tester, device.value);

      // Assert
      expect(options, isNotEmpty);
      for (final option in options) {
        expect(screen.intersect(option), option);
      }
    });
  }

  testWidgets('keeps square options on a phone', (tester) async {
    // Arrange
    const phone = Size(390, 844);

    // Act
    final options = await optionsOn(tester, phone);

    // Assert
    expect(options.first.width, closeTo(options.first.height, 0.01));
  });
}
