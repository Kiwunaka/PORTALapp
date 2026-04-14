# App-First Session Flow

Last updated: 2026-04-15

## Document Status

This file is the living client architecture note for app-first identity and provisioning.

## Goal

Replace Telegram-first access with an app-native identity and provisioning flow for `POKROV`.

## Core Principle

After `Try free`, the app must receive a real working VPN profile.

UI state alone is not enough. The backend must create a working account, a working device record, and a working subscription source.

## Current Flow

1. App generates and persists `install_id`.
2. App collects soft device context.
3. User taps `Try free`.
4. App calls `POST /api/client/session/start-trial`.
5. Backend validates anti-abuse rules.
6. Backend creates:
   - `app_account`
   - `device_record`
   - `app_session`
7. Backend provisions a real subscription source.
8. Backend returns:
   - `session`
   - `client_policy`
   - `access`
   - `provisioning`
   - experience payload
9. App silently imports the subscription URL and prepares the managed profile.
10. App asks how this device should be optimized before the first live route activation.
11. App saves the chosen per-device route policy.
12. Home screen changes to `Quick Connect`.

UX guardrail:

- until step 9 completes with a real subscription payload, `Locations` stays behind an activation gate and does not render fake/demo countries as if the device already had live access

Contract note:

- the client no longer sends caller-controlled `trial_days`
- the backend always enforces the canonical `5-day` trial from the shared surface facts
- `provisioning.status` must expose whether the profile is ready immediately or still pending sync
- the app should read one additive `client_policy` contract from `start-trial`, `user`, and `dashboard` instead of inferring defaults from stale local assumptions
- the same additive contract should also carry device route-mode state instead of forcing the app to guess from local toggles
- the persisted route choice should round-trip through backend-owned `route_mode`, `selected_apps`, `requires_elevated_privileges`, and mirrored `route_policy.*` fields

Current `client_policy` fields:

- `routing_mode_default`
- `transport_profile`
- `transport_kind`
- `engine_hint`
- `profile_revision`
- `dns_policy`
- `route_mode_default`
- `route_mode_choices`
- `route_mode_requires_elevation`
- `route_mode`
- `selected_apps`
- `requires_elevated_privileges`
- `route_policy.mode`
- `route_policy.selected_apps`
- `route_policy.requires_elevated_privileges`
- `package_catalog_version`
- `ruleset_version`
- `support_context.transport`
- `support_context.routing_mode`
- `support_context.ip_version_preference`
- `support_recovery_order`

## Route-Mode Onboarding Contract

Before the first live connect, the client must ask exactly one consumer question:

- `Optimize everything on this device`
- `Only selected apps`

Contract expectations:

- `Optimize everything on this device` is the default public path and stays `TUN`-first
- `Only selected apps` is the split-tunneling path and must persist selected app or process identifiers per device
- Windows should back that path with an executable or process picker
- Android should back that path with an installed-package picker
- the saved route mode must remain editable later from a dedicated route-mode screen
- if the chosen mode requires elevated rights on desktop, the app must tell the user before connect and guide relaunch as administrator
- raw system-proxy, service-mode, and low-level transport toggles stay outside the first-layer onboarding path
- the chosen mode must stay visible to support and recovery flows through the same backend policy payload instead of drifting into a client-only preference

Managed-profile smart-connect fields:

- `smart_connect.shortlist_revision`
- `smart_connect.transport_profile`
- `smart_connect.profile_revision`
- `smart_connect.shortlist[*].code`
- `smart_connect.shortlist[*].rank_hint.health_score`
- `smart_connect.shortlist[*].rank_hint.cpu_percent`
- `smart_connect.shortlist[*].rank_hint.panel_latency_ms`
- `smart_connect.shortlist[*].rank_hint.backend_penalty`
- `smart_connect.shortlist[*].rank_hint.cpu_penalty`
- `smart_connect.stickiness.preferred_node_code`
- `smart_connect.stickiness.threshold_percent`
- `smart_connect.fallback_order`

## Client-Side Foundation Already Present

As of 2026-03-20, the client-side foundation already covers:

- stable `install_id`
- runtime app `session_token`
- device context headers on portal API calls
- `Try free` action from the empty home screen
- managed manifest fetch from `GET /api/client/profile/managed`
- automatic application of the returned engine-aware config payload
- `subscription_url` fallback for manual import and recovery when the managed manifest is unavailable
- install-scoped latency upload through `POST /api/client/nodes/latency-samples`

That means the remaining work is mostly final UX polish and backend contract alignment rather than first-principles plumbing.

Current consumer shell IA:

- `VPN`
- `Locations`
- `Devices`
- `Profile`
- `Support`

Legacy `/config-options`, `/about`, and `/logs` should survive only as compatibility redirects, not as the public navigation model.

Shared-surface config note:

- client public defaults are synced from root `shared/*.json`
- Flutter consumes the synced adapter file `lib/features/portal/config/shared_surface_facts.dart`
- current public language should expose only `All except RU` and `Full tunnel`; internal names such as `global` or `blockedOnly` stay implementation details
- public consumer connection stays `TUN`-first; loopback proxy mechanics remain advanced or internal-only
- public routing defaults should stay aligned with shared facts: `All except RU`, rollout-selected transport, and `ru_direct_split`
- `legacy_reality_fallback` remains the public baseline until canary cohorts are explicitly promoted to `grpc_443_primary`
- support diagnostics should include routing mode, DNS policy, transport profile, ruleset version, app version, linked Telegram state, and `support_recovery_order`
- normal consumer labels should avoid raw `host:port`, public IP, and raw subscription URLs after silent import succeeds
- first-layer consumer surfaces should avoid raw subscription copy, edit, regenerate, or share actions
- `pokrov://` is the canonical public app-link scheme; `pokrovvpn://` remains hidden compatibility-only where import continuity still requires it

Android direct-app note:

- the client now ships a built-in direct package catalog with a versioned stamp
- current curated categories are `banks`, `payments`, `marketplaces`, `telecom`, and `gov_media`
- preset taps should append matching installed apps without deleting manual overrides

## Related Flows

### Telegram linking

Current platform contract:

- `POST /api/client/telegram/link`

### Telegram bonus claim

Current platform contract:

- `POST /api/bonuses/channel/claim`

Linked Telegram identity and membership in `@pokrov_vpn` can grant `+10 days`.

### Checkout continuation

- renewal and upgrade begin from the client UI
- the app opens the canonical hosted checkout in the external browser
- selected plans continue through the same backend checkout contract used by site and bot flows

### Support

Support payloads should carry:

- app account context
- device record context
- platform
- app version
- last known IP when available

Client UX rule:

- the support screen should prepare context and then continue through Telegram support or email
- authenticated support continuation is ticket-backed through `POST /api/tickets`, `GET /api/tickets/{ticket_id}`, `POST /api/tickets/{ticket_id}/messages`, and `/api/tickets/uploads` on web/cabinet surfaces
- plain connection links, manual import, and similar recovery tools should stay behind advanced/recovery surfaces after silent import succeeds
- the daily user journey should remain inside `VPN`, `Locations`, `Profile`, and `Support`, not bounce users back into raw config affordances
- do not imply a realtime in-app chat unless there is a real backend thread flow behind it
- diagnostics should expose only safe summaries such as routing mode and route category
- diagnostics must not leak raw config, keys, or detailed topology
- when no real session exists yet, support and profile surfaces may show prepared context and recovery entry points, but they must not pretend that live threads or live location inventory already exist
- recovery order in support copy should stay `app -> web cabinet -> Telegram`
- cabinet and profile handoffs should show safe on-screen summaries such as `connect.pokrov.space` while keeping the full personal link behind explicit copy actions

### Download surfaces

- the client fetches `/api/client/apps` and uses runtime URLs for Android `APK` / mirror and Windows `EXE` / mirror, plus docs/install fallback
- release handoff updates those runtime `APP_*` URLs on brain for the app, bot, and authenticated WebApp flows
- static marketing download CTAs are not driven by this runtime payload and must be rebuilt/redeployed when public Android or Windows URLs change
- public marketing direct-download CTA currently depends on `APK` and `EXE` URLs; `Play`-only or mirror-only release values keep runtime surfaces alive but do not produce the same direct button on the marketing install path
- signed release builds inject updater/source-code metadata through `PORTAL_RELEASE_REPOSITORY_URL`, `PORTAL_RELEASES_API_URL`, `PORTAL_RELEASES_LATEST_URL`, `PORTAL_RELEASES_APPCAST_URL`, and `PORTAL_WARP_DEFAULTS_URL`
- local non-release builds keep updater and source-code surfaces disabled instead of falling back to a personal repository URL
- public-facing build surfaces should present the beta line `0.x.x-beta` instead of inherited upstream display strings such as `2.5.7 dev`
- release verification must start from a clean `libcore` checkout pinned to the parent repo SHA; `python scripts/run_client_release_gate.py preflight` is the canonical root-level check before Flutter tests or artifact builds
- test/build modes of `python scripts/run_client_release_gate.py` now auto-bootstrap missing generated Dart assets with `flutter pub get` and `flutter pub run build_runner build --delete-conflicting-outputs`, so clean checkouts can rebuild the ignored codegen surface before Flutter tests begin
- raw Android artifacts live under `build/app/outputs/...`, and raw Windows artifacts live under `build/windows/x64/runner/Release/...`
- client `out/` becomes the canonical packaged Windows bundle only after `scripts/package_windows.ps1` is run from the client repo root
- `AAB`, `MSIX`, and portable `ZIP` remain release/store artifacts rather than first-layer client download targets today
- when `release_gate_check.py` includes Android build gates, it must also include `python scripts/android_localhost_audit.py` against a release-installed build on a physical device via `ANDROID_AUDIT_SERIAL`
- the latest local green `python scripts/release_orchestrator.py --gates-only` snapshot is necessary but not sufficient; Android publication still waits for production signing, the physical-device localhost audit, and separate `current-origin`, `brain-origin`, and `RU-origin` evidence in the release handoff

## Identity Strategy

- primary identifier: `install_id`
- secondary anti-abuse signal: `fingerprint_signal`
- human-readable identity: `device_name`

This is preferred over a Telegram-only identity model.

## Scope Note

This client flow is the shipping `v1` path for:

- `Android`
- `Windows`

For `iOS` and `macOS`, this document is a readiness reference only until Apple publication is formally approved.
