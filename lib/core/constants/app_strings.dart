/// Application strings and constants
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MesMots';
  static const String appEmoji = '🎒';

  // Common
  static const String cancel = 'Annuler';
  static const String validate = 'Valider';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String save = 'Enregistrer';
  static const String close = 'Fermer';
  static const String back = 'Retour';
  static const String next = 'Suivant';
  static const String finish = 'Terminer';
  static const String play = 'Jouer';
  static const String replay = 'Réécouter';
  static const String continueText = 'Continuer';

  // Home
  static const String previousLists = 'Listes précédentes';
  static const String newList = 'Nouvelle liste';

  // Word Lists
  static const String words = 'mots';
  static const String viewWords = 'Voir les mots';
  static const String listName = 'Nom de la liste';
  static const String addWords = 'Ajouter des mots (un par ligne)';
  static const String createList = 'Créer une liste';
  static const String editList = 'Modifier la liste';
  static const String deleteList = 'Supprimer la liste';
  static const String confirmDelete = 'Es-tu sûr de vouloir supprimer cette liste ?';

  // Levels
  static const String level1Name = 'Découverte';
  static const String level2Name = 'Reconstruction';
  static const String level3Name = 'Mots à trous';
  static const String level4Name = 'Écriture';

  static const String level1Description = 'Choisis la bonne orthographe';
  static const String level2Description = 'Remets les lettres dans l\'ordre';
  static const String level3Description = 'Complète les lettres manquantes';
  static const String level4Description = 'Écris le mot en entier';

  static const String levelUnlocked = 'Niveau suivant débloqué';
  static const String levelLocked = 'Atteindre 75% au niveau';
  static const String percentToUnlock = 'pour débloquer';

  // Game
  static const String validated = 'validés';
  static const String tapToReplay = '(touche pour réécouter)';
  static const String nextLevel = 'Niveau suivant';
  static const String backToList = 'Retour à la liste';
  static const String congratulations = 'Bravo !';
  static const String allWordsValidated = 'Tu as validé tous les mots !';

  // Parental
  static const String parentalMode = 'Mode parent';
  static const String enterPin = 'Entre ton code PIN';
  static const String createPin = 'Crée ton code PIN';
  static const String confirmPin = 'Confirme ton code PIN';
  static const String pinMismatch = 'Les codes ne correspondent pas';
  static const String wrongPin = 'Code incorrect';
  static const String recoveryQuestion = 'Question de récupération';
  static const String recoveryAnswer = 'Réponse de récupération';
  static const String forgotPin = 'Code oublié ?';
  static const String changePin = 'Changer le code';

  // Onboarding
  static const String welcomeTitle = 'Bienvenue dans MesMots !';
  static const String welcomeDescription =
      'Apprends tes mots de dictée en t\'amusant !';
  static const String gamesTitle = 'Quatre jeux pour progresser';
  static const String gamesDescription =
      'De la découverte à l\'écriture complète';
  static const String parentalTitle = 'Espace parent sécurisé';
  static const String parentalDescription =
      'Gérez les listes de mots avec un code PIN';

  // Errors
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorLoadingLists = 'Impossible de charger les listes';
  static const String errorSavingList = 'Impossible de sauvegarder la liste';
  static const String errorDeletingList = 'Impossible de supprimer la liste';
  static const String errorEmptyListName = 'Le nom de la liste est requis';
  static const String errorEmptyWords = 'Ajoute au moins un mot';
  static const String errorTtsNotAvailable =
      'La synthèse vocale n\'est pas disponible';
}
