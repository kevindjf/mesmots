import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/edit_word_item.dart';
import 'package:mesmots/shared/widgets/confirm_delete_dialog.dart';

import '../../../../goldens/golden_harness.dart';

void main() {
  setUpAll(loadGoldenFonts);

  final devices = <String, Size>{
    'phone upright': const Size(390, 844),
    'phone sideways': const Size(852, 393),
    'tablet sideways': const Size(1133, 744),
  };

  for (final device in devices.entries) {
    testWidgets('shows the save button without scrolling, ${device.key}',
        (tester) async {
      // Arrange
      final bounds = Offset.zero & device.value;

      // Act
      await pumpGoldenScreen(
        tester,
        const ListEditScreen(listId: 'list'),
        theme: AppTheme.of(AppPalette.light),
        overrides: goldenOverrides([goldenList()]),
        size: device.value,
      );

      // Assert
      final button =
          tester.getRect(find.text(AppStrings.saveList.toUpperCase()));
      expect(bounds.intersect(button).size, button.size);
    });
  }

  group('clearing every word', () {
    Future<void> openAndClear(WidgetTester tester) async {
      await pumpGoldenScreen(
        tester,
        const ListEditScreen(listId: 'list'),
        theme: AppTheme.of(AppPalette.light),
        overrides: goldenOverrides([goldenList()]),
      );
      await tester.tap(find.text(AppStrings.clearAll));
      await tester.pumpAndSettle();
    }

    Finder inDialog(String text) => find.descendant(
          of: find.byType(ConfirmDeleteDialog),
          matching: find.text(text.toUpperCase()),
        );

    testWidgets('asks first', (tester) async {
      // Act
      await openAndClear(tester);

      // Assert
      expect(find.text(AppStrings.clearAllTitle), findsOneWidget);
      expect(find.byType(EditWordItem), findsWidgets);
    });

    testWidgets('keeps the words when cancelled', (tester) async {
      // Arrange
      await openAndClear(tester);

      // Act
      await tester.tap(inDialog(AppStrings.cancel));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ConfirmDeleteDialog), findsNothing);
      expect(find.byType(EditWordItem), findsWidgets);
    });

    testWidgets('removes the words once confirmed', (tester) async {
      // Arrange
      await openAndClear(tester);

      // Act
      await tester.tap(inDialog(AppStrings.erase));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditWordItem), findsNothing);
    });
  });
}
