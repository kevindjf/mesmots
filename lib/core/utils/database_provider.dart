import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jerevise/features/word_lists/data/models/word_list_model.dart';
import 'package:jerevise/features/parental/data/models/parental_settings_model.dart';
import 'package:jerevise/features/conjugation/data/models/conjugation_progress_model.dart';
import 'package:jerevise/features/maths/data/models/math_progress_model.dart';

part 'database_provider.g.dart';

/// Initialize Hive database
Future<void> initializeDatabase() async {
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(WordListModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ParentalSettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ConjugationProgressModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(MathProgressModelAdapter());
  }
}

@riverpod
Future<Box<WordListModel>> wordListBox(WordListBoxRef ref) async {
  final box = await Hive.openBox<WordListModel>('wordLists');
  ref.onDispose(() => box.close());
  return box;
}

@riverpod
Future<Box<ParentalSettingsModel>> parentalSettingsBox(
  ParentalSettingsBoxRef ref,
) async {
  final box = await Hive.openBox<ParentalSettingsModel>('parentalSettings');
  ref.onDispose(() => box.close());
  return box;
}

@riverpod
Future<Box<ConjugationProgressModel>> conjugationProgressBox(
  ConjugationProgressBoxRef ref,
) async {
  final box =
      await Hive.openBox<ConjugationProgressModel>('conjugationProgress');
  ref.onDispose(() => box.close());
  return box;
}

@riverpod
Future<Box<MathProgressModel>> mathProgressBox(
  MathProgressBoxRef ref,
) async {
  final box = await Hive.openBox<MathProgressModel>('mathProgress');
  ref.onDispose(() => box.close());
  return box;
}
