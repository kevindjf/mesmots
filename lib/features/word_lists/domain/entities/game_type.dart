/// Available learning games. Every enabled game is always playable, in any
/// order; the adult chooses which games each list offers.
enum GameType {
  qcm,
  scramble,
  fillBlanks,
  writing,
  wordSearch,
  crossword;

  /// Display name of the game
  String get label {
    switch (this) {
      case GameType.qcm:
        return 'Le bon mot';
      case GameType.scramble:
        return 'Lettres mélangées';
      case GameType.fillBlanks:
        return 'Mots à trous';
      case GameType.writing:
        return 'Écriture';
      case GameType.wordSearch:
        return 'Mots mêlés';
      case GameType.crossword:
        return 'Mots croisés';
    }
  }

  /// Short description of the game
  String get description {
    switch (this) {
      case GameType.qcm:
        return 'Choisis la bonne orthographe';
      case GameType.scramble:
        return 'Remets les lettres dans l\'ordre';
      case GameType.fillBlanks:
        return 'Complète les lettres manquantes';
      case GameType.writing:
        return 'Écris le mot en entier';
      case GameType.wordSearch:
        return 'Retrouve les mots cachés';
      case GameType.crossword:
        return 'Écoute et remplis la grille';
    }
  }
}
