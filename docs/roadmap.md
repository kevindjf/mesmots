# Roadmap MesMots

Tickets issus des retours testeurs (ThePooley, Florent) et du découpage v1 / v1.1 / v2.
Format pensé pour un import futur dans Linear : un titre `[ID] Titre`, puis étiquettes, priorité, description et critères d'acceptation.

Priorités : P1 urgent · P2 haute · P3 normale · P4 basse.

## À prévoir (prochaine version)

- [ ] **MM-31** Code parent oublié : contrôle parental hors ligne (calcul dur) puis nouveau code, sans perte de données
- [ ] **MM-16** Partage de liste par QR code, entre deux téléphones, sans réseau
- [ ] **MM-15** Export / import de listes par la feuille de partage (base du QR code)
- [ ] **MM-30** Accent anglais pour les mots en anglais

Livré en 1.3.0 (22/11/2026) : MM-23 à MM-29.

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

## Retours testeur du 18/11/2026 (à trier)

Retour global très positif : « j'ai envie d'y jouer toute la journée », la personne va recommander l'app. Les priorités ci-dessous sont des propositions.

#### MM-23 Couper la voix quand on passe au mot suivant
- **Étiquettes** : bug, audio
- **Priorité** : P2
- **Description** : Dans « Écoute et épelle », si l'enfant écrit plus vite que l'épellation, la voix continue en fond alors qu'on est déjà passé au mot suivant.
- **Critères d'acceptation**
  - [ ] Le TTS est stoppé à la validation d'un mot, au changement de mot et à la sortie du jeu
  - [ ] Vérifier le même cas dans tous les jeux qui lisent ou épellent un mot

#### MM-24 Placer le curseur au milieu d'un mot dans « Écriture »
- **Étiquettes** : ux, jeux
- **Priorité** : P2
- **Description** : Impossible de toucher au milieu d'un mot pour insérer une lettre oubliée (ex. « bueau » → ajouter le r) : il faut tout effacer.
- **Critères d'acceptation**
  - [ ] Un tap sur une lettre déplace le curseur à cet endroit
  - [ ] La saisie et l'effacement s'appliquent à la position du curseur

#### MM-25 Ne plus perdre les modifications d'une liste
- **Étiquettes** : bug, ux, parent
- **Priorité** : P1
- **Description** : Dans l'éditeur de liste, le bouton Enregistrer en bas n'est pas visible. Le testeur a quitté et perdu ses mots sans comprendre pourquoi.
- **Critères d'acceptation**
  - [ ] Bouton Enregistrer toujours visible (épinglé, au-dessus du clavier), ou sauvegarde automatique
  - [ ] À défaut d'autosave : avertissement « modifications non enregistrées » en quittant

#### MM-26 Mots longs sur une seule ligne dans la liste
- **Étiquettes** : ui
- **Priorité** : P3
- **Description** : « hypocondriaque » passe sur deux lignes dans la liste sur téléphone. Réduire la taille du texte pour les mots longs plutôt que de les couper (FittedBox / AutoSizeText).
- **Critères d'acceptation**
  - [ ] Un mot reste sur une seule ligne, avec une taille minimale lisible

#### MM-27 Mots croisés : sauter les lettres déjà remplies
- **Étiquettes** : ux, jeux
- **Priorité** : P2
- **Description** : Le testeur veut taper le mot en entier d'un trait. Aujourd'hui il faut penser à ne pas retaper les lettres déjà posées par un autre mot.
- **Critères d'acceptation**
  - [ ] Si la case suivante est déjà remplie (croisement) et que la touche tapée est cette lettre, elle est absorbée et le curseur avance
  - [ ] Les doubles lettres marchent : pour « ll », le second tap remplit bien la case vide suivante
  - [ ] Si la lettre tapée diffère de la case pré-remplie, comportement à définir (on saute la case et on écrit dans la suivante ?)

#### MM-28 Bouton fermer sur la même ligne que la barre de progression
- **Étiquettes** : ui, jeux
- **Priorité** : P3
- **Description** : Pour gagner de la hauteur dans tous les jeux, mettre le bouton X sur la même ligne que la carte de progression (« 0/2 validés … 0% ») au lieu d'une ligne à part.
- **Critères d'acceptation**
  - [ ] Header commun à tous les jeux : X à gauche, progression à droite
  - [ ] Tap target du X toujours ≥ 44 px

#### MM-29 Jouer en paysage (téléphone et tablette)
- **Étiquettes** : ui, responsive
- **Priorité** : P1 (prochain chantier)
- **Description** : En paysage, aucun jeu n'est jouable. L'orientation n'est pas verrouillée (Info.plist autorise le paysage), donc les écrans débordent. Le paysage serait utile pour un clavier aux touches plus espacées.
- **Critères d'acceptation**
  - [ ] Tous les jeux jouables en paysage sur téléphone et tablette (consigne d'un côté, clavier de l'autre par exemple)
  - [ ] À défaut, verrouiller le portrait sur téléphone en attendant

#### MM-30 Prononciation des mots en anglais
- **Étiquettes** : audio, i18n
- **Priorité** : P3
- **Lié à** : MM-20
- **Description** : Le testeur utilise aussi l'app pour ses mots d'anglais. La voix devrait les lire avec l'accent anglais. Plus léger que MM-20 : une langue par liste (ou par mot) qui pilote la voix TTS.
- **Critères d'acceptation**
  - [ ] Choix de la langue sur une liste, voix TTS correspondante
  - [ ] Épellation et distracteurs : à cadrer avec MM-20

#### MM-31 Récupérer le code parent sans réinstaller
- **Étiquettes** : parent
- **Priorité** : P2
- **Description** : Code PIN oublié = réinstaller l'app et perdre toute la progression. Le testeur propose de demander un email, et demande pourquoi rien n'est stocké en ligne.
- **Décision (22/11/2026)** : solution 100 % hors ligne, pas d'email ni de compte. Un lien « Code oublié ? » sur l'écran du PIN ouvre un contrôle parental (un calcul dur), puis permet de choisir un nouveau code. Les listes et la progression sont conservées. Le PIN n'est pas une sécurité, il sert seulement à tenir l'enfant (6-9 ans) hors de l'espace parent.
- **Critères d'acceptation**
  - [ ] Lien « Code oublié ? » sur l'écran de saisie du PIN
  - [ ] Contrôle parental tiré au hasard, hors de portée d'un enfant de primaire : par exemple une multiplication à deux chiffres (« 37 × 6 »), ou un nombre écrit en lettres à taper en chiffres (« quatre cent soixante-dix-huit »)
  - [ ] Nouvelle question après une erreur ; un délai après plusieurs erreurs pour empêcher de tenter au hasard
  - [ ] Réponse juste → choix d'un nouveau PIN, sans perte de données
  - [ ] Contrôle parental réutilisable plus tard pour les liens externes et la notation de l'app, que la catégorie Enfants de l'App Store exige

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
- **Priorité** : P2
- **Description** : Partager une liste entre parents ou entre appareils. Cas concret (22/11/2026) : deux parents sur deux téléphones qui veulent la même liste de la semaine. Pas de serveur : c'est ce qui évite pour l'instant d'avoir besoin d'internet et d'un compte.
- **Critères d'acceptation**
  - [ ] Export via la feuille de partage système (fichier ou texte)
  - [ ] Import depuis un fichier ou du texte collé, avec dédoublonnage
  - [ ] Format versionné

#### MM-16 Partage de liste par QR code
- **Étiquettes** : v1.1, feature
- **Priorité** : P2
- **Dépend de** : MM-15
- **Description** : Générer un QR code pour une liste et le scanner sur un autre appareil. C'est le plus simple pour deux parents côte à côte : aucun réseau nécessaire, et une liste d'une vingtaine de mots tient largement dans un QR code. Un enseignant pourrait aussi afficher la dictée de la semaine.
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
