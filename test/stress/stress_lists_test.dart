import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/presentation/screens/crossword_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/spelling_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/word_search_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';

import '../goldens/golden_harness.dart';

/// Lists a parent could really type: many words, words with spaces, very
/// long words, odd letters, a very long name. Every screen must hold them.
final _lists = <WordList>[
  WordList.create(
    id: 'many',
    name: 'Très longue liste',
    words: [
      for (final w in const [
        'maison',
        'école',
        'jardin',
        'chapeau',
        'bateau',
        'oiseau',
        'chat',
        'chien',
        'lune',
        'soleil',
        'étoile',
        'nuage',
        'pluie',
        'neige',
        'vent',
        'arbre',
        'fleur',
        'herbe',
        'pomme',
        'poire',
        'cerise',
        'fraise',
        'banane',
        'orange',
        'citron',
        'carotte',
        'tomate',
        'salade',
        'pain',
        'beurre',
        'lait',
        'fromage',
        'gâteau',
        'bonbon',
        'chocolat',
        'voiture',
        'vélo',
        'train',
        'avion',
        'fusée',
        'route',
        'pont',
        'ville',
        'village',
        'forêt',
        'montagne',
        'rivière',
        'mer',
        'plage',
        'sable',
        'coquillage',
        'poisson',
        'baleine',
        'dauphin',
        'requin',
        'tortue',
        'lapin',
        'souris',
        'éléphant',
        'girafe',
        'lion',
        'tigre',
        'zèbre',
        'singe',
        'ours',
        'loup',
        'renard',
        'hibou',
        'papillon',
        'abeille',
        'fourmi',
        'escargot',
        'grenouille',
        'crayon',
        'cahier',
        'gomme',
        'règle',
        'cartable',
        'tableau',
        'maîtresse',
      ])
        w,
    ],
  ),
  WordList.create(
    id: 'spaces',
    name: 'Mots avec espaces',
    words: const [
      'au fur et à mesure',
      'il était une fois',
      'pomme de terre',
      'chemin de fer',
      'tel que',
      'parce que',
      "c'est-à-dire",
    ],
  ),
  WordList.create(
    id: 'long',
    name: 'Mots très longs',
    words: const [
      'hippopotomonstrosesquippedaliophobie',
      'anticonstitutionnellement',
      'intergouvernementalisation',
      'oto-rhino-laryngologiste',
      'électroencéphalogramme',
      'brimbaloufragistique',
    ],
  ),
  WordList.create(
    id: 'odd',
    name: 'Faux mots et cas limites',
    words: const [
      'a',
      'y',
      'ô',
      'œuf',
      'cœur',
      'maïs',
      'kkkkkkkk',
      'zigouplouf',
      'wxyz',
    ],
  ),
  WordList.create(
    id: 'name',
    name: 'Une liste au nom vraiment très très long pour voir si le titre '
        'passe sur deux lignes ou se coupe proprement',
    words: const ['chat', 'chien', 'lune'],
  ),
];

const _devices = <String, Size>{
  'small phone upright': Size(360, 640),
  'phone upright': Size(390, 844),
  'phone sideways': Size(852, 393),
  'small phone sideways': Size(640, 360),
  'tablet upright': Size(744, 1133),
  'tablet sideways': Size(1133, 744),
};

final _screens = <String, Widget Function(String id)>{
  'spelling': (id) => SpellingGameScreen(listId: id),
  'scramble': (id) => ScrambleGameScreen(listId: id),
  'fill blanks': (id) => FillBlanksGameScreen(listId: id),
  'writing': (id) => WritingGameScreen(listId: id),
  'qcm': (id) => QcmGameScreen(listId: id),
  'crossword': (id) => CrosswordGameScreen(listId: id),
  'word search': (id) => WordSearchGameScreen(listId: id),
  'list detail': (id) => ListDetailScreen(listId: id),
  'list editor': (id) => ListEditScreen(listId: id),
};

void main() {
  setUpAll(loadGoldenFonts);

  for (final device in _devices.entries) {
    group('on a ${device.key}', () {
      testWidgets('home and parent space hold every list', (tester) async {
        for (final screen in const [HomeScreen(), ParentSpaceScreen()]) {
          await pumpGoldenScreen(
            tester,
            screen,
            theme: AppTheme.of(AppPalette.light),
            overrides: goldenOverrides(_lists),
            size: device.value,
          );
          if (const bool.fromEnvironment('SHOTS')) {
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                'shots/${device.key}/${screen.runtimeType}.png'
                    .replaceAll(' ', '_'),
              ),
            );
          }
        }
      });

      for (final list in _lists) {
        for (final screen in _screens.entries) {
          testWidgets('${screen.key} holds the "${list.id}" list',
              (tester) async {
            // An overflow fails the test while pumping.
            await pumpGoldenScreen(
              tester,
              screen.value(list.id),
              theme: AppTheme.of(AppPalette.light),
              overrides: goldenOverrides(_lists),
              size: device.value,
            );
            if (const bool.fromEnvironment('SHOTS')) {
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile(
                  'shots/${device.key}/${list.id}_${screen.key}.png'
                      .replaceAll(' ', '_'),
                ),
              );
            }
          });
        }
      }
    });
  }
}
