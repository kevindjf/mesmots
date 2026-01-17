import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:mesmots/features/parental/data/models/parental_settings_model.dart';

part 'database_provider.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [
      WordListModelSchema,
      ParentalSettingsModelSchema,
    ],
    directory: dir.path,
  );

  ref.onDispose(() => isar.close());

  return isar;
}
