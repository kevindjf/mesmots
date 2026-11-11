import 'package:flutter/material.dart';

/// Modèle représentant une partie d'un verbe (radical ou terminaison)
class VerbPart {
  final String text;
  final bool isRadical; // true pour radical, false pour terminaison

  const VerbPart({
    required this.text,
    required this.isRadical,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerbPart &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isRadical == other.isRadical;

  @override
  int get hashCode => text.hashCode ^ isRadical.hashCode;

  @override
  String toString() => 'VerbPart(${isRadical ? "R" : "T"}: $text)';
}

/// Modèle représentant une conjugaison avec son découpage
class ConjugationParts {
  final String subject; // "je", "tu", "il/elle", etc.
  final String complet; // Forme complète : "parle"
  final String radical; // Radical : "parl"
  final String terminaison; // Terminaison : "e"

  const ConjugationParts({
    required this.subject,
    required this.complet,
    required this.radical,
    required this.terminaison,
  });

  factory ConjugationParts.fromJson(String subject, Map<String, dynamic> json) {
    return ConjugationParts(
      subject: subject,
      complet: json['complet'] as String,
      radical: json['radical'] as String,
      terminaison: json['terminaison'] as String,
    );
  }

  /// Vérifie si la combinaison radical + terminaison est correcte
  bool isCorrectCombination(String radicalTest, String terminaisonTest) {
    return radical == radicalTest && terminaison == terminaisonTest;
  }

  @override
  String toString() =>
      'ConjugationParts($subject: $complet = [$radical] + [$terminaison])';
}

/// Modèle représentant un verbe pour le Bâtisseur de Verbes
/// Renamed from VerbBuilder to VerbBuilderData to avoid conflicts
class VerbBuilderData {
  final String infinitif;
  final String groupe; // "1", "2", "3"
  final Map<String, ConjugationParts> present; // Conjugaisons au présent

  const VerbBuilderData({
    required this.infinitif,
    required this.groupe,
    required this.present,
  });

  factory VerbBuilderData.fromJson(Map<String, dynamic> json) {
    final presentMap = json['present'] as Map<String, dynamic>;

    final conjugations = <String, ConjugationParts>{};
    presentMap.forEach((subject, data) {
      conjugations[subject] =
          ConjugationParts.fromJson(subject, data as Map<String, dynamic>);
    });

    return VerbBuilderData(
      infinitif: json['infinitif'] as String,
      groupe: json['groupe'] as String,
      present: conjugations,
    );
  }

  /// Récupère les radicaux uniques de ce verbe
  Set<String> get uniqueRadicals {
    return present.values.map((c) => c.radical).toSet();
  }

  /// Récupère les terminaisons uniques de ce verbe
  Set<String> get uniqueTerminaisons {
    return present.values.map((c) => c.terminaison).toSet();
  }

  /// Récupère l'icône correspondant au groupe
  IconData get groupIcon {
    switch (groupe) {
      case '1':
        return Icons.looks_one;
      case '2':
        return Icons.looks_two;
      case '3':
        return Icons.looks_3;
      default:
        return Icons.menu_book;
    }
  }

  @override
  String toString() => 'VerbBuilderData($infinitif, groupe $groupe)';
}
