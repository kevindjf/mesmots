/// Application strings and constants
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MesMots';

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
  static const String confirmDelete =
      'Es-tu sûr de vouloir supprimer cette liste ?';

  // Games
  static const String chooseGame = 'CHOISIS TON JEU';
  static const String myWords = 'MES MOTS';
  static const String masteredWords = 'mots maîtrisés';
  static const String mastered = 'maîtrisés';
  static const String wordsToLearn = 'mots à apprendre';
  static const String playedTimes = 'Joué';
  static const String crosswordUnavailable =
      'Pas assez de lettres communes entre les mots';
  static const String crosswordAcross = 'Horizontal';
  static const String crosswordDown = 'Vertical';
  static const String crosswordListen = 'Écoute le mot et écris-le';
  static const String hint = 'Aide';
  static const String erase = 'Effacer';
  static const String clearAll = 'Tout effacer';
  static const String copyTheWord = 'Recopie le mot :';

  // Game
  static const String validated = 'validés';
  static const String tapToReplay = '(touche pour réécouter)';
  static const String spellWord = 'Épeler le mot';
  static const String listenWord = 'Écouter le mot';
  static const String listen = 'Écouter';
  static const String spell = 'Épeler';
  static const String spellingListen = 'Écoute les lettres et écris le mot';
  static const String playAgain = 'Rejouer';
  static const String otherGame = 'Choisir un autre jeu';
  static const String backToList = 'Retour à la liste';
  static const String congratulations = 'Bravo !';
  static const String allWordsValidated = 'Tu as joué avec tous tes mots !';

  // Parental
  static const String parentSpace = 'Espace parent';
  static const String parentSpaceIntro =
      'Les listes créées ici apparaissent sur l\'écran de l\'enfant.';
  static const String parentLists = 'LISTES DE MOTS';
  static const String parentNoList = 'Aucune liste pour l\'instant';
  static const String allowedGames = 'JEUX AUTORISÉS';
  static const String allowedGamesHint =
      'L\'enfant ne verra que les jeux cochés pour cette liste.';
  static const String atLeastOneGame = 'Choisis au moins un jeu';

  // Appearance
  static const String appearance = 'APPARENCE';
  static const String themeLight = 'Clair';
  static const String themeDark = 'Sombre';
  static const String highContrast = 'Contraste renforcé';
  static const String highContrastHint =
      'Texte foncé sur les couleurs vives, plus facile à lire.';
  static const String games = 'jeux';
  static const String askAdultForList =
      'Demande à un adulte d\'ajouter ta liste avec le cadenas en haut.';
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
  static const String welcomeTiles = 'MES MOTS';
  static const String welcomeTagline = 'Les mots de la semaine, en jouant !';
  static const String welcomeAudience =
      'Quelques secondes pour tout préparer, c\'est parti !';
  static const String start = 'Commencer';
  static const String skip = 'Passer';
  static const String tourListTitle = 'Vous ajoutez la liste';
  static const String tourListText =
      'Tapez les mots de la semaine, en quelques secondes.';
  static const String tourGamesTitle = 'Votre enfant joue';
  static const String tourGamesText =
      '7 jeux, dans l\'ordre qu\'il veut, quand il veut. Pas de niveau à débloquer.';
  static const String tourStarsTitle = 'Il gagne des étoiles';
  static const String tourStarsText =
      'Chaque réussite donne une étoile au mot. À 3 étoiles, il est maîtrisé. Les erreurs ne retirent rien.';
  static const String createMyCode = 'Créer mon code';
  static const List<String> tourExampleWords = ['maison', 'école', 'soleil'];
  static const String createPinTitle = 'Votre code parent';
  static const String createPinText =
      '4 chiffres pour ouvrir l\'espace parent. Votre enfant ne doit pas le connaître.';
  static const String confirmPinTitle = 'Encore une fois';
  static const String confirmPinText = 'Saisissez le même code pour confirmer.';

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
