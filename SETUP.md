# Configuration du projet MesMots

## Étapes d'installation

### 1. Générer les fichiers de plateforme

Si vous n'avez pas encore les dossiers `android/`, `ios/`, etc., exécutez :

```bash
flutter create . --platforms=android,ios,web
```

Cette commande va créer tous les fichiers nécessaires pour Android, iOS et Web sans écraser vos fichiers existants.

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Android (si problème de namespace)

Si vous rencontrez l'erreur de namespace Android, vérifiez que le fichier `android/build.gradle` contient :

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**Note**: Utilisez AGP 7.3.0 ou 7.4.0 pour compatibilité avec Isar 3.1.0+1.

### 4. Générer le code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l'application

```bash
flutter run
```

## Problèmes courants

### Erreur de namespace Android

**Symptôme**: `Namespace not specified` pour isar_flutter_libs

**Solution**:
1. Le fichier `android/gradle.properties` a été créé avec la configuration nécessaire
2. Assurez-vous que `android/build.gradle` utilise AGP 7.3.0 ou 7.4.0
3. Nettoyez le projet : `flutter clean && flutter pub get`

### Erreur de dépendances

**Symptôme**: Conflit de versions

**Solution**: Les versions ont été verrouillées dans pubspec.yaml pour éviter les conflits

## Assets à ajouter

Pour que l'application fonctionne complètement, vous devez ajouter :

### Polices (obligatoire)
Téléchargez Nunito depuis [Google Fonts](https://fonts.google.com/specimen/Nunito) et placez :
- `Nunito-Regular.ttf` dans `assets/fonts/`
- `Nunito-SemiBold.ttf` dans `assets/fonts/`
- `Nunito-Bold.ttf` dans `assets/fonts/`

### Sons (optionnel pour démarrer)
Les fichiers MP3 sont actuellement des placeholders vides. L'app fonctionnera sans, mais sans feedback audio.

Pour ajouter de vrais sons :
- `assets/sounds/success.mp3`
- `assets/sounds/error.mp3`
- `assets/sounds/word_complete.mp3`
- `assets/sounds/level_complete.mp3`
- `assets/sounds/tap.mp3`
- `assets/sounds/star.mp3`

## Commandes utiles

```bash
# Nettoyer le projet
flutter clean

# Voir les devices disponibles
flutter devices

# Lancer sur un device spécifique
flutter run -d <device-id>

# Générer l'APK
flutter build apk

# Générer l'AAB (pour Play Store)
flutter build appbundle
```
