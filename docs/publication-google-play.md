# Publication Google Play (test interne)

Objectif : installer MesMots sur une tablette gérée par Family Link via un **test interne** Google Play, sans mode développeur ni APK.

## Identité de l'app

| | |
|---|---|
| Nom | MesMots |
| Identifiant (applicationId / bundle iOS) | `fr.kappsmobile.mesmots` |
| Compte Play Console | organisation Kapps Mobile |

L'identifiant est définitif une fois l'app créée sur Play Console.

## Clé d'upload (à sauvegarder !)

- Keystore : `~/.keystores/mesmots/upload-keystore.jks` (alias `upload`), **hors du dépôt**.
- Mots de passe : dans `android/key.properties` (ignoré par git, jamais commité).
- **Sauvegarde ces deux fichiers** dans le gestionnaire de mots de passe / coffre de l'entreprise.
- Avec la signature d'app Play (activée par défaut), Google garde la clé de signature finale ; si la clé d'upload est perdue, une réinitialisation est possible via le support Play, mais c'est lent.

Sur une autre machine sans `key.properties`, le build release est signé avec la clé debug (utilisable en local, refusé par Play).

## Construire le bundle

1. Incrémenter la version dans `pubspec.yaml` à chaque envoi (`1.0.0+1` → `1.0.0+2`…) : Play refuse un `versionCode` déjà utilisé.
2. Construire :

```bash
flutter build appbundle --release
```

Fichier produit : `build/app/outputs/bundle/release/app-release.aab`.

## Play Console : première mise en ligne

1. **Créer l'application** : nom « MesMots », langue par défaut français (France), type *Application*, *Gratuite*.
2. **Tester et publier → Tests → Test interne** :
   - Onglet *Testeurs* : créer une liste d'e-mails et y ajouter le compte Google de l'enfant (et le tien).
   - *Créer une release* : accepter la signature d'app Play, importer `app-release.aab`, ajouter une note de version, *Enregistrer*, *Examiner la release*, *Déployer*.
   - Copier le **lien d'inscription** des testeurs (onglet *Testeurs*).
3. **Déclarations** que Play peut demander avant la première diffusion (menu *Tableau de bord → Configurer votre application*) :
   - Règles de confidentialité : une URL est requise pour une app destinée aux enfants (page simple : aucune donnée collectée, tout reste sur l'appareil).
   - Accès à l'application : aucun identifiant requis (le code PIN est créé par l'utilisateur).
   - Annonces : non.
   - Classification du contenu : questionnaire (pas de contenu sensible).
   - Public cible : tranches 5 ans et moins / 6-8 / 9-12 → l'app relève du **programme Familles** de Google Play.
   - Sécurité des données : aucune donnée collectée ni partagée ; la photo de la liste est analysée sur l'appareil (ML Kit) et n'est pas envoyée.

## Installer sur la tablette (Family Link)

1. Sur la tablette, connecté avec le compte de l'enfant, ouvrir le **lien d'inscription** et accepter de devenir testeur.
2. Ouvrir la fiche Play depuis ce lien et demander l'installation.
3. Approuver la demande dans **Family Link** (sur ton téléphone) comme pour toute autre app.

Point à vérifier au premier essai : l'inscription d'un compte supervisé à un test interne n'est pas documentée clairement par Google. Si elle est bloquée, alternatives : installer avec un compte adulte ajouté sur la tablette, ou passer par un **test fermé** (même procédure, liste de testeurs dédiée).

## Mises à jour

Incrémenter la version, reconstruire le `.aab`, créer une nouvelle release dans *Test interne*. La tablette reçoit la mise à jour via le Play Store (sous réserve des réglages Family Link).

## Passage en production (plus tard)

Compte organisation : pas d'obligation de test fermé à 12 testeurs. Il faudra compléter la fiche Play (descriptions, captures, icône 512 px : `docs/play/icon-512.png`) et respecter les exigences du programme Familles.
