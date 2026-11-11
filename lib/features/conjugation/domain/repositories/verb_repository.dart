import 'package:jerevise/features/conjugation/domain/entities/verb.dart';

/// Interface du repository pour les verbes du quiz
abstract class VerbRepository {
  /// Récupère tous les verbes
  Future<List<Verb>> getAll();

  /// Récupère les verbes par groupe
  Future<List<Verb>> getByGroup(String groupTag);

  /// Récupère les verbes par leurs infinitifs
  Future<List<Verb>> getByInfinitives(Set<String> infinitives);
}
