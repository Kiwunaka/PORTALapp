# POKROV Client Docs

Last updated: 2026-04-18

This folder contains living client-fork-specific documentation for `POKROV`.

Legacy filename note:

- some client docs still use legacy filenames such as `portal-vpn-v1-spec.md` and `portal-vpn-backlog.md`
- those files are still current for the `POKROV` client fork until a separate rename pass happens

For platform-wide truth, start at the root docs index:

- [Root Docs Index](C:/Users/kiwun/Documents/ai/VPN/docs/README.md)
- [Root Product Overview](C:/Users/kiwun/Documents/ai/VPN/docs/product/portal-vpn-product.md)
- [Root Architecture Overview](C:/Users/kiwun/Documents/ai/VPN/docs/architecture/system-overview.md)
- [Publishing And Signing Guide](C:/Users/kiwun/Documents/ai/VPN/docs/operations/publishing-and-signing-guide.md)

## Client Source Of Truth

### Product

- [POKROV v1 Product Spec](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/product/portal-vpn-v1-spec.md)

### Architecture

- [App-First Session Flow](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/architecture/app-first-session-flow.md)

### Forking And Cleanup

- [Fork Cleanup Tracker](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/fork/fork-cleanup-tracker.md)

### Implementation

- [POKROV Implementation Backlog](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/implementation/portal-vpn-backlog.md)

## Alignment Rules

- Client docs must stay aligned with the platform canon on brand, account model, trial length, Telegram reward, and support entrypoints.
- Client docs must treat browser email auth as additive to the app-first model, not as a replacement for the app or Telegram flows.
- Client docs must treat browser email auth as operationally ready only when transactional sender identity and delivery-confirmation/webhook visibility are live.
- Client docs must describe unavailable email delivery truthfully: if sender or webhook readiness is missing, browser email auth stays blocked or unavailable rather than "almost ready".
- Client docs must treat visible product naming as `POKROV`; legacy `POKROV VPN` identifiers are compatibility-only.
- Client docs must treat Windows release identity, executable naming, and packaged artifact canon as end-to-end `POKROV` / `pokrov`.
- Client docs must treat `Android`, `iOS`, `macOS`, and `Windows` as the public client target for this bridge repo.
- Client docs must distinguish the two-track client strategy:
  automatic app-first activation first on `Android + Windows`, plus a
  key-based delivery and redeem/recovery bridge kept coherent across all four
  target platforms.
- Client docs must describe current public direct-download reality truthfully:
  managed in-app activation and direct public distribution are strongest on
  `Android + Windows`, while Apple bridge flows still depend on compatible
  key-based delivery, install help, and later packaging work.
- Client docs must use [external/logogo.png](C:/Users/kiwun/Documents/ai/VPN/external/logogo.png), [logo/logoclear.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logoclear.svg), and [logo/logowithtext.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logowithtext.svg) as the master brand assets for regenerated launcher, splash, tray, favicon, and share-preview outputs.
- If a client doc conflicts with root canonical docs, update the client doc or explicitly mark the difference as planned work.
- Client docs must describe post-premium free-tier continuation as
  `5 GB / 30 days / 1 device` on the dedicated `NL-free` node.
- Client docs must describe redeem and access-key flows as bridge-compatible
  secondary paths until a later backend wave ships the final first-layer redeem
  contract.
- Client docs must not claim Android public-release readiness until release-build localhost/control-surface checks are complete.
- Client docs must treat a local green `release_orchestrator.py --gates-only` snapshot as necessary but not sufficient; public release still needs live deploy/handoff truth and the required origin evidence.
- Client docs must not present RU-aware routing as fully shipped until the routing strategy layer, DNS split rules, and leak checks are actually verified.
- Client docs must describe only the currently shipped routing modes `Full tunnel` and `All except RU`; keep `Blocked only` as planned work until it exists in code and passes release verification.
- Client docs must distinguish current public download targets from release/store artifacts: app surfaces currently expose Android `Play` / `APK` / mirror and Windows `EXE` / mirror, while `AAB`, `MSIX`, and portable `ZIP` stay operator/store artifacts.
- Client docs must treat `external/client-fork/app/out/` as the canonical packaged Windows bundle after a final green rerun and treat raw client `build/` and `dist/` outputs as disposable local artifacts.
- Client docs must describe `pokrov://` as the canonical public URI scheme and `pokrovvpn://` only as hidden compatibility handling where removal is not yet feasible.
- Client docs must describe the consumer onboarding choice `Optimize everything on this device` vs `Only selected apps` and treat split tunneling as a first-layer product feature.
- Client docs must describe persisted split-tunnel state through backend-owned `route_mode`, `selected_apps`, `requires_elevated_privileges`, and mirrored `route_policy.*` fields instead of implying that the choice is local-only UI state.
- Client docs must keep the public user-facing version line on `0.x.x-beta` and reject inherited visible strings such as `2.5.7 dev`.
- Client docs must keep raw subscription copy, edit, regenerate, or share actions out of the first-layer consumer path.
- Client docs must describe support as a real ticket-backed flow across app, cabinet, and admin; cabinet attachments belong to `/api/tickets/uploads`, and the client must not promise a live in-app chat that does not exist.
