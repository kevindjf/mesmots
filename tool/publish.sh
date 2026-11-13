#!/usr/bin/env bash
# Publishes a new MesMots version on Google Play.
#
#   tool/publish.sh <patch|minor|major|build> [--track internal|beta|both] [--notes "..."] [--dry-run]
#
# Steps: bump the version in pubspec.yaml (and commit it), build the app bundle
# from that commit in a temporary worktree (uncommitted work is never shipped),
# run analyze + tests, tag the commit, then upload to Google Play.
#
# Upload is automatic when a service account key exists (see
# docs/publication-google-play.md). Without it, the bundle is left in
# build/release/ for a manual import in Play Console.
set -euo pipefail

PACKAGE="fr.kappsmobile.mesmots"
SERVICE_ACCOUNT="${PLAY_SERVICE_ACCOUNT:-$HOME/.keystores/mesmots/play-service-account.json}"
NOTES_FILE="docs/play/release-notes.txt"
VENV="$HOME/.cache/mesmots-publish-venv"

usage() {
  sed -n '2,4p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

# --- Arguments -------------------------------------------------------------
BUMP="${1:-}"
[[ "$BUMP" =~ ^(patch|minor|major|build)$ ]] || usage
shift
TRACK="both"
NOTES=""
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --track) TRACK="$2"; shift 2 ;;
    --notes) NOTES="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) usage ;;
  esac
done
case "$TRACK" in
  internal) TRACKS="internal" ;;
  beta) TRACKS="beta" ;;
  both) TRACKS="internal,beta" ;;
  *) usage ;;
esac

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$1"; }
fail() { printf '\033[1;31m✗ %s\033[0m\n' "$1" >&2; exit 1; }

# --- Checks ----------------------------------------------------------------
step "Vérifications"
[[ -f android/key.properties ]] || fail "android/key.properties manquant (clé d'upload, voir la doc)."
if ! git diff --quiet -- pubspec.yaml || ! git diff --cached --quiet; then
  fail "pubspec.yaml modifié ou fichiers indexés : commite ou annule avant de publier."
fi
if [[ -z "$NOTES" && -f "$NOTES_FILE" ]]; then
  NOTES="$(cat "$NOTES_FILE")"
fi
[[ -n "$NOTES" ]] || fail "Notes de version vides : passe --notes \"...\" ou remplis $NOTES_FILE."
(( ${#NOTES} <= 500 )) || fail "Notes de version trop longues (${#NOTES}/500 caractères)."
if ! git diff --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  echo "ℹ Travail non commité détecté : il ne sera PAS inclus (build depuis le dernier commit)."
fi

# --- Version ---------------------------------------------------------------
CURRENT="$(grep -E '^version: ' pubspec.yaml | sed 's/version: //')"
NAME="${CURRENT%+*}"
CODE="${CURRENT#*+}"
IFS=. read -r MAJ MIN PAT <<<"$NAME"
case "$BUMP" in
  major) MAJ=$((MAJ + 1)); MIN=0; PAT=0 ;;
  minor) MIN=$((MIN + 1)); PAT=0 ;;
  patch) PAT=$((PAT + 1)) ;;
  build) ;;
esac
NEW_NAME="$MAJ.$MIN.$PAT"
NEW_CODE=$((CODE + 1))
NEW="$NEW_NAME+$NEW_CODE"
step "Version $CURRENT → $NEW (pistes : $TRACKS)"
echo "Notes :"
echo "$NOTES" | sed 's/^/  /'

if (( DRY_RUN )); then
  echo
  echo "Dry run : rien n'est modifié."
  exit 0
fi

read -r -p "Continuer ? [o/N] " ANSWER
[[ "$ANSWER" =~ ^[oOyY]$ ]] || fail "Annulé."

sed -i '' "s/^version: .*/version: $NEW/" pubspec.yaml
git commit -q -m "build: bump version to $NEW" -- pubspec.yaml
COMMIT="$(git rev-parse --short HEAD)"

# --- Build from the commit in a temporary worktree --------------------------
step "Build depuis le commit $COMMIT"
WORKTREE="$(mktemp -d)/mesmots-release"
cleanup() { git worktree remove --force "$WORKTREE" >/dev/null 2>&1 || true; }
trap cleanup EXIT
git worktree add -q --detach "$WORKTREE" HEAD
ln -s "$ROOT/android/key.properties" "$WORKTREE/android/key.properties"
(
  cd "$WORKTREE"
  flutter pub get >/dev/null
  dart run build_runner build --delete-conflicting-outputs >/dev/null 2>&1
  step "Analyse"
  flutter analyze --no-fatal-infos
  step "Tests"
  flutter test
  step "App bundle"
  flutter build appbundle --release
)
mkdir -p build/release
AAB="build/release/MesMots-$NEW.aab"
cp "$WORKTREE/build/app/outputs/bundle/release/app-release.aab" "$AAB"
git tag -a "v$NEW" -m "MesMots $NEW" HEAD
echo "✓ $AAB (tag v$NEW)"

# --- Upload ----------------------------------------------------------------
if [[ ! -f "$SERVICE_ACCOUNT" ]]; then
  step "Import manuel"
  echo "Pas de clé de compte de service ($SERVICE_ACCOUNT)."
  echo "Dans Play Console → Tester et publier → Tests internes / Tests ouverts → Créer une version :"
  echo "  1. glisse $AAB"
  echo "  2. colle les notes de version ci-dessus entre <fr-FR> et </fr-FR>"
  echo "  3. Suivant → Enregistrer, puis Vue d'ensemble de la publication → Envoyer pour examen"
  open -R "$AAB" 2>/dev/null || true
  exit 0
fi

step "Envoi sur Google Play"
if [[ ! -x "$VENV/bin/python" ]]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q google-api-python-client google-auth
fi
"$VENV/bin/python" "$ROOT/tool/play_upload.py" \
  --package "$PACKAGE" \
  --key "$SERVICE_ACCOUNT" \
  --aab "$AAB" \
  --tracks "$TRACKS" \
  --name "$NEW_CODE ($NEW_NAME)" \
  --notes "$NOTES"

echo "ℹ Le commit et le tag v$NEW sont locaux : pousse-les quand tu veux (git push --follow-tags)."
echo
echo "✓ MesMots $NEW envoyée. Le test interne est disponible tout de suite ; le test ouvert après l'examen de Google."
