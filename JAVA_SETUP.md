# Configuration Java pour MesMots

## Problème

Android Gradle Plugin 8.1.1 **nécessite Java 17 ou supérieur**.

Actuellement, votre système utilise Java 11, ce qui cause l'erreur :
```
Android Gradle plugin requires Java 17 to run. You are currently using Java 11.
```

## Solution : Installer et configurer Java 17

### Étape 1 : Installer Java 17

#### Sur macOS (avec Homebrew)

```bash
# Installer OpenJDK 17
brew install openjdk@17

# Créer un lien symbolique pour que le système reconnaisse Java 17
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

#### Sur macOS (avec SDKMAN - Alternative)

```bash
# Installer SDKMAN si ce n'est pas déjà fait
curl -s "https://get.sdkman.io" | bash

# Installer Java 17
sdk install java 17.0.9-tem

# Utiliser Java 17 par défaut
sdk default java 17.0.9-tem
```

### Étape 2 : Configurer Flutter pour utiliser Java 17

#### Option A : Configuration globale Flutter (Recommandé)

```bash
# Configurer Flutter pour utiliser Java 17
flutter config --jdk-dir=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# Vérifier la configuration
flutter doctor -v
```

#### Option B : Configuration locale au projet

Modifiez `android/gradle.properties` et décommentez/ajoutez :

```properties
org.gradle.java.home=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

### Étape 3 : Vérification

```bash
# Vérifier la version Java utilisée par Flutter
java -version

# Devrait afficher quelque chose comme:
# openjdk version "17.0.x"
```

### Étape 4 : Nettoyer et rebuilder

```bash
# Nettoyer les builds précédents
cd android
./gradlew clean
cd ..
flutter clean

# Réinstaller les dépendances
flutter pub get

# Essayer de builder
flutter run
```

## Vérifier quelle version de Java vous avez

```bash
# Lister toutes les installations Java
/usr/libexec/java_home -V

# Voir quelle version est utilisée actuellement
java -version
echo $JAVA_HOME
```

## Dépannage

### Si Flutter ne trouve pas Java 17

Vérifiez le chemin exact :
```bash
# Trouver où Java 17 est installé
/usr/libexec/java_home -v 17

# Ou avec Homebrew
brew info openjdk@17
```

Puis configurez Flutter avec le bon chemin :
```bash
flutter config --jdk-dir=<chemin-affiché>
```

### Si l'erreur persiste

1. Redémarrez votre terminal pour que les changements d'environnement prennent effet
2. Vérifiez que `JAVA_HOME` pointe vers Java 17 :
   ```bash
   export JAVA_HOME=$(/usr/libexec/java_home -v 17)
   ```
3. Ajoutez cette ligne à votre `~/.zshrc` ou `~/.bash_profile` pour la rendre permanente

## Alternatives

### Utiliser Java 11 (Non recommandé)

Si vous ne pouvez vraiment pas installer Java 17, vous pouvez downgrader AGP à 7.4.0, mais cela créera un conflit avec Flutter qui recommande AGP 8+.

Dans ce cas, modifiez `android/settings.gradle.kts` :
```kotlin
id("com.android.application") version "7.4.0" apply false
```

**Note** : Cette approche n'est pas recommandée car Flutter pourrait éventuellement forcer AGP 8+.

## Résumé rapide

```bash
# Installation complète en 4 commandes
brew install openjdk@17
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
flutter config --jdk-dir=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
flutter doctor -v
```

Ensuite :
```bash
cd /Users/kevin/kappsmobile/projects/interne/mesmots
flutter clean
flutter pub get
flutter run
```
