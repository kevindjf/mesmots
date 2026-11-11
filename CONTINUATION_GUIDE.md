# JeRevise - Guide de continuation (Phases 2-5)

## Etat actuel (Phase 1 terminee)

### Ce qui a ete fait
- `pubspec.yaml` : rename `mesmots` → `jerevise`, ajout `assets/data/` dans les assets
- Global find-replace : `package:mesmots/` → `package:jerevise/` dans tous les `.dart`
- `app_colors.dart` : ajout couleurs sections (sectionOrtho, sectionConjug, sectionMaths + shadows)
- `app_strings.dart` : rename appName → JeRevise, ajout strings sections
- `main.dart` : rename `MesMotsApp` → `JeReviseApp`, redirige vers `SectionHomeScreen`
- `home_screen.dart` : rename `HomeScreen` → `OrthoHomeScreen`, ajout bouton retour
- `pin_setup_screen.dart` : redirige vers `SectionHomeScreen` au lieu de `HomeScreen`
- **Nouveau** : `lib/features/home/presentation/screens/section_home_screen.dart` - ecran d'accueil par sections
- **Nouveau** : `lib/features/home/presentation/widgets/section_card.dart` - carte section Mr. Square
- **Nouveau** : `lib/features/conjugation/presentation/screens/conjugation_home_screen.dart` - **PLACEHOLDER** a remplacer en Phase 4

### Ce qu'il reste a faire
- Le display name iOS/Android n'a PAS ete modifie (AndroidManifest.xml, Info.plist) - a faire si besoin
- `build_runner` n'a PAS ete re-execute - les `.g.dart` referenceront encore `mesmots` dans certains cas. Il faudra executer `dart run build_runner build --delete-conflicting-outputs` apres toutes les phases.

---

## Phase 2 — Porter la couche donnees de Conjugo

### Source : `/Users/kevin/kappsmobile/projects/interne/conjugo/`

### 2.1 Copier les assets

```bash
# Depuis la racine du projet mesmots/
mkdir -p assets/data assets/sounds
cp /Users/kevin/kappsmobile/projects/interne/conjugo/assets/data/verbs.json assets/data/
cp /Users/kevin/kappsmobile/projects/interne/conjugo/assets/data/verbs_builder.json assets/data/
cp /Users/kevin/kappsmobile/projects/interne/conjugo/assets/sounds/pick.mp3 assets/sounds/
cp /Users/kevin/kappsmobile/projects/interne/conjugo/assets/sounds/snap.mp3 assets/sounds/
cp /Users/kevin/kappsmobile/projects/interne/conjugo/assets/sounds/time_up.mp3 assets/sounds/
```

### 2.2 Creer les entites domain

Dossier : `lib/features/conjugation/domain/entities/`

| Fichier | Source Conjugo | Transformation |
|---------|---------------|----------------|
| `verb.dart` | `models/verb.dart` | Port direct - classe Verb(infinitive, groupTag, present) avec fromJson |
| `verb_builder_data.dart` | `models/verb_builder.dart` | Renommer `VerbBuilder` → `VerbBuilderData` pour eviter conflit. Contient aussi VerbPart et ConjugationParts |
| `conjugation_constants.dart` | `data/constants.dart` | Port direct - SUBJECTS, AppConstants avec timeLimits, questionCounts, groupMetadata |
| `quiz_config.dart` | `models/quiz_config.dart` | Port direct - selectedVerbs, timeLimit, numberQuestions |
| `quiz_question.dart` | `models/quiz_question.dart` | Port direct - import Verb depuis le nouveau chemin |
| `quiz_state.dart` | `models/quiz_state.dart` | Port direct - import QuizQuestion depuis nouveau chemin |
| `verb_builder_config.dart` | `models/verb_builder_config.dart` | Port direct - GameMode enum + VerbBuilderConfig |
| `verb_builder_question.dart` | `models/verb_builder_question.dart` | Importer VerbBuilderData au lieu de VerbBuilder |
| `verb_builder_state.dart` | `models/verb_builder_state.dart` | Importer depuis nouveaux chemins |
| `conjugation_progress.dart` | **NOUVEAU** | Classe pour stocker progression par verbe |

**Attention** : Dans `verb_builder_question.dart` et `verb_builder_state.dart`, remplacer les imports de `../models/verb_builder.dart` par le nouveau chemin et utiliser `VerbBuilderData` au lieu de `VerbBuilder`.

### 2.3 Creer les interfaces repository

Dossier : `lib/features/conjugation/domain/repositories/`

**verb_repository.dart** :
```dart
import '../entities/verb.dart';

abstract class VerbRepository {
  Future<List<Verb>> getAll();
  Future<List<Verb>> getByGroup(String groupTag);
  Future<List<Verb>> getByInfinitives(Set<String> infinitives);
}
```

**verb_builder_repository.dart** :
```dart
import '../entities/verb_builder_data.dart';

abstract class VerbBuilderRepository {
  Future<List<VerbBuilderData>> getAll();
  Future<List<VerbBuilderData>> getByGroup(String groupe);
  Future<List<VerbBuilderData>> getByInfinitives(Set<String> infinitives);
}
```

**conjugation_progress_repository.dart** :
```dart
import '../entities/conjugation_progress.dart';

abstract class ConjugationProgressRepository {
  Future<ConjugationProgress?> getProgress(String verbInfinitive);
  Future<void> saveProgress(ConjugationProgress progress);
  Future<void> resetProgress();
}
```

### 2.4 Creer les datasources

Dossier : `lib/features/conjugation/data/datasources/`

**verb_json_datasource.dart** : Convertir `VerbsRepository` statique en classe injectable avec `@riverpod`. Charger `assets/data/verbs.json`, cache memoire.

**verb_builder_json_datasource.dart** : Convertir `VerbBuilderRepository` statique en classe injectable avec `@riverpod`. Charger `assets/data/verbs_builder.json`.

**conjugation_progress_local_datasource.dart** : Operations Hive box pour la progression.

### 2.5 Modele Hive

**`lib/features/conjugation/data/models/conjugation_progress_model.dart`** :
- `@HiveType(typeId: 2)`
- Champs : quizScores, quizAttempts, builderScores, builderAttempts, totalSessions

### 2.6 Implementations repository

Dossier : `lib/features/conjugation/data/repositories/`
- `verb_repository_impl.dart` → delegue a VerbJsonDatasource
- `verb_builder_repository_impl.dart` → delegue a VerbBuilderJsonDatasource
- `conjugation_progress_repository_impl.dart` → delegue a Hive datasource

### 2.7 Modifier database_provider.dart

Ajouter :
```dart
import 'package:jerevise/features/conjugation/data/models/conjugation_progress_model.dart';

// Dans initializeDatabase() :
if (!Hive.isAdapterRegistered(2)) {
  Hive.registerAdapter(ConjugationProgressModelAdapter());
}

// Nouveau provider :
@riverpod
Future<Box<ConjugationProgressModel>> conjugationProgressBox(
  ConjugationProgressBoxRef ref,
) async {
  final box = await Hive.openBox<ConjugationProgressModel>('conjugationProgress');
  ref.onDispose(() => box.close());
  return box;
}
```

---

## Phase 3 — Porter la logique de jeu (Providers)

### 3.1 Etendre AudioService

Modifier `lib/core/utils/audio_service.dart` - ajouter :
```dart
Future<void> playPick() => _play('sounds/pick.mp3');
Future<void> playSnap() => _play('sounds/snap.mp3');
Future<void> playTimeUp() => _play('sounds/time_up.mp3');
```

### 3.2 Quiz Provider

**Creer** `lib/features/conjugation/presentation/providers/conjugation_quiz_provider.dart`

Convertir `QuizNotifier` (StateNotifier) → `@riverpod class ConjugationQuiz extends _$ConjugationQuiz`

Points cles :
- Le Conjugo original utilise `ProviderScope(overrides: [...])` pour injecter les verbes. Avec @riverpod, utiliser un parametre family : `build(QuizConfig config)`
- Le provider charge les verbes via `ref.read(verbRepositoryProvider)`
- Timer interne avec `Timer.periodic`
- Methodes : `answer(String?)`, `next()`
- Audio : utiliser `ref.read(audioServiceProvider)` pour playSuccess/playError

Source reference : `/Users/kevin/kappsmobile/projects/interne/conjugo/lib/providers/quiz_provider.dart`

### 3.3 Verb Builder Provider

**Creer** `lib/features/conjugation/presentation/providers/verb_builder_game_provider.dart`

Convertir `VerbBuilderNotifier` → `@riverpod class VerbBuilderGame extends _$VerbBuilderGame`

Points cles :
- `build(VerbBuilderConfig config)` charge les verbes et genere les questions
- Methodes : selectRadical, selectTerminaison, clearRadical, clearTerminaison, validateAnswer, nextQuestion
- Timer pour mode expert
- Audio : pick/snap via audioServiceProvider

Source reference : `/Users/kevin/kappsmobile/projects/interne/conjugo/lib/providers/verb_builder_provider.dart`

---

## Phase 4 — Reconstruire l'UI en Mr. Square

### 4.1 Modifier GameHeader

Ajouter parametre optionnel `timer` a `lib/features/games/presentation/widgets/game_header.dart` :
```dart
final Widget? timer; // Widget chrono optionnel
```

### 4.2 Widgets specifiques conjugaison

Dossier : `lib/features/conjugation/presentation/widgets/`

**lego_brick.dart** : Port depuis `/conjugo/lib/widgets/lego_brick.dart`
- Garder LegoBrickPainter CustomPainter
- Remplacer `Colors.blue.shade600` → `AppColors.sectionConjug` (radical)
- Remplacer `Colors.orange.shade600` → `AppColors.sectionOrtho` (terminaison)
- Police → Fredoka

**draggable_brick.dart** : Port depuis `/conjugo/lib/widgets/draggable_brick.dart`
- Import VerbPart depuis nouveau chemin
- Import LegoBrick depuis nouveau chemin

**brick_drop_zone.dart** : Port depuis `/conjugo/lib/widgets/brick_drop_zone.dart`
- Style Mr. Square (ombres 3D offset sans blur)
- Import depuis nouveaux chemins

### 4.3 Ecrans a creer

Tous dans `lib/features/conjugation/presentation/screens/` :

**conjugation_home_screen.dart** (REMPLACER le placeholder) :
- GradientBackground + AppHeader("Conjugaison")
- Bouton retour vers SectionHomeScreen
- 2 cartes : Quiz (avec emoji 🎯) et Batisseur (emoji 🧱)
- Style Mr. Square avec AppCard/SectionCard
- Source ref : `/conjugo/lib/screens/games_menu_page.dart`

**quiz_setup_screen.dart** :
- Selection verbes par groupe, temps, nb questions
- GradientBackground + AppHeader
- ColorfulButton pour demarrer
- Source ref : `/conjugo/lib/screens/home_page.dart`

**quiz_game_screen.dart** :
- GameHeader avec timer + progression
- Question avec verbe + sujet
- 3 boutons reponse style ColorfulButton
- Feedback correct/incorrect
- Source ref : `/conjugo/lib/screens/quiz_page.dart`

**quiz_result_screen.dart** :
- ProgressStars, score, pourcentage
- Boutons rejouer / retour
- Source ref : `/conjugo/lib/screens/result_page.dart`

**builder_setup_screen.dart** :
- PAYSAGE FORCE (SystemChrome.setPreferredOrientations)
- Selection mode (simple/moyen/expert) + verbes
- Source ref : `/conjugo/lib/screens/verb_builder_setup_page.dart`

**builder_game_screen.dart** :
- PAYSAGE FORCE
- Layout horizontal : panel gauche (mascotte+prompt), centre (assembly zone + brick bin)
- DraggableBrick + BrickDropZone
- GameHeader avec progression
- Source ref : `/conjugo/lib/screens/verb_builder_page.dart`

**builder_result_screen.dart** :
- Resultats avec etoiles
- Source ref : `/conjugo/lib/screens/verb_builder_result_page.dart`

---

## Phase 5 — Integration & verification

### 5.1 Navigation
- SectionHomeScreen → ConjugationHomeScreen (deja cable)
- ConjugationHomeScreen → QuizSetupScreen / BuilderSetupScreen
- Quiz : Setup → Game → Result → retour
- Builder : Setup → Game (paysage) → Result → retour

### 5.2 Code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5.3 Verification
```bash
flutter analyze
flutter build ios --no-codesign
```

Test navigation :
1. Section Home → Ortho → jeux (inchange)
2. Section Home → Conjugaison → Quiz Setup → Quiz → Result
3. Section Home → Conjugaison → Builder Setup → Builder (paysage) → Result

---

## Reference rapide des fichiers source Conjugo

Tous les fichiers source sont dans `/Users/kevin/kappsmobile/projects/interne/conjugo/lib/` :

```
models/          → port dans domain/entities/
data/            → port dans data/datasources/ et domain/entities/ (constants)
providers/       → port dans presentation/providers/ (convertir @riverpod)
screens/         → reecrit from scratch en Mr. Square dans presentation/screens/
widgets/         → port+restyle dans presentation/widgets/
services/        → remplace par AudioService existant (etendu)
```

## Patterns MesMots a respecter

- Tous les providers utilisent `@riverpod` annotation (pas de `StateNotifierProvider` manuel)
- Les fichiers generes sont `part 'file_name.g.dart'`
- Clean Architecture : Entity → Repository interface → DataSource → Repository impl → Provider
- Hive models : `@HiveType(typeId: N)` avec conversion `toEntity()` / `fromEntity()`
- Couleurs : toujours via `AppColors`, jamais hardcodees
- Typographie : toujours `fontFamily: AppTypography.fontFamily`
- Widgets partages : privilegier les existants (ColorfulButton, AppCard, GradientBackground, etc.)
- Style Mr. Square : ombres 3D (offset sans blur), animation press (100ms), coins arrondis
