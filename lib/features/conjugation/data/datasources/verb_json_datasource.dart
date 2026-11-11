import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verb_json_datasource.g.dart';

/// Datasource pour charger les verbes depuis le fichier JSON
class VerbJsonDatasource {
  List<Verb>? _cache;

  /// Charge tous les verbes depuis assets/data/verbs.json
  /// Utilise un cache mémoire pour éviter de recharger à chaque appel
  Future<List<Verb>> getAll() async {
    if (_cache != null) return _cache!;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/verbs.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cache = jsonList
          .map((item) => Verb.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cache!;
    } catch (e) {
      // En cas d'erreur, retourner les verbes par défaut
      _cache = _defaultVerbs();
      return _cache!;
    }
  }

  /// Filtre les verbes par groupe (groupTag)
  Future<List<Verb>> getByGroup(String groupTag) async {
    final all = await getAll();
    return all.where((verb) => verb.groupTag == groupTag).toList();
  }

  /// Récupère les verbes par leurs infinitifs
  Future<List<Verb>> getByInfinitives(Set<String> infinitives) async {
    final all = await getAll();
    return all.where((verb) => infinitives.contains(verb.infinitive)).toList();
  }

  /// Expose the cached verbs synchronously, or null if not yet loaded.
  List<Verb>? get cachedVerbs => _cache;

  /// Vide le cache (utile pour les tests)
  void clearCache() {
    _cache = null;
  }

  /// Verbes par défaut en cas d'erreur de chargement
  List<Verb> _defaultVerbs() {
    return const [
      Verb(
        infinitive: 'être',
        groupTag: 'exception',
        present: {
          'je': 'suis',
          'tu': 'es',
          'il/elle': 'est',
          'nous': 'sommes',
          'vous': 'êtes',
          'ils/elles': 'sont',
        },
      ),
      Verb(
        infinitive: 'avoir',
        groupTag: 'exception',
        present: {
          'je': 'ai',
          'tu': 'as',
          'il/elle': 'a',
          'nous': 'avons',
          'vous': 'avez',
          'ils/elles': 'ont',
        },
      ),
      Verb(
        infinitive: 'aller',
        groupTag: 'exception',
        present: {
          'je': 'vais',
          'tu': 'vas',
          'il/elle': 'va',
          'nous': 'allons',
          'vous': 'allez',
          'ils/elles': 'vont',
        },
      ),
      Verb(
        infinitive: 'faire',
        groupTag: 'exception',
        present: {
          'je': 'fais',
          'tu': 'fais',
          'il/elle': 'fait',
          'nous': 'faisons',
          'vous': 'faites',
          'ils/elles': 'font',
        },
      ),
      Verb(
        infinitive: 'parler',
        groupTag: '1',
        present: {
          'je': 'parle',
          'tu': 'parles',
          'il/elle': 'parle',
          'nous': 'parlons',
          'vous': 'parlez',
          'ils/elles': 'parlent',
        },
      ),
    ];
  }
}

@riverpod
VerbJsonDatasource verbJsonDatasource(VerbJsonDatasourceRef ref) {
  return VerbJsonDatasource();
}
