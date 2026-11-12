# MesMots 🎒

Application mobile pour apprendre en s'amusant les **mots de dictée de la semaine** (enfants de 5 à 10 ans).

## 📱 À propos

Un adulte (parent, maîtresse…) saisit ou photographie la liste de mots de la semaine. L'enfant l'apprend ensuite à travers 6 jeux, **dans l'ordre qu'il veut, quand il veut, autant de fois qu'il veut** : pas de niveaux à débloquer, pas de frustration.

| Jeu | Principe |
|---|---|
| **Le bon mot** | Choisir la bonne orthographe parmi plusieurs propositions |
| **Lettres mélangées** | Remettre les lettres dans l'ordre |
| **Mots à trous** | Compléter les lettres manquantes |
| **Écriture** | Écouter le mot et l'écrire en entier |
| **Mots mêlés** | Retrouver les mots cachés dans une grille (glisser le doigt, ou toucher la première puis la dernière lettre) |
| **Mots croisés** | Écouter chaque mot et le placer dans la grille ; la 1re lettre est donnée et un bouton « Aide » révèle une lettre |

Les mots sont lus à voix haute (synthèse vocale). Les accents sont conservés dans tous les jeux : c'est l'orthographe qu'on apprend.

## 🎮 Progression

- Chaque réussite, **dans n'importe quel jeu**, donne une étoile au mot.
- Un mot est **maîtrisé à 3 étoiles**. Les erreurs ne retirent jamais d'étoiles.
- L'écran de la liste affiche les étoiles de chaque mot et le nombre de parties jouées par jeu.
- Les mots croisés ne sont proposés que si les mots de la liste ont assez de lettres en commun pour se croiser (au moins 3 mots placés).

## 📖 Utilisation

### Pour l'adulte

1. Au premier lancement, créer le code PIN parental : l'espace parent s'ouvre directement.
2. Ensuite, toucher le cadenas de l'accueil et saisir le code pour ouvrir l'**espace parent**.
3. Dans l'espace parent : créer, modifier ou supprimer une liste (saisie manuelle ou photo avec reconnaissance de texte) et choisir les **jeux autorisés** pour chaque liste (tous par défaut).

Les écrans de l'enfant n'affichent aucune action de gestion.

### Pour l'enfant

1. Choisir la liste de la semaine.
2. Choisir un jeu parmi ceux autorisés, jouer, rejouer, changer de jeu.

## 🏗️ Architecture

Clean Architecture *feature-first* :

```
lib/
├── core/            # Constantes (couleurs, textes, dimensions), thème, services (TTS, audio, haptique, OCR, Hive)
├── features/
│   ├── word_lists/  # Listes de mots, maîtrise par mot, écrans d'accueil et de liste
│   ├── games/       # Les 6 jeux (générateurs de grilles en Dart pur dans domain/usecases)
│   ├── parental/    # Code PIN et espace parent
│   └── onboarding/  # Premier lancement
├── shared/widgets/  # Widgets réutilisables (style « Mr. Square »)
└── main.dart
```

## 🛠️ Stack technique

- Flutter 3.x, Riverpod (génération de code)
- Hive (persistance locale)
- flutter_tts, audioplayers
- google_mlkit_text_recognition (photo de la liste)
- Tests : flutter_test, mocktail

## 🚀 Installation

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter run
```

## ✅ Tests

```bash
flutter test
```

Les générateurs de grilles sont aussi testés une fois compilés en JavaScript (les entiers s'y comportent différemment) :

```bash
flutter test --platform chrome test/features/games/domain
```

## 🗂️ Historique

La version multi-matières « JeRevise » (orthographe, conjugaison, maths) est conservée sous le tag git `jerevise-snapshot` ; la conjugaison et les maths deviendront des applications séparées.
