import 'package:jerevise/features/conjugation/domain/entities/verb_builder_data.dart';

/// Interface du repository pour les verbes du Bâtisseur de Verbes
abstract class VerbBuilderRepository {
  /// Récupère tous les verbes
  Future<List<VerbBuilderData>> getAll();

  /// Récupère les verbes par groupe
  Future<List<VerbBuilderData>> getByGroup(String groupe);

  /// Récupère les verbes par leurs infinitifs
  Future<List<VerbBuilderData>> getByInfinitives(Set<String> infinitives);
}
