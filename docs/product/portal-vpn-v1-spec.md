# POKROV v1 Product Spec

Last updated: 2026-04-15

## Document Status

This file is the living client product spec for `POKROV`.

## Legacy Bridge Scope

This spec now documents the retained bridge/hotfix client lane and current public Android+Windows release truth until formal cutover.

- new client development truth belongs to `POKROV-app/main`
- `app-next/` in the root repo is the temporary bootstrap-source workspace until that repo is bootstrapped locally
- use this file for bridge behavior, release packaging continuity, compatibility, and rollback-safe reference work
- do not treat this file as the default home for new primary-UX or product-direction changes after Wave 0

## Summary

`POKROV` is a `consumer-first`, `app-first` connectivity application for `Android` and `Windows`.

`iOS` and `macOS` are not part of the full public `v1` promise. In this release wave they stay in readiness, packaging, and signing-preparation status only.

The target journey is:

- open the app
- tap `Try free`
- receive a real working trial subscription
- tap `Connect`

Telegram must remain optional for first use. It is a growth, recovery, and reward channel, not the primary login wall.
Bot purchase and recovery paths stay valid, but they do not replace the main app-first public journey.
Browser continuation may also use additive email auth on the site and cabinet without replacing the app-first model.
That browser email path is only trustworthy when transactional sender identity and delivery-confirmation or webhook visibility are live.

## Locked Product Decisions

- product name: `POKROV`
- legacy client identifier: `POKROV VPN` only where compatibility removal is not yet feasible
- UX direction: `consumer-first`
- account model: `app-first`
- full public `v1` scope: `Android + Windows`
- Apple scope in this wave: readiness only
- default runtime core: `sing-box`
- `xray` support: advanced compatibility fallback only
- free trial: `5 days`
- Telegram reward: `+10 days`
- public user-facing version line: `0.x.x-beta`
- recommended public routing mode: `All except RU`
- public routing mode set: `All except RU` and `Full tunnel`

## Release Gate Reality

- public `v1` scope remains `Android + Windows`
- `Windows` can continue through the normal public release path when its gates are green
- `Android` is release-blocked until a real release-build audit proves that local proxy, DNS, command, and admin/control listeners are not exposed without acceptable protection
- as of `2026-04-15`, the documented full `python scripts/release_orchestrator.py --gates-only` success snapshot still remains the `2026-04-13` run, while the current repo-local portal/client regression pack is green again and Windows release packaging now targets the canonical `pokrov-*` artifact line
- that local green gate snapshot does not yet prove live deploy, live node enablement, or separate `current-origin`, `brain-origin`, and `RU-origin` checks
- when `release_gate_check.py` includes `android-apk` or `android-aab`, it must require `ANDROID_AUDIT_SERIAL` and treat emulator serials only as adb rehearsal, not as final sign-off
- release builds must start from a clean `libcore` checkout pinned to the SHA recorded by the parent client repo; `python scripts/run_client_release_gate.py preflight` is the canonical repo-local proof for that condition
- production Android signing is still mandatory for publication; debug-keystore fallback is local-smoke-only
- `Clash API` must stay disabled by default in the shipping client; any future use remains explicit advanced opt-in only until the Android local-surface audit is fully closed
- do not tell users that split tunneling, Private Space, Knox, Shelter, or similar app isolation tools are enough to compensate for an unauthenticated local control surface unless a dedicated security review has proven that claim

## Target User Experience

### First launch

The user sees:

- brand and trust message
- `Try free` primary CTA
- short explanation that the trial activates on this device

The app should not ask for:

- keys
- subscription URLs
- Telegram login
- manual import as the primary path

### After trial activation

The app receives a real subscription payload, imports it silently, and switches to a `Quick Connect` home screen.

The home screen should show:

- a large `Connect` button
- `Auto-select` location by default
- current location or best location
- trial or subscription state
- quick access to devices, profile, and support
- safe route labels instead of raw `host:port`, public IP, or other low-level node internals
- stable behavior that keeps the previous node when the gain is too small instead of flapping between nearby options

### Route-mode choice after activation

Before the first live route activation, the app must ask how this device should be optimized:

- `Optimize everything on this device` is the recommended default and stays `TUN`-first
- `Only selected apps` is the consumer split-tunneling path

Public UX rules for that choice:

- Windows should open an executable or process picker for the selected-apps path
- Android should open an installed-app picker for the selected-apps path
- the chosen route mode must persist per device and remain editable later from a dedicated route-mode screen
- the persisted route state should travel through backend-owned `route_mode`, `selected_apps`, `requires_elevated_privileges`, and mirrored `route_policy.*` fields so app, cabinet, and support all see one truth
- if desktop `TUN` needs elevated rights, the app must explain that before connect and guide the user to relaunch as administrator
- first-layer UI must not force normal users through raw system-proxy, service-mode, or low-level transport toggles

### Before trial activation

Before the device receives a real subscription payload:

- the onboarding card remains the primary connection surface
- `Locations` stays gated and must not show fake/demo countries
- `Support` may prepare account or device context, but live ticket history appears only after a real linked session exists
- `Telegram` remains an optional reward and recovery layer, not the first-use wall
- the premium shell, onboarding card, and portal tabs ship with complete RU copy rather than a mixed RU/EN surface

### Renewal and purchase

- purchase and renewal stay available from the app
- the client continues payment through the canonical hosted checkout on `https://pay.pokrov.space/checkout/`
- checkout opens in the external browser or external application rather than through native store billing in this wave
- Telegram purchase continuation may stay visible as a secondary fallback, not the primary CTA

## Information Architecture

Primary tabs:

1. `VPN`
2. `Locations`
3. `Devices`
4. `Profile`
5. `Support`

Legacy `/config-options`, `/about`, and `/logs` may remain only as compatibility redirects. Public IA is the five-tab shell above.

Signed release builds inject updater and source-code metadata through `PORTAL_RELEASE_REPOSITORY_URL`, `PORTAL_RELEASES_API_URL`, `PORTAL_RELEASES_LATEST_URL`, `PORTAL_RELEASES_APPCAST_URL`, and `PORTAL_WARP_DEFAULTS_URL`.

Outside signed release builds, updater and source-code surfaces stay disabled instead of falling back to a personal repository URL.

## Telegram Role

Telegram is used for:

- optional account binding
- reward campaign `+10 days`
- recovery flows
- community and announcements

Current aligned channel and bot:

- channel: `@pokrov_vpn`
- main bot: `@pokrov_vpnbot`

## Support Direction

Support should be reachable from:

- the app itself
- WebApp if the user is already in the platform
- helpbot `@pokrov_supportbot`
- `support@pokrov.space`

Current client behavior for `v1`:

- app support should prepare account and device context before handing the user into Telegram or email
- app support should be reachable directly from inside the client instead of forcing the user to leave the app first
- the client must not pretend there is a realtime in-app support chat unless such a backend actually exists
- authenticated browser and cabinet support should continue as a real ticket flow with thread replies and file uploads instead of a decorative contact form
- public recovery order stays `POKROV app -> web cabinet -> Telegram fallback`
- support diagnostics should show routing mode, DNS policy, transport profile, ruleset/package catalog version, app version, and linked Telegram state without exposing raw secrets or share links

## Smart Connect And Privacy Rules

Quick-connect rules for the public client:

- the backend builds a rollout-compatible shortlist before the client starts latency checks
- premium users probe up to `5` eligible non-free nodes; free-tier users stay on `NL-free` only
- shortlist eligibility rejects disabled, draining, unhealthy, stale, overloaded, and transport-incompatible nodes
- the client combines real device RTT with backend CPU and health penalties and applies a `15%` stickiness threshold before changing nodes
- existing explicit user-node assignments must be respected instead of bypassed by auto-select

Consumer privacy rules:

- normal consumer screens must not expose public IP, raw connection links, raw JSON/profile editors, sniffing terminology, Clash/local-control surfaces, or low-level topology
- route labels and support diagnostics should stay safe and human-readable
- raw subscription copy, edit, regenerate, or share actions must stay out of the first-layer consumer path
- manual import and recovery tools may remain available behind compatibility/recovery paths after silent import succeeds

## Branding Requirements

All public and user-visible client surfaces must ship as `POKROV`.

Replace:

- app name strings
- launcher icons
- splash assets
- tray icons
- update metadata
- release asset names
- visible `Hiddify` references in UI
- canonical public URI scheme should be `pokrov`
- Windows release candidates must resolve package identity, executable naming, installer naming, and protocol activation to `POKROV` / `pokrov`

Tracked separately from public-v1 ship:

- internal `pubspec` name `hiddify`
- `package:hiddify/...` imports
- Android Gradle/Kotlin namespace debt that still matches the inherited source tree
- hidden compatibility URI handlers such as `pokrovvpn://` where update/import continuity still depends on them

Release-facing packaging must still fail if legacy `hiddify` branding leaks into signed Windows `MSIX` identity or public installer surfaces.

Brand source:

- [logogo.png](C:/Users/kiwun/Documents/ai/VPN/external/logogo.png)
- [logoclear.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logoclear.svg)
- [logowithtext.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logowithtext.svg)

Brand-source rule:

- regenerate Android launcher, banner, splash, and other platform raster assets from the current raster master
- regenerate Windows ICO, tray, favicon, and share-preview assets from the current release masters instead of treating older exports as independent truth
- keep in-app and public wordmark rendering aligned with the current vector masters

## Release Continuity

Canonical public release artifacts for this fork:

- `pokrov-android-universal.apk`
- `pokrov-android-market.aab`
- `pokrov-windows-setup-x64.exe`
- `pokrov-windows-setup-x64.msix`
- `pokrov-windows-portable-x64.zip`
- WinGet package identifier: `Pokrov.Pokrov` for stable and `Pokrov.Pokrov.Beta` for the dev channel

Public versioning rule:

- user-facing client surfaces, cabinet download badges, and release notes should present the same beta line `0.x.x-beta`
- inherited upstream display strings such as `2.5.7 dev` must not remain visible in public-facing builds

Current user-facing download surfaces expose only:

- Android `Play` / `APK` / mirror URL
- Windows `EXE` / mirror URL
- install/docs fallback

Treat `AAB`, `MSIX`, and portable `ZIP` as release/store/operator artifacts unless the public payload expands.

Packaging reality:

- raw Android release artifacts live under `external/client-fork/app/build/app/outputs/...`
- raw Windows release artifacts live under `external/client-fork/app/build/windows/x64/runner/Release/...`
- the canonical Windows `out/` bundle is created only by running `external/client-fork/app/scripts/package_windows.ps1` from the client repo root
- after the final green rerun, retain `external/client-fork/app/out/` as the canonical packaged bundle and treat raw `build/` and `dist/` outputs as disposable local artifacts
- Windows packaging must reject legacy `POKROV VPN`, `Pokrov.Vpn`, or `hiddify` residue in packaged `MSIX` identity fields and release-facing installer names
- raw local artifacts do not by themselves prove production signing, live deploy, or completed release handoff

Because Android package identity and Windows app identity changed during the
`POKROV VPN` migration, release continuity is:

- fresh install first
- migration notice required
- old app can remain installed until the new app connects successfully

The product must not promise seamless in-place update from the previous app
line.

Android packaging note:

- keep `applicationId` on the new `space.pokrov.vpn`
- keep the Gradle/Kotlin namespace on legacy `com.hiddify.hiddify` until the Android source tree is migrated as a separate task

## v1 Scope

In scope:

- app-first trial activation
- silent profile provisioning
- quick connect UX
- first-run route-mode onboarding with `Optimize everything on this device` and `Only selected apps`
- smart-connect shortlist and RTT-based auto-select within the existing pool rules
- locations list
- devices management
- profile and renewal
- in-app support
- browser checkout continuation from the app via the canonical pay host
- Telegram reward `+10 days`
- release artifact naming and runtime link wiring for Android and Windows
- public-facing rebrand cleanup for Android and Windows
- advanced routing modes `All except RU` and `Full tunnel`
- built-in Android direct package presets for `banks`, `payments`, `marketplaces`, `telecom`, and `gov_media`
- safe diagnostics that show routing mode and route category without leaking raw config or keys
- emergency response actions such as changing location, refreshing profile, reconnecting, and contacting support

Out of scope:

- forced Telegram sign-in as the primary gate
- admin panel inside the client
- power-user-first navigation
- manual config import as the primary onboarding path
- system-proxy-first or service-mode-first onboarding for normal users
- public `Blocked only` preset until the rule layer, geo assets, and DNS behavior are actually implemented
- public iOS App Store launch
- public macOS distribution promise

## Routing And DNS Direction

Recommended RU-facing preset:

- `All except RU`

Current public preset set:

- `All except RU`
- `Full tunnel`

Planned follow-up preset:

- `Blocked only`

Expected routing behavior for `All except RU`:

- `geoip:ru` direct
- private and reserved destinations direct
- everything else proxied
- torrent and explicit local exceptions handled as dedicated rules

Release rule:

- do not present the existing `Region.ru` preference as a finished RU-routing solution until the real rule layer, geo assets, and DNS split behavior are implemented and verified

Current implementation status:

- the client now has an explicit routing-mode groundwork layer for internal `global`, `allExceptRu`, and hidden `blockedOnly`
- public copy must describe internal `global` as `Full tunnel`
- `All except RU` already maps Russian and private traffic to direct rules in the generated sing-box option set
- `Blocked only` remains hidden or internal until geo assets, DNS split policy, and leak checks are complete enough for honest public verification
- the full preset stack and DNS split policy remain follow-up work
- consumer defaults now align around `All except RU`, tunneled DoH, and first-party user-agent strings rather than legacy tool impersonation
- Android direct-routing assistance now uses a versioned built-in package catalog instead of a raw empty selector-only experience

## Apple Readiness Notes

Readiness work may include:

- bundle ID planning
- display name review
- deep-link scheme review
- entitlement and tunnel target inventory
- signing and notarization prerequisites

Those items are preparation work only until a later release wave approves public Apple distribution.
