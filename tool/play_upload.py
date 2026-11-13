"""Uploads an app bundle to Google Play tracks and sends it for review.

Used by tool/publish.sh. Needs a service account with release rights on the
app (see docs/publication-google-play.md).
"""

import argparse

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SCOPE = "https://www.googleapis.com/auth/androidpublisher"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", required=True)
    parser.add_argument("--key", required=True, help="Service account JSON key")
    parser.add_argument("--aab", required=True)
    parser.add_argument("--tracks", required=True, help="e.g. internal,beta")
    parser.add_argument("--name", required=True, help="Release name")
    parser.add_argument("--notes", required=True, help="fr-FR release notes")
    args = parser.parse_args()

    credentials = service_account.Credentials.from_service_account_file(
        args.key, scopes=[SCOPE]
    )
    play = build("androidpublisher", "v3", credentials=credentials, cache_discovery=False)
    edits = play.edits()

    edit_id = edits.insert(packageName=args.package, body={}).execute()["id"]

    print(f"Import de {args.aab}…")
    bundle = edits.bundles().upload(
        packageName=args.package,
        editId=edit_id,
        media_body=MediaFileUpload(
            args.aab, mimetype="application/octet-stream", resumable=True
        ),
    ).execute()
    version_code = str(bundle["versionCode"])
    print(f"✓ Bundle importé (versionCode {version_code})")

    for track in args.tracks.split(","):
        edits.tracks().update(
            packageName=args.package,
            editId=edit_id,
            track=track,
            body={
                "track": track,
                "releases": [
                    {
                        "name": args.name,
                        "versionCodes": [version_code],
                        "status": "completed",
                        "releaseNotes": [{"language": "fr-FR", "text": args.notes}],
                    }
                ],
            },
        ).execute()
        print(f"✓ Release prête sur la piste {track}")

    # Committing sends the changes for review (managed publishing is off).
    edits.commit(packageName=args.package, editId=edit_id).execute()
    print("✓ Modifications validées et envoyées pour examen")


if __name__ == "__main__":
    main()
