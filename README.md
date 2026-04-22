# POKROV

`POKROV` is the consumer client bridge for the public
`Android + iOS + macOS + Windows` target used in this repository.

Current delivery reality:

- automatic app-first activation is the primary path on `Android + Windows`
- key-based delivery and redeem/recovery compatibility keep the bridge coherent
  across all four target platforms while backend and public-surface work catches up

Canonical documentation lives in:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

Key release facts:

- brand: `POKROV`
- public beta line: `0.9.0-beta`
- onboarding: app-first
- public target: `Android + iOS + macOS + Windows`
- automatic activation first track: `Android + Windows`
- key-based bridge track: `Android + iOS + macOS + Windows`
- trial: `5 days`
- Telegram reward: `+10 days`
- post-premium free tier: `5 GB / 30 days / 1 device` on `NL-free`
- support bot: `@pokrov_supportbot`
- feedback bot: `@pokrov_feedbackbot`
- official public channel: `@pokrov_vpn`
- main bot: `@pokrov_vpnbot`
- `swazist_bot` and `portal_service_bot` are officially disabled legacy usernames

Focused verification from this workspace:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

Public release and signing policy is documented in [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md).
