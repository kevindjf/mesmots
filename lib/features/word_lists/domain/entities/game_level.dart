/// Game difficulty levels
enum GameLevel {
  qcm,
  scramble,
  fillBlanks,
  writing;

  /// Get level index (0-3)
  int get index => GameLevel.values.indexOf(this);

  /// Get level number (1-4)
  int get number => index + 1;

  /// Get next level if exists
  GameLevel? get next {
    if (index < GameLevel.values.length - 1) {
      return GameLevel.values[index + 1];
    }
    return null;
  }

  /// Get previous level if exists
  GameLevel? get previous {
    if (index > 0) {
      return GameLevel.values[index - 1];
    }
    return null;
  }

  /// Check if this is the last level
  bool get isLast => this == GameLevel.writing;

  /// Check if this is the first level
  bool get isFirst => this == GameLevel.qcm;

  /// Get level name
  String get name {
    switch (this) {
      case GameLevel.qcm:
        return 'Découverte';
      case GameLevel.scramble:
        return 'Reconstruction';
      case GameLevel.fillBlanks:
        return 'Mots à trous';
      case GameLevel.writing:
        return 'Écriture';
    }
  }

  /// Get level description
  String get description {
    switch (this) {
      case GameLevel.qcm:
        return 'Choisis la bonne orthographe';
      case GameLevel.scramble:
        return 'Remets les lettres dans l\'ordre';
      case GameLevel.fillBlanks:
        return 'Complète les lettres manquantes';
      case GameLevel.writing:
        return 'Écris le mot en entier';
    }
  }

  /// Get level emoji
  String get emoji {
    switch (this) {
      case GameLevel.qcm:
        return '🔵';
      case GameLevel.scramble:
        return '🟢';
      case GameLevel.fillBlanks:
        return '🟠';
      case GameLevel.writing:
        return '🟣';
    }
  }
}
