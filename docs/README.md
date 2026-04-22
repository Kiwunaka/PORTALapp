# POKROV Client Docs

Last updated: 2026-04-22

This folder contains living client-fork-specific documentation for `POKROV`.

`external/client-fork/app/` is the retained legacy bridge/hotfix workspace and the current public Android+Windows release/build/signing lane until formal cutover.

Wave 7 deprecation note:

- feature-direction work is frozen out of this lane
- keep this docs tree for compatibility, rollback-safe release truth, and emergency bridge maintenance only

Its nested location inside the platform repository is convenience-only:

- bridge-period packaging, hotfix, and release-doc changes happen here
- new client development truth moves to `POKROV-app/main`
- root platform docs and platform code still land on `portal/master`
- do not treat the nested checkout as a second platform authority just because it is present under the same parent workspace

Wave 0 lane note:

- expected new client repo checkout after bootstrap: `C:/Users/kiwun/Documents/ai/POKROV-app`
- that checkout is now bootstrapped locally; `app-next/` in the root repo remains transition/bootstrap reference material only
- this legacy docs set remains authoritative only for bridge, hotfix, compatibility, and current release-truth behavior

Legacy filename note:

- some client docs still use legacy filenames such as `portal-vpn-v1-spec.md` and `portal-vpn-backlog.md`
- those files are still current for the `POKROV` client fork until a separate rename pass happens

For platform-wide truth, start at the root docs index:

- [Root Docs Index](C:/Users/kiwun/Documents/ai/VPN/docs/README.md)
- [Root Product Overview](C:/Users/kiwun/Documents/ai/VPN/docs/product/portal-vpn-product.md)
- [Root Architecture Overview](C:/Users/kiwun/Documents/ai/VPN/docs/architecture/system-overview.md)
- [Publishing And Signing Guide](C:/Users/kiwun/Documents/ai/VPN/docs/operations/publishing-and-signing-guide.md)

## Workspace And Artifact Rules

- treat `external/client-fork/app/` as the default local workspace only for bridge/hotfix edits, release packaging, and legacy-client maintenance
- keep the broader repo split simple: new client-direction changes belong to `POKROV-app/main`, bridge-release changes belong to this legacy repo, and root docs plus other platform work belong to `portal/master`
- retain `external/client-fork/app/out/` when it contains the canonical packaged bundle from the latest green rerun or any artifact still being verified, handed off, or distributed
- treat raw client `build/` and `dist/` outputs as disposable local artifacts that may be rebuilt
- do not confuse retained packaged outputs in `out/` with disposable raw build products

## Client Source Of Truth

Bridge note:

- this docs tree is no longer the long-term client canon for new product-direction work
- use it when the retained bridge lane or current public release truth changes
- use `app-next/docs/*` as bootstrap-source material until `POKROV-app/docs/*` exists locally

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
- Client docs must treat `Android + Windows` as the full public `v1` scope.
- Client docs must treat `iOS` and `macOS` as readiness-only in this release wave unless a later canonical doc changes that status.
- Client docs must use [external/logogo.png](C:/Users/kiwun/Documents/ai/VPN/external/logogo.png), [logo/logoclear.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logoclear.svg), and [logo/logowithtext.svg](C:/Users/kiwun/Documents/ai/VPN/logo/logowithtext.svg) as the master brand assets for regenerated launcher, splash, tray, favicon, and share-preview outputs.
- If a client doc conflicts with root canonical docs, update the client doc or explicitly mark the difference as planned work.
- Client docs must not claim Android public-release readiness until release-build localhost/control-surface checks are complete.
- Client docs must treat a local green `release_orchestrator.py --gates-only` snapshot as necessary but not sufficient; public release still needs live deploy/handoff truth and the required origin evidence.
- Client docs must not present RU-aware routing as fully shipped until the routing strategy layer, DNS split rules, and leak checks are actually verified.
- Client docs must describe only the currently shipped routing modes `Full tunnel` and `All except RU`; keep `Blocked only` as planned work until it exists in code and passes release verification.
- Client docs must distinguish current public download targets from release/store artifacts: app surfaces currently expose Android `Play` / `APK` / mirror and Windows `EXE` / mirror, while `AAB`, `MSIX`, and portable `ZIP` stay operator/store artifacts.
- Client docs must treat `external/client-fork/app/out/` as the retained canonical packaged bundle after a final green rerun and treat raw client `build/` and `dist/` outputs as disposable local artifacts.
- Client docs must describe `pokrov://` as the canonical public URI scheme and `pokrovvpn://` only as hidden compatibility handling where removal is not yet feasible.
- Client docs must describe the consumer onboarding choice `Optimize everything on this device` vs `Only selected apps` and treat split tunneling as a first-layer product feature.
- Client docs must describe persisted split-tunnel state through backend-owned `route_mode`, `selected_apps`, `requires_elevated_privileges`, and mirrored `route_policy.*` fields instead of implying that the choice is local-only UI state.
- Client docs must keep the public user-facing version line on `0.x.x-beta` and reject inherited visible strings such as `2.5.7 dev`.
- Client docs must keep raw subscription copy, edit, regenerate, or share actions out of the first-layer consumer path.
- Client docs must describe support as a real ticket-backed flow across app, cabinet, and admin; cabinet attachments belong to `/api/tickets/uploads`, and the client must not promise a live in-app chat that does not exist.
