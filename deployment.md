# Deployment

This document explains how the app is built and deployed to the tvOS App Store.

## Pipeline (Semaphore)

Deployment is automated on **Semaphore** — see `.semaphore/semaphore.yml`:

1. **Test** — runs the tvOS UI tests on every push.
2. **Deploy to TestFlight** — on merge to `main`, computes the next build number from
   TestFlight (`fastlane next_build_number`), then runs `fastlane beta` to build, sign
   and upload to TestFlight (internal + Open beta).
3. **Promote to App Store** — a manually-triggered promotion
   (`.semaphore/promote-app-store.yml`) that submits the already-uploaded build for
   App Store review via `fastlane promote_to_app_store`.

### Semaphore secrets

The pipeline reuses the secrets shared with **brunstadtv-app** and adds one
app-specific secret:

- `bccmedia-testflight-api` — **shared**. The App Store Connect API key
  (`BCCMEDIA_APP_STORE_CONNECT_*`). Account-level, so it works for `tv.brunstad.app`.
- `ios-signing-certs` — **shared**. The Apple Distribution `.p12`
  (`CERTIFICATE_P12_BASE64` + `CERTIFICATE_PASSWORD`). Same universal cert that signs
  the iOS app; the tvOS provisioning profile is fetched at build time via the API.
- `tvos-ci` — **app-specific**. Only the values nothing else provides:
  `LOGIN_API_KEY`, `AUTOLOGIN_HOST`, `RUDDER_WRITE_KEY`, `RUDDER_DATAPLANE_URL`,
  `NPAW_ACCOUNT_CODE`, `UNLEASH_URL`, `UNLEASH_CLIENT_KEY`, `SENTRY_DSN`.

Run `scripts/setup-semaphore-secrets.sh` to create/update `tvos-ci` (it verifies the
shared secrets exist and never duplicates them). The fastlane lanes fall back to a
local `fastlane/api_key.p8` / `fastlane/certificate.p12` when the shared env vars
aren't present, so manual local runs still work.

## Deploying manually (fallback)

Locally you can still run the fastlane lanes directly (requires
[fastlane](https://github.com/fastlane/fastlane) and Xcode):

- `fastlane beta` builds and uploads to TestFlight.
- `fastlane promote_to_app_store` (with `BUILD_NUMBER` set) submits a build for review.
