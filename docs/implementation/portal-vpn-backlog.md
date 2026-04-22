# POKROV Implementation Backlog

Last updated: 2026-04-15

## Current status

Wave 0 note:

- this backlog now tracks only bridge, release-truth, compatibility, and hotfix work in the retained legacy client lane
- new client product-direction backlog should move into `POKROV-app/main` once that repo is bootstrapped locally

The app-first foundation and the consumer information architecture are now largely in place.

As of `2026-04-15`, the documented full `python scripts/release_orchestrator.py --gates-only` success snapshot remains the `2026-04-13` run, and the current repo-local `portal` client suite is green again after the latest support and premium-layout fixes.

Already verified locally by the portal test pack:

- app-first `Try free` bootstrap with real session token persistence
- silent subscription import and activation
- `Quick Connect` home flow
- `Locations`
- `Devices`
- `Profile` rewards and Telegram bonus entry points
- browser checkout continuation from the app
- in-app `Support` handoff with prepared device context

## Remaining public-v1 blockers

### Android local-surface security gate

- initial hardening landed: `Clash API` now defaults to off, and the client has a codified release-gate model for unaudited local surfaces
- repo smoke landed: `python scripts/client_security_smoke.py` now guards default local-surface settings, RU preset groundwork, and known localhost control-path wiring
- repo/static gate pack is green, but that does not replace the required connected-device Android localhost audit
- audit release builds for mixed proxy, local DNS, Clash API, libbox command server, and equivalent localhost control surfaces
- prove default bind scope and third-party reachability on Android instead of assuming `VpnService` isolation is sufficient
- keep Android release blocked if any unauthenticated local admin or proxy surface remains reachable
- add release smoke for localhost port scans before connect, after connect, and after disconnect
- add negative tests for unauthorized local-client access and config or key exposure

### RU-aware routing and DNS gate

- initial groundwork landed: explicit `routing-mode` preference plus rule generation for `Global` and `All except RU`
- replace the current region placeholder with a real routing strategy layer
- keep the current public verification focused on `Global` and `All except RU`
- keep `Blocked only` internal or compatibility-only until the rule layer, DNS behavior, and leak checks are fully implemented
- complete geo asset wiring for GeoIP, GeoSite, routing rules, and DNS presets
- validate DNS split and leak behavior on Android and Windows before treating RU-specific routing copy as shipped

### Release branding and packaging

- keep regenerated launcher, tray, and package assets aligned with the final `POKROV` brand set
- keep Windows package identity, executable naming, installer naming, and release artifacts on the canonical `POKROV` / `pokrov` line
- build fresh release candidates for Android and Windows after the latest branding sync
- sign the final Android and Windows artifacts for public distribution
- keep runtime release handoff aligned with the currently exposed public targets: Android `Play` / `APK` / mirror and Windows `EXE` / mirror
- keep `AAB`, `MSIX`, and portable `ZIP` aligned as store/operator artifacts unless the public payload expands
- updater and source-code metadata no longer fall back to a personal repository URL in non-release builds
- after the final green rerun, retain `external/client-fork/app/out/` as the canonical packaged Windows bundle and treat raw `build/` and `dist/` outputs as disposable local artifacts

### User-facing wording cleanup

- remove remaining user-visible `Hiddify` / old power-user wording from advanced surfaces
- polish Russian copy where inherited text still feels technical or legacy
- keep advanced networking controls out of first-layer onboarding and daily-use screens

### Runtime launch verification

- verify the shipping client uses the real backend contracts for trial, profile, support, and Telegram bonus in release builds
- validate final download links and release handoff values after signed artifacts are published
- confirm app, bot, and authenticated WebApp consume the same runtime `APP_*` values after handoff
- rebuild static marketing exports when public Android or Windows URLs change so `NEXT_PUBLIC_APP_*` stays aligned
- split node-reachability evidence into `current-origin`, `brain-origin`, and `RU-origin` checks when release readiness depends on regional reachability

## Explicit non-blockers for this wave

- internal source identifiers such as the current Dart package name and `package:hiddify/...` imports remain a coordinated refactor, not a last-mile public-v1 blocker
- `iOS` and `macOS` stay in readiness-only status for this release wave
