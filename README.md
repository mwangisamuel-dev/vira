# VIRA — The Frontline of Hope

Emergency medical logistics platform for Kenya. One Flutter codebase,
three role-scoped experiences: **Rider** (hospitals/clinics/blood banks),
**Courier** (motorcycle riders), **Dispatch** (ops console, also the
responsive web build).

## Status

This is a scaffold, not a finished app. It was hand-written (no `flutter
create`/`flutter pub get`/`flutter analyze` were run — this sandbox has
no Flutter SDK installed) to get the architecture, design system, domain
models, and screen flow in place and reviewable. Expect to run `flutter
pub get` and fix the inevitable small issues (import paths, package
version pins) on first run in a real Flutter environment.

## Getting started

```bash
flutter pub get
flutter run
```

You'll need real values for:
- `ApiClient._baseUrlDev` / `_baseUrlProd` in `lib/core/network/api_client.dart`
- A Google Maps API key wired into `android/` and `ios/` config for
  `google_maps_flutter` (the live tracking and map widgets are currently
  placeholders pending this)
- Font files in `assets/fonts/` (Inter + JetBrains Mono families,
  referenced in `pubspec.yaml` but not bundled in this scaffold)

## Architecture

```
lib/
├── core/
│   ├── theme/         # ViraColors, ViraType, ViraTheme — the entire
│   │                    brand system as Flutter tokens
│   ├── network/        # ApiClient (Dio + REST), SocketService (WebSocket
│   │                    Gateway, topic-based pub/sub over one connection)
│   ├── state/          # ViraSession, authProvider (Riverpod)
│   ├── services/       # LocationService (background-capable GPS stream
│   │                    + offline queue via Hive)
│   └── router/         # ViraRouter — single role-based routing guard
├── features/
│   ├── auth/             # role select -> OTP -> session creation
│   ├── rider/             # hospital dashboard, cargo manifest builder
│   ├── courier/             # on-duty toggle, job feed, accept/navigate
│   ├── dispatch/              # ops console (responsive: mobile + wide web),
│   │                            critical-dispatch list reads activeTripsProvider
│   ├── trip/                    # providers/trip_providers.dart (tripProvider,
│   │                              activeTripsProvider) + shared TripStateTracker
│   │                              + live tracking screen, used identically by
│   │                              all 3 roles
│   └── wallet/                    # Payment/EarningsSummary models, providers
│                                    hitting ApiClient wallet endpoints, and
│                                    WalletScreen (earnings hero, M-Pesa payout
│                                    request, payment history) — routed at /wallet
└── shared/
    ├── models/          # CargoManifest, Trip, CustodyEvent, GeoPoint,
    │                       enums (ViraRole, PriorityTier, CargoType,
    │                       TripStatus, CustodyEventType)
    └── widgets/          # ViraMark, StatusPill, ViraCard, RouteTimeline
```

## Design decisions worth knowing about

**Cargo is the primary entity, not the rider.** `CargoManifest` exists
independently of `Trip` — a trip is just the movement record around a
manifest. This was a gap in the original architecture brief (the Trips
schema there modeled a person-carrying ride, not a medical payload) and
is the single biggest structural change from a generic ride-hailing
clone.

**Priority tiers (`PriorityTier`: critical/urgent/scheduled) drive match
SLA, not just display.** A CRITICAL manifest unmatched after 90s should
auto-escalate to Dispatch — that escalation logic lives server-side, but
the client model carries the SLA value so every screen (rider, courier,
dispatch) shows the same countdown.

**Chain of custody (`CustodyEvent`) is append-only and independent of
trip status.** This is what makes hospitals trust the platform over
informal arrangements, and it's the primary compliance artifact for
anything patient-adjacent under Kenya's Data Protection Act. Don't let
this collapse into just a status field on `Trip`.

**Location streaming assumes background failure is the default case,
not the exception.** `LocationService` queues failed pings in Hive and
retries on a timer — Nairobi traffic means screen-lock and dead zones
are the common case for a courier mid-ride, not edge cases. The
`flutter_background_geolocation` dependency in `pubspec.yaml` is the
production path; the `geolocator`-based foreground stream in this
scaffold is a fallback/testing path only.

**One router, hard role boundaries.** `ViraRouter`'s `redirect` is the
only enforcement point — a Rider session resolving `/courier/*` or
`/dispatch/*` gets bounced back to its own home, regardless of how it
got there (deep link, browser URL on the web Dispatch build, stale
bookmark).

**The brand mark matches the real logo/favicon files, not the original
brief.** The architecture brief described a left-wing/right-wing-slash
V construction; the actual `logo.png`/`favicons.png` supplied later show
a different two-tone V (navy left stroke, crimson right stroke with a
diagonal notch, cyan heartbeat pulse at the crossing) with the wordmark
"VIRA / CRITICAL INFRASTRUCTURE," not "THE FRONTLINE OF HOPE." `ViraMark`
(`lib/shared/widgets/vira_mark.dart`) was rebuilt as vector paths to
match the real files, with a `simplified` mode for the single-color
favicon form and an optional `statusDot` for the app-icon variant.

## Known gaps / next steps

- **No live backend** — `ApiClient` and `SocketService` are real implementations,
  and `tripProvider`/`activeTripsProvider` (in `lib/features/trip/providers/`)
  and the wallet providers (`lib/features/wallet/providers/`) are wired to call
  them for real. But since no backend exists yet to call, every one of these
  providers falls back to a representative demo value on error/timeout —
  search for `_demoTrip(` to find every fallback site. Once `/v1/trips`,
  `/v1/wallet/*`, and the WebSocket gateway are live, these fallbacks can be
  deleted with no further UI rewiring needed.
- Wallet screen (earnings hero, M-Pesa payout request, payment history) is
  built and routed at `/wallet`, reachable from the Courier home "KES Earned"
  stat card. It reads `earningsSummaryProvider`/`paymentHistoryProvider` and
  calls `requestPayoutProvider` — all real REST calls to endpoints that don't
  exist on a backend yet, so expect errors until that's stood up.
- No tests yet (`test/` directory created, empty).
- Google Maps integration is a placeholder Container in
  `live_tracking_screen.dart` pending API key provisioning.
- The brand mark (`ViraMark`) was rebuilt as vector CustomPaint to match the
  actual logo/favicon assets (two-tone navy/crimson V, diagonal notch, cyan
  pulse) rather than the earlier architecture brief's favicon description,
  which didn't match the real files. `assets/images/vira_logo.png` and
  `vira_favicons_reference.png` are kept as the source-of-truth reference and
  for exporting real app icons later — the in-app mark doesn't load them
  directly.
