import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:mesmots/features/parental/data/models/parental_settings_model.dart';

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
