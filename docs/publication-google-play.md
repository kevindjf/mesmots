# Publication Google Play

## Mettre à jour l'app (le cas courant)

1. Écrire les notes de version dans `docs/play/release-notes.txt` (500 caractères max, en français, pour les utilisateurs).
2. Lancer :

```bash
tool/publish.sh patch
```

C'est tout. Le script :

- passe la version à la suivante dans `pubspec.yaml` et commite ce changement ;
- construit l'app **depuis ce commit**, dans un dossier temporaire : le travail non commité n'est jamais publié ;
- lance `flutter analyze` et `flutter test` (s'arrête en cas d'échec) ;
- produit `build/release/MesMots-<version>.aab` et pose le tag `v<version>` ;
- envoie le bundle sur Google Play, en **test interne** (disponible tout de suite) et en **test ouvert** (après examen de Google, en général quelques heures à quelques jours).

Le commit et le tag restent locaux : `git push --follow-tags` quand tu veux.

### Options

| Commande | Effet |
|---|---|
| `tool/publish.sh patch` | 1.1.1 → 1.1.2 (corrections, petites améliorations) |
| `tool/publish.sh minor` | 1.1.1 → 1.2.0 (nouveau jeu, nouvelle fonctionnalité) |
| `tool/publish.sh major` | 1.1.1 → 2.0.0 |
| `tool/publish.sh build` | Garde 1.1.1, n'augmente que le numéro de build (renvoi d'un build) |
| `--track internal` | Seulement le test interne (essayer avant la bêta) |
| `--track beta` | Seulement le test ouvert |
| `--notes "…"` | Notes de version sans passer par le fichier |
| `--dry-run` | Affiche la future version et les notes, sans rien modifier |

Le numéro de build (`+N`) augmente à chaque envoi : Play refuse un numéro déjà utilisé.

### Faut-il repasser par la fiche Play Store ?

**Non**, pas pour une mise à jour. Une nouvelle version = un nouveau bundle + des notes de version, c'est tout. On ne retouche Play Console que si :

| Changement dans l'app | À mettre à jour |
|---|---|
| Nouveau jeu, écran très différent | Captures d'écran (`docs/play/screenshots/`) et descriptions (`docs/play/store-listing.md`) dans *Fiche Play Store* |
| Nouvelle permission (caméra, photos…) | *Contenu de l'application* : déclaration correspondante + *Sécurité des données* |
| Données envoyées hors de l'appareil, SDK d'analyse, pubs | *Sécurité des données*, *Annonces*, politique de confidentialité (https://kapps-mobile.fr/mesmots/confidentialite/) |
| Public visé différent | *Cible et contenu* |

Attention : l'app est dans le **programme Familles** (enfants de moins de 13 ans). Tout SDK tiers doit être certifié « Familles », sinon l'app peut être refusée. C'est pour ça que ML Kit a été retiré.

## Mise en place de l'envoi automatique (une seule fois)

Sans cette étape, le script s'arrête après le build : il ouvre le Finder sur le `.aab` et affiche les clics à faire dans Play Console.

1. **Google Cloud** (https://console.cloud.google.com), avec le compte Kapps Mobile :
   - créer (ou choisir) un projet ;
   - *API et services → Bibliothèque* : activer **Google Play Android Developer API** ;
   - *IAM → Comptes de service* : créer un compte de service (ex. `play-publisher`), sans rôle ;
   - sur ce compte : *Clés → Ajouter une clé → JSON*. Enregistrer le fichier sous `~/.keystores/mesmots/play-service-account.json` (**hors du dépôt, jamais commité**).
2. **Play Console → Utilisateurs et autorisations → Inviter de nouveaux utilisateurs** :
   - e-mail : celui du compte de service (`…@….iam.gserviceaccount.com`) ;
   - autorisations sur l'app MesMots : *Publier dans les canaux de test*, *Gérer les canaux de test et les listes de testeurs*, *Voir les informations sur l'application*.
3. Tester avec `tool/publish.sh build --track internal`.

Les droits peuvent mettre jusqu'à 24 h à s'appliquer. En cas d'erreur `403`, attendre et relancer `tool/publish.sh build`.

## Ce qu'il ne faut pas perdre

- Clé d'upload : `~/.keystores/mesmots/upload-keystore.jks` (alias `upload`) et ses mots de passe dans `android/key.properties` (ignoré par git).
- Clé du compte de service : `~/.keystores/mesmots/play-service-account.json`.

Sauvegarder ces fichiers dans le coffre de l'entreprise. Sans `key.properties`, le build release est signé avec la clé debug et Play le refuse. La signature finale est gérée par Google (signature d'app Play) : si la clé d'upload est perdue, une réinitialisation est possible via le support Play, mais c'est lent.

## Identité de l'app

| | |
|---|---|
| Nom sur le Play Store | MesMots - Mots de dictée |
| Identifiant | `fr.kappsmobile.mesmots` (définitif) |
| Compte Play Console | Kapps Mobile |
| Catégorie | Enseignement |
| Contact public | contact@kapps-mobile.com |
| Confidentialité | https://kapps-mobile.fr/mesmots/confidentialite/ (source : `docs/play/privacy-policy.html`) |
| Public cible | 5 ans et moins, 6-8, 9-12 (programme Familles, « Approuvé par les enseignants » demandé) |
| Test ouvert | France, Belgique, Suisse, Luxembourg, Monaco, Canada |

## Testeurs

- **Test interne** : liste « MesMots - Famille » (Play Console → Tests internes → Testeurs). Lien d'inscription : https://play.google.com/apps/internaltest/4701531246511080208. Le testeur doit ouvrir le lien connecté avec l'adresse Gmail ajoutée ; un ajout récent peut mettre jusqu'à une heure à être pris en compte (avant, Google affiche « URL not found »).
- **Test ouvert** : tout le monde peut rejoindre depuis la fiche Play Store, dans les pays ciblés.

## Installer une version de développement sur un téléphone

Une app installée depuis Play est signée par Google ; une app installée avec `adb` ou `flutter run` est signée avec la clé d'upload ou debug. Android refuse de passer de l'une à l'autre (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`) : il faut désinstaller, ce qui efface les listes et la progression.

## Famille et tablette (Family Link)

Sur la tablette, connecté avec le compte de l'enfant, ouvrir le lien d'inscription au test interne, accepter, puis demander l'installation et l'approuver dans Family Link.
