import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';

/// Sujets de conjugaison (constante globale pour faciliter l'accès)
const kSubjects = ['je', 'tu', 'il/elle', 'nous', 'vous', 'ils/elles'];

/// Constantes utilisées dans l'application de conjugaison
class ConjugationConstants {
  // Sujets de conjugaison
  static const subjects = kSubjects;

  // Options de temps de réponse (en secondes)
  static const timeLimits = [10, 15, 20, 30, 35];

  // Options de nombre de questions
  static const questionCounts = [10, 15, 20, 30, 35];

  // Valeurs par défaut
  static const defaultTimeLimit = 15;
  static const defaultQuestionCount = 15;

  // Métadonnées des groupes de verbes
  static const groupMetadata = {
    'exception': {
      'icon': Icons.auto_fix_high,
      'color': AppColors.verbGroupException,
      'name': 'Exceptions',
      'description': 'Les verbes magiques (être, avoir, aller, faire)',
    },
    '1': {
      'icon': Icons.looks_one,
      'color': AppColors.verbGroup1,
      'name': '1er groupe',
      'description': 'Les verbes faciles !',
    },
    '2': {
      'icon': Icons.looks_two,
      'color': AppColors.verbGroup2,
      'name': '2ème groupe',
      'description': 'Un peu plus difficile',
    },
    '3': {
      'icon': Icons.looks_3,
      'color': AppColors.verbGroup3,
      'name': '3ème groupe',
      'description': 'Pour les champions !',
    },
  };
}
