# MesMots 🎒

Application mobile d'apprentissage ludique des mots de dictée pour enfants de 5 à 10 ans.

## 📱 À propos

**MesMots** est une application Flutter permettant aux enfants d'apprendre leurs mots de dictée de manière progressive et ludique, à travers 4 mini-jeux de difficulté croissante :

1. **🔵 Niveau 1 - Découverte (QCM)** : Reconnaître la bonne orthographe parmi 4 propositions
2. **🟢 Niveau 2 - Reconstruction** : Remettre les lettres dans l'ordre
3. **🟠 Niveau 3 - Mots à trous** : Compléter les lettres manquantes
4. **🟣 Niveau 4 - Écriture** : Écrire le mot en entier de mémoire

## ✅ État d'avancement

### ✓ Fonctionnalités implémentées

- [x] Architecture Clean Architecture complète
- [x] Système de persistance avec Isar
- [x] Gestion des listes de mots (CRUD)
- [x] Système de progression par niveau
- [x] Contrôle parental avec code PIN
- [x] Services TTS, Audio et Haptic
- [x] Écran d'accueil avec liste des listes
- [x] Écran de détail d'une liste
- [x] Écran de création/modification de liste
- [x] **Niveau 1 - QCM complet et fonctionnel**
  - Génération intelligente de distracteurs (erreurs phonétiques, accents, etc.)
  - Système de validation (2 réussites requises)
  - Règle des 2 erreurs consécutives
  - Interface adaptée aux enfants
  - Feedback audio et haptique

### 🚧 En cours / À faire

- [ ] Niveau 2 - Lettres mélangées (placeholder créé)
- [ ] Niveau 3 - Mots à trous (placeholder créé)
- [ ] Niveau 4 - Écriture (placeholder créé)
- [ ] Onboarding au premier lancement
- [ ] Configuration initiale du PIN
- [ ] Animations et célébrations
- [ ] Fichiers audio (sons de feedback)
- [ ] Police Nunito
- [ ] Génération du code (build_runner)

## 🏗️ Architecture

Le projet suit une **Clean Architecture** stricte avec séparation Domain / Data / Presentation :

```
lib/
├── core/               # Constantes, thème, services
├── features/           # Features organisées par domaine
│   ├── word_lists/     # Gestion des listes de mots
│   ├── games/          # Mini-jeux
│   ├── parental/       # Contrôle parental
│   └── onboarding/     # Onboarding (à faire)
├── shared/             # Widgets réutilisables
└── main.dart           # Point d'entrée
```

## 🛠️ Stack technique

- **Framework** : Flutter 3.x
- **State Management** : Riverpod (avec code generation)
- **Base de données** : Isar
- **TTS** : flutter_tts
- **Audio** : audioplayers
- **Code Generation** : build_runner, riverpod_generator, isar_generator

## 🚀 Installation

### Prérequis

- Flutter SDK 3.2.0 ou supérieur
- Dart SDK 3.0.0 ou supérieur

### Étapes

1. **Cloner le projet**
   ```bash
   git clone <repo-url>
   cd mesmots
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer le code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Ajouter les assets manquants** (temporairement optionnel)

   Créer les dossiers suivants et ajouter des fichiers placeholder :
   - `assets/sounds/` : success.mp3, error.mp3, word_complete.mp3, level_complete.mp3, tap.mp3, star.mp3
   - `assets/fonts/` : Nunito-Regular.ttf, Nunito-SemiBold.ttf, Nunito-Bold.ttf
   - `assets/animations/` : (Lottie files - optionnel pour l'instant)

5. **Lancer l'app**
   ```bash
   flutter run
   ```

## 📖 Utilisation

### Pour les parents

1. Au premier lancement, cliquer sur l'icône de cadenas pour configurer le code PIN
2. Créer une nouvelle liste de mots
3. Laisser l'enfant jouer

### Pour les enfants

1. Choisir une liste de mots
2. Jouer aux niveaux débloqués
3. Valider chaque mot en le réussissant 2 fois

## 🎮 Règles du jeu

### Validation d'un mot

- Un mot doit être **réussi 2 fois** pour être validé ⭐⭐
- Les 2 réussites n'ont pas besoin d'être consécutives
- Après **2 erreurs consécutives**, le compteur de réussites est remis à zéro

### Déblocage des niveaux

- **Niveau 1 (QCM)** : toujours débloqué
- **Niveaux 2, 3, 4** : débloqués quand le niveau précédent atteint **75%**

## 📝 Configuration

### Charte graphique

Le projet utilise une palette de couleurs pastel douce adaptée aux enfants :

- Bleu pastel (Niveau 1)
- Vert pastel (Niveau 2)
- Orange pastel (Niveau 3)
- Violet pastel (Niveau 4)

### Typographie

Police recommandée : **Nunito** (arrondie et friendly)

Tailles adaptées aux enfants (plus grandes que la normale).

## 🤝 Contribution

Le projet est organisé selon les principes SOLID :

- **Aucune logique dans les vues** : utiliser les providers
- **Un widget = une responsabilité**
- **Pas de duplication** : utiliser shared/
- **Immutabilité** : entités immuables avec copyWith

## 📄 Licence

Ce projet est un projet éducatif.

## 🎯 Prochaines étapes

1. Implémenter les niveaux 2, 3 et 4
2. Créer le flow d'onboarding
3. Ajouter les assets audio et police
4. Implémenter les animations de célébration
5. Tests sur Android et iOS
6. Polish final de l'UI

---

Développé avec ❤️ pour aider les enfants à apprendre leurs mots de dictée
