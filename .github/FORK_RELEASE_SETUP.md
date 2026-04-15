# Fork Release Setup (Android + Windows)

Workflow: `.github/workflows/fork-android-windows-release.yml`

## Required for builds

- `ANDROID_SIGNING_KEY` (base64 keystore, optional but recommended)
- `ANDROID_SIGNING_STORE_PASSWORD` (optional with key)
- `ANDROID_SIGNING_KEY_PASSWORD` (optional with key)
- `ANDROID_SIGNING_KEY_ALIAS` (optional with key)

- `WINDOWS_SIGNING_KEY` (base64 `.pfx`, optional)
- `WINDOWS_SIGNING_PASSWORD` (optional with key)

## Recommended repository variables (branding overrides)

- `BRAND_NAME` (example: `POKROV`)
- `ANDROID_APPLICATION_ID` (example: `space.pokrov.vpn`)
- `ANDROID_NAMESPACE` (example: `com.hiddify.hiddify`)
- `ANDROID_TEST_NAMESPACE` (example: `test.com.hiddify.hiddify`)
- `URI_SCHEME` (example: `pokrov`)
- `WINDOWS_IDENTITY_NAME` (example: `pokrov`)
- `WINDOWS_PUBLISHER_NAME` (example: `POKROV`)
- `WINDOWS_INSTALL_DIR` (example: `POKROV`)
- `WINDOWS_EXE_STEM` (example: `POKROV`)
- `BRAND_COPYRIGHT` (optional custom copyright line)

## Required for Play upload (optional)

- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- Repository variable `ANDROID_PACKAGE_NAME` (defaults to `space.pokrov.vpn` if missing)

## Required for mirror upload (optional)

- `MIRROR_SSH_HOST`
- `MIRROR_SSH_USER`
- `MIRROR_SSH_KEY` (private key in PEM/OpenSSH format)

## Manual run

1. Open Actions -> `Fork Android + Windows Release`.
2. Set:
   - `release_tag` (example: `v1.0.0`)
   - `channel` (`prod` for stable, `dev` for test channel)
   - enable `create_github_release`
   - enable `upload_to_play` when AAB should be pushed to Play track
   - enable `push_to_mirror` when mirror upload is configured
3. Run workflow.
4. Download artifact `release-handoff` and apply links via:
   - `pwsh external/client-fork/scripts/release_handoff.ps1`
   - `python external/client-fork/scripts/check_release_urls.py --env-file external/client-fork/release-links.env`

Default artifact slug in this repo is `pokrov`.
Default mirror path in this repo is `/var/www/downloads/pokrov`.
Default WinGet package identifier in this repo is `Pokrov.Pokrov` and the dev channel publishes as `Pokrov.Pokrov.Beta`.
Keep the Android namespace on the legacy `com.hiddify.hiddify` package unless you also migrate the Kotlin source tree under `android/app/src/main/kotlin`.
