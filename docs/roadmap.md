# Roadmap MesMots

Tickets issus des retours testeurs (ThePooley, Florent) et du découpage v1 / v1.1 / v2.
Format pensé pour un import futur dans Linear : un titre `[ID] Titre`, puis étiquettes, priorité, description et critères d'acceptation.

Priorités : P1 urgent · P2 haute · P3 normale · P4 basse.

---

## v1 — Sortie publique (Android + iOS)

### Fait

- [x] **MM-1 Retirer le scan photo ML Kit** : `ocr_service`, `photo_capture_screen`, `image_picker`, `google_mlkit_text_recognition` et les permissions caméra/photos ont été supprimés.
- [x] **MM-2 Pièges des lettres muettes dans « Le bon mot »** : distracteurs sept→set/cet, compter→conter, doigt, vingt, printemps…
- [x] **MM-3 Service d'épellation et bouton « Épeler »** : `TtsService.spell`, `SpellButton`, `LetterName`. Les lettres sont dites par leur vrai nom, les accents et la cédille sont nommés.
- [x] **MM-4 Jeu « Écoute et épelle »** : `GameType.spelling`, lettres surlignées au fur et à mesure qu'elles sont dites.
- [x] **MM-5 Côté parent : écouter et épeler chaque mot** dans l'éditeur de liste.
- [x] **MM-6 Vue dictée : liste de mots repliable en haut** : un tap ouvre une fiche avec deux boutons, Écouter et Épeler, et rien n'est lu automatiquement.
- [x] **MM-7 Écran des jeux en liste, avec des pictos de tuiles de lettres**.

### À faire

#### MM-8 Retirer le seed de debug de `main.dart`
- **Étiquettes** : v1, tech
- **Priorité** : P1
- **Description** : Le bloc `TEMP` (kDebugMode) crée les listes « debug-alphabet » et « Test toutes les lettres ». Il reste à le supprimer une fois l'écoute de l'alphabet terminée.
- **Critères d'acceptation**
  - [ ] Plus aucun code `TEMP` dans `lib/main.dart`
  - [ ] Les listes de debug n'apparaissent plus après une réinstallation

#### MM-9 Préparation iOS
- **Étiquettes** : v1, ios
- **Priorité** : P2
- **Description** : Rendre le build iOS publiable.
- **Critères d'acceptation**
  - [ ] `ios/Podfile` : ligne `platform :ios, '13.0'` (ou plus) décommentée
  - [ ] `PrivacyInfo.xcprivacy` ajouté (APIs utilisées : UserDefaults, horodatage des fichiers)
  - [ ] `Info.plist` sans permissions résiduelles (caméra, photos)
  - [ ] Bundle id, équipe de signature et icônes configurés
  - [ ] TTS français vérifié sur un vrai iPhone : voix, épellation, accents
  - [ ] Build Release lancé sur un appareil

#### MM-10 QA complète Android + iOS
- **Étiquettes** : v1, qa
- **Priorité** : P2
- **Description** : Passer tout le parcours sur le Pixel et sur un iPhone.
- **Critères d'acceptation**
  - [ ] Création, édition et suppression d'une liste, code PIN parent
  - [ ] Les 7 jeux joués de bout en bout, avec la progression des étoiles
  - [ ] Épellation contrôlée sur la liste « Test toutes les lettres » (a–z, accents, ç, œ)
  - [ ] Mode sombre, petits écrans, tablette (grille en 2 colonnes)
  - [ ] Accessibilité : tap targets de 44 px minimum, réduction des animations
  - [ ] `flutter analyze` et `flutter test` au vert

#### MM-11 Mettre à jour les assets des stores
- **Étiquettes** : v1, store
- **Priorité** : P2
- **Description** : Les captures de `docs/play/screenshots` montrent encore 6 jeux en grille. Il faut aussi reprendre la fiche et les notes de version.
- **Critères d'acceptation**
  - [ ] Nouvelles captures : liste des jeux, Écoute et épelle, vue dictée repliable
  - [ ] `store-listing.md` mentionne 7 jeux et l'épellation, sans la photo
  - [ ] `release-notes.txt` à jour
  - [ ] Captures au format iPhone 6.7" et 6.5" pour l'App Store

#### MM-12 Publication Google Play
- **Étiquettes** : v1, store, android
- **Priorité** : P2
- **Description** : Suivre `docs/publication-google-play.md`.
- **Critères d'acceptation**
  - [ ] Politique de confidentialité en ligne (URL publique)
  - [ ] Questionnaire du programme Familles et classification du contenu remplis
  - [ ] Version bumpée, AAB signé envoyé en test interne puis en production

#### MM-13 Publication App Store
- **Étiquettes** : v1, store, ios
- **Priorité** : P2
- **Description** : Première soumission sur l'App Store.
- **Critères d'acceptation**
  - [ ] Fiche App Store Connect créée, catégorie Enfants (tranche d'âge choisie)
  - [ ] Étiquettes de confidentialité : aucune donnée collectée
  - [ ] Build TestFlight testé
  - [ ] Soumis en review

---

## v1.1

#### MM-14 Listes prédéfinies par thème
- **Étiquettes** : v1.1, feature
- **Priorité** : P3
- **Description** : Proposer des listes prêtes à l'emploi (nombres, jours, couleurs, animaux, mots invariables CP/CE1…) que le parent ajoute en un tap. Demande de ThePooley.
- **Critères d'acceptation**
  - [ ] Catalogue embarqué, organisé par niveau ou thème
  - [ ] Une liste ajoutée devient une copie modifiable
  - [ ] Les mots des listes passent le test des pièges (sept, vingt…)

#### MM-15 Export / import de listes
- **Étiquettes** : v1.1, feature
- **Priorité** : P3
- **Description** : Partager une liste entre parents ou entre appareils.
- **Critères d'acceptation**
  - [ ] Export via la feuille de partage système (fichier ou texte)
  - [ ] Import depuis un fichier ou du texte collé, avec dédoublonnage
  - [ ] Format versionné

#### MM-16 Partage de liste par QR code
- **Étiquettes** : v1.1, feature
- **Priorité** : P3
- **Dépend de** : MM-15
- **Description** : Générer un QR code pour une liste et le scanner sur un autre appareil. Un enseignant pourrait par exemple afficher la dictée de la semaine.
- **Critères d'acceptation**
  - [ ] QR code généré côté parent
  - [ ] Scan derrière le code PIN parent, avec une permission caméra justifiée

#### MM-17 Écran d'accueil des jeux
- **Étiquettes** : v1.1, ux
- **Priorité** : P4
- **Description** : Revoir le point d'entrée vers les jeux maintenant qu'il y en a 7 : jeu recommandé, dernier jeu joué…

#### MM-18 Enregistrer la voix du parent pour chaque mot
- **Étiquettes** : v1.1, feature, audio
- **Priorité** : P3
- **Description** : Le parent enregistre sa propre prononciation d'un mot, qui remplace le TTS dans tous les jeux.
- **Critères d'acceptation**
  - [ ] Enregistrer, réécouter, refaire ou supprimer depuis l'éditeur de liste
  - [ ] Lecture prioritaire sur le TTS, avec repli sur le TTS si l'enregistrement manque
  - [ ] Fichiers audio stockés en local et supprimés avec le mot
  - [ ] Permission micro demandée uniquement côté parent

---

## v2

#### MM-19 Mode écriture au stylet
- **Étiquettes** : v2, feature
- **Priorité** : P4
- **Description** : L'enfant écrit le mot à la main, au stylet ou au doigt, et l'écriture est reconnue. Demande de ThePooley.

#### MM-20 Listes en anglais
- **Étiquettes** : v2, i18n
- **Priorité** : P4
- **Description** : Choisir la langue d'une liste, avec le TTS, l'épellation et les distracteurs propres à cette langue.

#### MM-21 Retour du scan photo d'une dictée
- **Étiquettes** : v2, feature
- **Priorité** : P4
- **Description** : Réintroduire l'OCR, retiré en v1 car pas fiable, avec une étape de correction avant l'enregistrement.

---

## Backlog

#### MM-22 Progression douce
- **Étiquettes** : backlog, ux
- **Description** : Adapter la difficulté selon la maîtrise du mot (jeux plus guidés au début, puis plus libres). À cadrer.
