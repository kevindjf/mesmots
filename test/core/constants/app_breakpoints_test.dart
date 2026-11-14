import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';

void main() {
  group('ScreenClass.of', () {
    test('a phone is small, held upright or sideways', () {
      // Arrange
      const upright = Size(412, 840);
      const sideways = Size(840, 412);

      // Act
      final classes = [ScreenClass.of(upright), ScreenClass.of(sideways)];

      // Assert
      expect(classes, [ScreenClass.sm, ScreenClass.sm]);
    });

    test('an Android 10" tablet is medium', () {
      // Arrange
      const tablet = Size(800, 1280);

      // Act
      final screenClass = ScreenClass.of(tablet);

      // Assert
      expect(screenClass, ScreenClass.md);
      expect(screenClass.isTablet, isTrue);
    });

    test('an iPad 13" is large, in both orientations', () {
      // Arrange
      const portrait = Size(1032, 1376);
      const landscape = Size(1376, 1032);

      // Act
      final classes = [ScreenClass.of(portrait), ScreenClass.of(landscape)];

      // Assert
      expect(classes, [ScreenClass.lg, ScreenClass.lg]);
    });

    test('the UI grows with the screen class', () {
      // Arrange
      final scales = ScreenClass.values.map((c) => c.uiScale).toList();

      // Act
      final sorted = [...scales]..sort();

      // Assert
      expect(scales.first, 1);
      expect(scales, sorted);
    });
  });

  group('AppBreakpoints.columnsFor', () {
    test('one column on a phone', () {
      // Arrange
      const phoneContent = 372.0;

      // Act
      final columns = AppBreakpoints.columnsFor(phoneContent);

      // Assert
      expect(columns, 1);
    });

    test('two columns on a tablet held upright', () {
      // Arrange
      const tabletContent = 697.0;

      // Act
      final columns = AppBreakpoints.columnsFor(tabletContent, spacing: 16);

      // Assert
      expect(columns, 2);
    });

    test('never more than the maximum, never less than one', () {
      // Arrange
      const huge = 10000.0;
      const tiny = 10.0;

      // Act
      final most = AppBreakpoints.columnsFor(huge);
      final least = AppBreakpoints.columnsFor(tiny);

      // Assert
      expect(most, AppBreakpoints.gridMaxColumns);
      expect(least, 1);
    });
  });
}
