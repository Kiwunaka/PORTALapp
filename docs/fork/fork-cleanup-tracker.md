# Fork Cleanup Tracker

Last updated: 2026-04-15

## Goal

Track the remaining brand-migration work for `POKROV` without accidentally destabilizing the shipping client fork.

## Branding

| Area | Status | Notes |
|---|---|---|
| App display name | Done | Runtime app surfaces target `POKROV`; keep `POKROV VPN` only in explicitly documented compatibility-only cases |
| Launcher icon | Mostly done | Current branding sync regenerates release-facing launcher assets from the canonical masters; verify again on signed artifacts |
| Splash assets | Mostly done | Runtime splash and regenerated derivatives follow the current brand masters; recheck signed builds only |
| Tray icons | Mostly done | Current branding sync updates the Windows icon pipeline; keep signed-build verification in the release handoff |
| App update metadata | Done | Appcast, web manifest, release message, store descriptions, and release-url fallbacks no longer point to the personal repo and now use `POKROV` branding |
| README and docs branding | In progress | Canonical docs are aligned; keep cleaning stale support notes and workflow examples that still suggest legacy values |

## Remaining visible Hiddify references

| Area | Status | Notes |
|---|---|---|
| Supporting docs and inherited history files | Pending | Clean up only what can confuse public release or operator handoff |
| Binary names such as `HiddifyCli.exe` | Done | `libcore`, build scripts, and Windows release bundle now use `POKROVCli.exe` only |
| Advanced labels and old settings wording | In progress | Continue rewriting visible inherited power-user wording for the consumer UX where it still leaks through |
| Android namespace / test namespace | Deferred | `com.hiddify.hiddify` and `test.com.hiddify.hiddify` stay until the package tree is migrated as a dedicated refactor |
| Internal package name / imports | Deferred | `pubspec name: hiddify` and `package:hiddify/...` are internal refactor debt, not a last-minute public-v1 rename |

## UX cleanup

| Area | Status | Notes |
|---|---|---|
| Trial shown without working profile | Done | Portal tests cover live app-first trial provisioning and silent import |
| Fake demo nodes | Mostly done | Portal flows now use backend-backed data; keep validating release builds with real payloads |
| In-app support using demo copy | Mostly done | Support composer exists; final release verification still needed against production wiring |
| Russian copy polish | In progress | Consumer-facing copy improved, but advanced/legacy wording still needs a final pass |
| First-layer Hiddify power-user settings | In progress | Keep finishing the move of technical controls into `Advanced` |

## Product decisions already locked

- Product name: `POKROV`
- Trial: `5 days`
- Telegram reward: `+10 days`
- Product direction: `consumer-first`
- Identity direction: `app-first`
- Default core: `sing-box`
- `xray` only in advanced compatibility mode

## Immediate implementation priorities

1. Run the connected-device Android localhost audit against a release-installed build before public Android publication.
2. Sign and verify the final Android and Windows release artifacts against the current `POKROV` branding and runtime link handoff.
3. Finish visible advanced-surface wording cleanup.
4. Recheck runtime support, reward, and profile flows in signed release-mode builds.
5. Keep internal package/import and Android namespace debt as a separate coordinated refactor instead of a last-minute public rename.
