import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb_builder_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verb_builder_json_datasource.g.dart';

/// Datasource pour charger les verbes du Bâtisseur depuis le fichier JSON
class VerbBuilderJsonDatasource {
  List<VerbBuilderData>? _cache;

  /// Charge tous les verbes depuis assets/data/verbs_builder.json
  /// Utilise un cache mémoire pour éviter de recharger à chaque appel
  Future<List<VerbBuilderData>> getAll() async {
    if (_cache != null) return _cache!;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/verbs_builder.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cache = jsonList
          .map((item) => VerbBuilderData.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cache!;
    } catch (e) {
      // En cas d'erreur, retourner une liste vide
      _cache = [];
      return _cache!;
    }
  }

  /// Filtre les verbes par groupe
  Future<List<VerbBuilderData>> getByGroup(String groupe) async {
    final all = await getAll();
    return all.where((verb) => verb.groupe == groupe).toList();
  }

  /// Récupère les verbes par leurs infinitifs
  Future<List<VerbBuilderData>> getByInfinitives(Set<String> infinitives) async {
    final all = await getAll();
    return all.where((verb) => infinitives.contains(verb.infinitif)).toList();
  }

  /// Expose the cached verbs synchronously, or null if not yet loaded.
  List<VerbBuilderData>? get cachedVerbs => _cache;

  /// Vide le cache (utile pour les tests)
  void clearCache() {
    _cache = null;
  }
}

@riverpod
VerbBuilderJsonDatasource verbBuilderJsonDatasource(
  VerbBuilderJsonDatasourceRef ref,
) {
  return VerbBuilderJsonDatasource();
}
