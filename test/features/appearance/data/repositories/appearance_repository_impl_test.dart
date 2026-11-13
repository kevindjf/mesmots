import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mesmots/features/appearance/data/repositories/appearance_repository_impl.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late AppearanceRepositoryImpl repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('appearance');
    Hive.init(dir.path);
    box = await Hive.openBox<dynamic>(AppearanceRepositoryImpl.boxName);
    repository = AppearanceRepositoryImpl(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('a fresh install loads the original look', () {
    // Act & Assert
    expect(repository.load(), AppearanceSettings.initial);
  });

  test('saved settings load back', () async {
    // Arrange
    const settings = AppearanceSettings(highContrast: true);

    // Act
    await repository.save(settings);

    // Assert
    expect(repository.load(), settings);
  });

  test('a theme saved by an older version is ignored', () async {
    // Arrange
    await box.put('theme', 'dark');

    // Act & Assert
    expect(repository.load(), AppearanceSettings.initial);
  });
}
