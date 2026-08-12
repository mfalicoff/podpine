# Mobile release runbook

This runbook turns a protected `main` commit into store-ready Android and iOS
artifacts without putting credentials in the repository.

## Required checks

The `Mobile CI` workflow is the release gate. Protect `main` and require its
`Format, analyze, test, and Drift` check. Each push to `main` then compiles an
Android release app bundle, an installable release APK on Linux, and an
unsigned iOS release on macOS. Android CI artifacts are signed with one
persistent secret-backed key so an APK from a later run can update an earlier
one. The workflow refuses to build Android artifacts when signing secrets are
absent; it never falls back to a runner's ephemeral debug key. The iOS job
continues to use `--no-codesign`.

Run the same quality gate locally before tagging:

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos
flutter test
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code -- lib/core/database/app_database.g.dart
```

## Version and production diagnostics

1. Update the release name in `pubspec.yaml` when preparing a release. Mobile
   CI overrides the build-number suffix with the monotonically increasing
   GitHub Actions run number; local store builds must still use a build number
   greater than every previously uploaded build.
2. Add the project DSN to GitHub Actions as the `PODPINE_SENTRY_DSN`
   repository secret. Keep it and any Sentry auth token out of source control.
3. Pass these compile-time values to both platform builds:

```sh
--dart-define=PODPINE_SENTRY_DSN="$PODPINE_SENTRY_DSN"
--dart-define=PODPINE_ENVIRONMENT=production
```

The `Mobile CI` release jobs inject the DSN from the repository secret and
fail before building when the secret is missing. Sentry Flutter derives the
release directly from the built application's package identifier, version, and
build number; Podpine does not define a separate release variable. Local and
signed builds must pass the same DSN and environment values explicitly.

An empty DSN disables uploads. Podpine does not set a Sentry user, collect HTTP
request breadcrumbs or bodies, or attach arbitrary application data. Sync and
download breadcrumbs only contain allowlisted states, counts, status families,
and size buckets. Error messages, URLs, credentials, titles, file paths, feed
addresses, and user identifiers are removed before sending.

## Android signing and update-compatible APKs

Use the repository generator to create a persistent key and a restricted file
containing the four GitHub Actions secret values:

```sh
./scripts/generate_android_signing_secrets.sh
```

The default output is `.secrets/android-signing`, which Git ignores. If the
GitHub CLI is installed and authenticated, the script can also upload the
values without printing them:

```sh
./scripts/generate_android_signing_secrets.sh \
  --output /secure/path/podpine-android-signing \
  --upload \
  --repository mfalicoff/podpine
```

The script refuses to overwrite an existing output directory. Keep its
keystore and credentials file in a secure backup.

To create the credentials manually instead, generate one long-lived signing
key. The same key must sign every directly installed APK for Android to accept
it as an update:

```sh
keytool -genkeypair \
  -keystore podpine-release.p12 \
  -storetype PKCS12 \
  -alias podpine \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000
```

Back up the keystore and its credentials before using it. Losing the key means
future APKs cannot update existing direct installations.

Encode the keystore without committing it:

```sh
base64 < podpine-release.p12 | tr -d '\n'
```

Add the result and credentials as these GitHub Actions repository secrets:

- `PODPINE_ANDROID_KEYSTORE_BASE64`
- `PODPINE_ANDROID_KEYSTORE_PASSWORD`
- `PODPINE_ANDROID_KEY_ALIAS`
- `PODPINE_ANDROID_KEY_PASSWORD`

The Android CI job decodes the keystore into the runner's temporary directory,
validates the configured alias, and passes the four existing signing variables
to Gradle. Both its APK and AAB use the workflow run number as Android's
`versionCode`.

An app installed from an older CI artifact that used an ephemeral debug key
must be uninstalled once before installing the first persistently signed APK.
After that migration, later CI APKs install as normal updates. An app installed
through Google Play must be updated through a Play testing or production track
because Play App Signing may use a different certificate.

## Android local signed app bundle

Store the upload keystore outside the repository. Set all four variables in the
release shell or secret-backed CI job:

```sh
export PODPINE_ANDROID_KEYSTORE_PATH=/secure/path/podpine-release.p12
export PODPINE_ANDROID_KEYSTORE_PASSWORD=...
export PODPINE_ANDROID_KEY_ALIAS=...
export PODPINE_ANDROID_KEY_PASSWORD=...
flutter build appbundle --release \
  --dart-define=PODPINE_SENTRY_DSN="$PODPINE_SENTRY_DSN" \
  --dart-define=PODPINE_ENVIRONMENT=production
```

Confirm Gradle reports the production `release` signing configuration, then
verify the resulting `build/app/outputs/bundle/release/app-release.aab` with
`jarsigner -verify`. Back up the keystore in the team password manager. Rotate
an upload key through Play Console instead of committing a replacement.

## iOS signed archive

Install the App Store Connect API key, distribution certificate, and provisioning
profile through the secret-backed release environment. In Xcode, select the
Podpine team and App Store distribution profile for `app.podpine.podpine`.
Build with the diagnostic defines above:

```sh
flutter build ipa --release \
  --dart-define=PODPINE_SENTRY_DSN="$PODPINE_SENTRY_DSN" \
  --dart-define=PODPINE_ENVIRONMENT=production
```

Validate the archive and IPA in Xcode Organizer before upload. Store API keys,
certificates, profiles, and their passwords only in the release secret store.

## Store metadata checklist

- App name, subtitle/short description, full description, categories, support
  URL, privacy-policy URL, copyright, and release notes are current.
- Phone and tablet screenshots match the submitted build and contain no real
  account data.
- Google Play Data safety and Apple App Privacy disclosures include Pinepods
  account/network use and crash diagnostics.
- Content rating, age rating, export compliance, encryption declarations, and
  review contact/test-account details are complete.
- The physical-device matrix in `docs/DEVICE_TEST_MATRIX.md` is signed off for
  this exact version and build number.
- Sentry debug symbols are uploaded from the signed build, a deliberate test
  crash is symbolicated, and no private fields appear in its event payload.
- Rollout starts staged/phased. Crash-free sessions, sync failures, download
  failures, and store feedback have named owners and rollback thresholds.

After approval, tag the exact protected commit and record links to the CI run,
device matrix, store submission, and Sentry release in the release notes.
