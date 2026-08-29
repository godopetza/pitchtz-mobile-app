# Pitch TZ — Architecture & Developer Guide

> A Flutter football‑pitch booking app for Dar es Salaam, Tanzania.
> Book pitches, pay with mobile money, split bills, join teams — built with
> **MVVM + Clean Architecture**, **Provider**, and **get_it**.

This document explains **what the app does**, **how it is structured**, **what every
folder and file is responsible for**, and **how data flows** from a tap on the screen
down to the (currently mocked) data layer and back.

---

## Table of contents

1. [At a glance](#1-at-a-glance)
2. [Tech stack](#2-tech-stack)
3. [The architecture (MVVM + Clean)](#3-the-architecture-mvvm--clean)
4. [The layers explained](#4-the-layers-explained)
5. [Folder-by-folder, file-by-file](#5-folder-by-folder-file-by-file)
6. [How data flows (with real examples)](#6-how-data-flows-with-real-examples)
7. [State management & reactivity](#7-state-management--reactivity)
8. [Dependency injection wiring](#8-dependency-injection-wiring)
9. [Navigation & the app flow](#9-navigation--the-app-flow)
10. [Theming & design tokens](#10-theming--design-tokens)
11. [Swapping mock data for a real backend](#11-swapping-mock-data-for-a-real-backend)
12. [Build, test & run](#12-build-test--run)

---

## 1. At a glance

Pitch TZ has **16 screens** built from the original Claude design:

Splash · Onboarding (3 slides) · Login · Explore (list + map) · Search Results
(list + map) · Pitch Detail · Booking Summary · Processing · Success · Scan & Pay ·
My Bookings · Favorites · Teams · Profile · Pitch AI.

Everything runs today on **mock repositories** — no backend required. The domain
contracts are shaped so a real API can be dropped in by replacing only the data layer.

**Design source:** `assets/design/Pitch TZ All Screens Standalone.html` (a self‑unpacking
bundle; the real markup lives in its embedded base64 manifest). Colours, spacing,
copy and mock data were transcribed from it.

---

## 2. Tech stack

| Concern | Choice | Why |
|---|---|---|
| UI | Flutter (Material 3) | Cross‑platform, matches the pixel design |
| State management | **provider** (`ChangeNotifier`) | Simple, idiomatic MVVM ViewModels |
| Dependency injection | **get_it** | Service locator to wire Clean Architecture layers |
| Typography | **google_fonts** (Plus Jakarta Sans) | Exact font from the design |
| HTTP client | **dio** | Interceptors + structured error handling for the REST API |
| Data | **Live PitchTZ API** (discovery) | `https://pitchtz-production.up.railway.app/v1` — see §11 |

Dependencies live in `pubspec.yaml`.

---

## 3. The architecture (MVVM + Clean)

The app combines the **MVVM** presentation pattern with **Clean Architecture**'s layer
separation. Dependencies always point **inward** — the UI depends on the domain, the
data layer implements the domain, and the domain depends on nothing.

```
        ┌──────────────────────────────────────────────────────────┐
        │                     PRESENTATION                          │
        │                                                           │
        │   View (Widget)  ◄──watch/notify──►  ViewModel            │
        │   "dumb" UI, no logic                (ChangeNotifier)     │
        │                                          │                │
        └──────────────────────────────────────────┼───────────────┘
                                                    │ calls
                                                    ▼
        ┌──────────────────────────────────────────────────────────┐
        │                       DOMAIN                              │
        │                                                           │
        │   Entities   ·   Repository interfaces   ·   Use cases    │
        │   (pure Dart, no Flutter, no packages)                    │
        └──────────────────────────────────────────┬───────────────┘
                                                    │ implemented by
                                                    ▼
        ┌──────────────────────────────────────────────────────────┐
        │                        DATA                               │
        │                                                           │
        │   Repository implementations  ◄─────  MockData source     │
        │   (today: in‑memory mock; tomorrow: HTTP/DB)              │
        └──────────────────────────────────────────────────────────┘

        Cross‑cutting:  core/ (theme, router, widgets, utils)   di/ (get_it)
```

**MVVM mapping**

- **Model** → `domain/entities` + `data` (the entities and where they come from).
- **View** → `features/<feature>/view/*.dart` (Flutter widgets, no business logic).
- **ViewModel** → `features/<feature>/viewmodel/*.dart` (`ChangeNotifier`s that hold
  screen state, call use‑cases/repositories, and expose ready‑to‑render getters).

**Golden rule:** a View never talks to a repository directly, and a ViewModel never
imports a Flutter widget. The View watches the ViewModel; the ViewModel calls the
domain; the domain is implemented by the data layer.

---

## 4. The layers explained

### Domain (`lib/domain`) — the core, framework‑free
Pure Dart. Defines **what** the app manipulates and **what operations exist**, with no
idea **how** they're implemented.

- **Entities** — plain data classes (`Pitch`, `Booking`, `Team`, `City`, …).
- **Repository interfaces** — abstract contracts (`PitchRepository`,
  `BookingRepository`, …). "Here's what I need; someone else provides it."
- **Use cases** — single‑purpose actions (`CreateBooking`, `ToggleFavorite`,
  `SearchPitchesWithAi`) and the pricing engine (`BookingCalculator`).

### Data (`lib/data`) — the implementation
Implements the domain's repository interfaces.

- **`datasources/mock_data.dart`** — the single source of truth for all mock content.
- **`repositories/*_impl.dart`** — classes that satisfy the domain contracts by
  reading from `MockData`. Replace these to go live; the rest of the app is untouched.

### Presentation (`lib/features`) — the screens
One folder per feature, each split into `view/` (widgets) and `viewmodel/`
(`ChangeNotifier`s), plus `widgets/` for feature‑local reusable pieces.

### Core (`lib/core`) — cross‑cutting building blocks
Theme, router, formatting utilities, the QR painter, the toast controller, and shared
widgets used everywhere (buttons, chips, turf image, map backdrop, steppers).

### DI (`lib/di`) — the wiring
`injection.dart` registers every repository, use‑case and ViewModel in `get_it` so the
router and widgets can resolve them without manual construction.

---

## 5. Folder-by-folder, file-by-file

```
lib/
├── main.dart                     App entry point: init DI, run PitchTzApp
├── app.dart                      Root widget: MaterialApp, providers, toast overlay
│
├── core/                         Cross-cutting building blocks (no business logic)
│   ├── router/
│   │   ├── route_names.dart      Route name constants (Routes.detail, …)
│   │   └── app_router.dart       onGenerateRoute: maps names → screens + their VMs
│   ├── theme/
│   │   ├── app_colors.dart       Every hex from the design, named
│   │   ├── app_typography.dart   Plus Jakarta Sans text styles (AppText.*)
│   │   ├── app_spacing.dart      Spacing / radius scale
│   │   └── app_theme.dart        Global ThemeData (Material 3)
│   ├── utils/
│   │   ├── formatters.dart       TSh currency, 12h time, per-player rounding
│   │   ├── qr_painter.dart       Deterministic decorative QR (CustomPainter)
│   │   └── toast_controller.dart App-wide toast (ChangeNotifier)
│   └── widgets/                  Reusable UI atoms
│       ├── buttons.dart          PrimaryButton, OutlineButton, CircleIconButton
│       ├── pill_chip.dart        PillChip, TintBadge
│       ├── quantity_stepper.dart  − value +  control
│       ├── segmented_toggle.dart Pill segmented control (List/Map, Upcoming/Past…)
│       ├── tap_scale.dart        Press-to-scale wrapper (design's active state)
│       ├── turf_image.dart       Unsplash photo over striped "mowed grass" gradient
│       └── map_backdrop.dart     Stylised static map + MapPin
│
├── domain/                       Pure Dart. The contracts & business rules.
│   ├── entities/
│   │   ├── pitch.dart            Pitch, Area
│   │   ├── review.dart           Review, PitchDetails
│   │   ├── time_slot.dart        TimeSlot, SlotGroup
│   │   ├── booking.dart          Booking, ExtraDef, PriceLine, BookingStatus
│   │   ├── payment_method.dart   PaymentMethod
│   │   ├── city.dart             City
│   │   ├── team.dart             MyTeam, TeamStat, StandingRow, Challenge, …
│   │   └── ai_match.dart         AiMatch
│   ├── repositories/             Abstract interfaces (implemented in data/)
│   │   ├── pitch_repository.dart
│   │   ├── favorites_repository.dart   (Listenable)
│   │   ├── booking_repository.dart     (Listenable)
│   │   ├── teams_repository.dart
│   │   ├── city_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── auth_repository.dart
│   │   └── ai_repository.dart
│   └── usecases/
│       ├── booking_calculator.dart     Pricing engine (totals, split, pay-now)
│       ├── create_booking.dart
│       ├── toggle_favorite.dart
│       └── search_pitches_with_ai.dart
│
├── data/                         Implements the domain contracts.
│   ├── datasources/
│   │   └── mock_data.dart        All hardcoded content (venues, teams, cities…)
│   └── repositories/
│       ├── pitch_repository_impl.dart        + slot availability/pricing logic
│       ├── favorites_repository_impl.dart    ChangeNotifier, seeded {2,5}
│       ├── booking_repository_impl.dart       ChangeNotifier, holds last booking
│       ├── teams_repository_impl.dart
│       ├── city_repository_impl.dart
│       ├── payment_repository_impl.dart
│       ├── auth_repository_impl.dart          stubbed OTP/OAuth delays
│       └── ai_repository_impl.dart            simulated 1.4s "thinking"
│
├── di/
│   └── injection.dart            get_it: register repos, use-cases, ViewModels
│
└── features/                     One folder per feature (view + viewmodel [+ widgets])
    ├── shell/                    Bottom-nav container hosting the 5 tabs
    │   ├── view/main_shell.dart
    │   └── viewmodel/shell_viewmodel.dart      current tab index (singleton)
    ├── onboarding/               Splash + 3 onboarding slides
    │   ├── view/splash_page.dart
    │   ├── view/onboarding_page.dart
    │   └── viewmodel/onboarding_viewmodel.dart
    ├── auth/                     Phone / OTP / Google / Apple login
    │   ├── view/login_page.dart
    │   └── viewmodel/login_viewmodel.dart
    ├── explore/                  Home (list + map), city & filter sheets
    │   ├── view/explore_page.dart
    │   ├── view/explore_map_view.dart
    │   ├── view/results_page.dart
    │   ├── viewmodel/explore_viewmodel.dart
    │   ├── viewmodel/results_viewmodel.dart
    │   └── widgets/pitch_cards.dart, explore_sheets.dart
    ├── pitch_detail/             Pitch detail + date/slot picker
    │   ├── view/detail_page.dart
    │   └── viewmodel/detail_viewmodel.dart
    ├── booking/                  Summary → Processing → Success → Scan & Pay
    │   ├── view/summary_page.dart, processing_page.dart, success_page.dart,
    │   │        scan_pay_page.dart
    │   └── viewmodel/booking_flow_viewmodel.dart   (shared singleton for the flow)
    ├── bookings/                 My bookings (Upcoming / Past)
    │   ├── view/bookings_page.dart
    │   └── viewmodel/bookings_viewmodel.dart
    ├── favorites/                Saved pitches (+ empty state)
    │   ├── view/favorites_page.dart
    │   └── viewmodel/favorites_viewmodel.dart
    ├── teams/                    Team, standings, challenges, join, FPL
    │   ├── view/teams_page.dart
    │   └── viewmodel/teams_viewmodel.dart
    ├── profile/                  Static profile / settings
    │   └── view/profile_page.dart
    └── ai_assistant/             "Pitch AI" chat + results
        ├── view/ai_page.dart
        └── viewmodel/ai_viewmodel.dart
```

### The most important files to know

| File | Role |
|---|---|
| `main.dart` | Boots DI, launches the app |
| `app.dart` | `MaterialApp`, root providers (booking flow + toast), toast overlay |
| `di/injection.dart` | Central wiring: what's a singleton vs. a factory |
| `core/router/app_router.dart` | Every route → screen + its ViewModel provider |
| `data/datasources/mock_data.dart` | All the content you'd later fetch from an API |
| `domain/usecases/booking_calculator.dart` | The pricing business rules |
| `features/booking/viewmodel/booking_flow_viewmodel.dart` | The whole booking flow's state |

---

## 6. How data flows (with real examples)

### The general pattern

```
User taps ──► View (widget) ──► ViewModel method ──► UseCase / Repository (domain)
                                                            │
                                                            ▼
                                            Repository impl reads MockData
                                                            │
              View rebuilds ◄── notifyListeners() ◄─────────┘
              (Provider's watch)   (state changed)
```

The View **reads** state through `context.watch<SomeViewModel>()` and **acts** by
calling ViewModel methods. The ViewModel mutates its private state, then calls
`notifyListeners()`, which tells Provider to rebuild any widget watching it.

### Example A — Toggling a favourite (shows app‑wide reactivity)

1. On the Explore screen you tap a card's heart.
2. `ExplorePage` calls `vm.toggleFavorite(pitch.id)`.
3. `ExploreViewModel` forwards to `FavoritesRepository.toggle(id)`.
4. `FavoritesRepositoryImpl` (a `ChangeNotifier`) flips the id in its `Set<int>` and
   calls `notifyListeners()`.
5. **Every** ViewModel that subscribed to the favorites repo in its constructor
   (`Explore`, `Results`, `Detail`, `Favorites`) receives the change and re‑emits, so
   the heart updates **everywhere at once** — the Favorites tab, the detail screen, the
   results list — with no manual plumbing.

```
Explore heart tap
   └─ ExploreViewModel.toggleFavorite(id)
        └─ FavoritesRepository.toggle(id)            [data, ChangeNotifier]
             └─ notifyListeners()
                  ├─► ExploreViewModel   → UI updates
                  ├─► FavoritesViewModel → Favorites tab updates
                  └─► DetailViewModel    → detail heart updates
```

### Example B — Booking a pitch (a multi‑screen flow)

The booking flow spans four screens but **one shared ViewModel** (`BookingFlowViewModel`,
a get_it singleton provided at the app root), so state survives navigation.

```
DetailPage
  • DetailViewModel tracks date + consecutive slot selection, computes pitchFee.
  • "Continue" → getIt<BookingFlowViewModel>().start(pitch, pitchFee, date, time…)
  • Navigator.push(summary)

SummaryPage  (watches BookingFlowViewModel)
  • Add extras / tips / repeat / payment plan / method / split.
  • BookingCalculator (use case) recomputes total, pay-now, per-player share live.
  • "Pay" → Navigator.push(processing)

ProcessingPage
  • Waits 2.2s → BookingFlowViewModel.confirm()
        └─ CreateBooking use case → BookingRepository.createBooking(...)
             └─ stores the booking, notifyListeners()   [Bookings tab will refresh]
  • Navigator.pushReplacement(success)

SuccessPage  (watches BookingFlowViewModel)
  • Shows the booking code, split QR, share panel.
  • "View my bookings" → ShellViewModel.setIndex(1) + pop back to the shell.
```

`BookingCalculator` is where the money rules live (kept out of the UI):

```
total     = pitchFee + extras + tips + service fee (3,000)
payNow    = ceil(total / 2 / 500) * 500          // 50% now, rounded to 500
perPlayer = ceil(amount / players / 100) * 100    // split, rounded to 100
```

### Example C — Reading a list (Explore "Available tonight")

```
ExplorePage.build
  └─ context.watch<ExploreViewModel>()
       └─ vm.tonight            (getter)
            └─ PitchRepository.getTonight()
                 └─ returns curated List<Pitch> from MockData.venues
  └─ renders a TonightCard per pitch
```

Pure reads don't need `notifyListeners()` — they resolve on build. Notifications are
only for **changes** (favourites, new bookings, tab switches, async AI results).

---

## 7. State management & reactivity

- **ViewModels are `ChangeNotifier`s.** They hold private mutable state and expose
  getters + intent methods. After a mutation they call `notifyListeners()`.
- **Views subscribe with Provider:**
  - `context.watch<VM>()` — rebuild when the VM notifies (use in `build`).
  - `context.read<VM>()` — one‑off call, no rebuild (use in tap handlers).
- **Repositories can be `Listenable` too.** `FavoritesRepository` and
  `BookingRepository` are `ChangeNotifier`s. ViewModels that care subscribe in their
  constructor and re‑broadcast, which is how one action updates many screens.
- **Singleton vs. factory state (see DI):**
  - *Singletons* (shared): `BookingFlowViewModel` (spans the booking flow),
    `ShellViewModel` (current tab, settable from the Success screen), and the
    favorites/booking repositories.
  - *Factories* (fresh per screen): `Explore`, `Results`, `Detail`, `Bookings`,
    `Favorites`, `Teams`, `Ai`, `Login`, `Onboarding` ViewModels.

Each ViewModel that subscribes to a repository **removes its listener in `dispose()`**
to avoid leaks.

---

## 8. Dependency injection wiring

`di/injection.dart` is called once from `main()` via `configureDependencies()`.

```dart
// Repositories — singletons (shared, hold state)
getIt.registerLazySingleton<PitchRepository>(() => const PitchRepositoryImpl());
getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl());
getIt.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl());
// …teams, city, payment, auth, ai…

// Use cases — depend on repositories
getIt.registerLazySingleton(() => const BookingCalculator());
getIt.registerLazySingleton(() => CreateBooking(getIt()));       // resolves BookingRepository
getIt.registerLazySingleton(() => ToggleFavorite(getIt()));
getIt.registerLazySingleton(() => SearchPitchesWithAi(getIt()));

// ViewModels — factories (fresh per screen), except the two shared singletons
getIt.registerFactory(() => ExploreViewModel(getIt(), getIt(), getIt(), getIt()));
getIt.registerLazySingleton(() => BookingFlowViewModel(getIt(), getIt(), getIt(), getIt()));
getIt.registerLazySingleton(() => ShellViewModel());
```

`getIt()` inside a registration resolves the parameter **by type** from the container, so
constructor order defines which dependency is injected. Screens obtain their ViewModel in
the router:

```dart
case Routes.detail:
  final pitchId = settings.arguments as int? ?? 1;
  return ChangeNotifierProvider(
    create: (_) => getIt<DetailViewModel>()..load(pitchId),
    child: const DetailPage(),
  );
```

---

## 9. Navigation & the app flow

Routes are named constants (`core/router/route_names.dart`) and resolved by
`AppRouter.onGenerateRoute`. The five primary tabs live inside `MainShell`
(an `IndexedStack`, so tab state is preserved); everything else is **pushed** on top.

```
Splash (1.8s)
  └─► Onboarding (3 slides)
        ├─ Skip ─────────────► Home shell
        └─► Login
              ├─ phone → OTP → Verify ─► Home shell   (+ "Karibu" toast)
              ├─ Google / Apple ───────► Home shell   (+ toast)
              └─ Skip for now ─────────► Home shell

Home shell (bottom nav, IndexedStack)
  ├─ Explore ──┬─ search / See all / area ─► Results (list ⇄ map)
  │            ├─ map preview ─────────────► Explore map (in-tab)
  │            ├─ Ask Pitch AI ────────────► AI
  │            ├─ pitch card ──────────────► Pitch Detail
  │            ├─ avatar ───────────────────► Profile tab
  │            └─ city ▼ / filter ─────────► bottom sheets
  ├─ Bookings (Upcoming / Past)
  ├─ Teams (standings, challenges, join, FPL)
  ├─ Favorites (list or empty state)
  └─ Profile (settings, language, version)

Pitch Detail ─ pick date + consecutive slots ─► Continue
  └─► Summary ─ extras/tips/plan/method/split ─► Pay
        └─► Processing (2.2s, confirms booking)
              └─► Success ─ share / split / QR
                    ├─ "Preview what they see" ─► Scan & Pay
                    └─ "View my bookings" ─────► Bookings tab
```

Transitions: fade for splash/home/processing/success, slide for pushed screens
(`AppRouter._fade` / `._slide`).

**App‑wide toast:** `ToastController` (root provider) drives a floating message rendered
by `_ToastOverlay` in `app.dart`, sitting above the whole navigator — used for
"Signed in", "City coming soon", "FPL linked", etc.

---

## 10. Theming & design tokens

All visual constants come from `core/theme`:

- **`app_colors.dart`** — brand `#0E3B2C` (pitch green), `#C9F24E` (lime),
  `#F5F4EF` (cream), `#171B18` (ink), `#6E756F` (muted), success `#2E7D46` / `#EAF2E4`,
  plus map, payment‑brand and accent colours.
- **`app_typography.dart`** — Plus Jakarta Sans via `google_fonts`, exposed as
  `AppText.h1/h2/h3/title/body/…`.
  ⚠️ **These are runtime getters, so they can't be used inside `const` widgets** — wrap
  such `Text`/`Padding` without `const`.
- **`app_spacing.dart`** — spacing and corner‑radius scale.

Screens are largely styled inline to match the bespoke design; the theme provides sane
defaults (fonts, colour scheme, no ripple splash).

The turf artwork (`core/widgets/turf_image.dart`) reproduces the design's
`url(unsplash) , repeating-linear-gradient(...)`: an Unsplash photo fades in over a
painted two‑tone "mowed grass" gradient that shows while loading or offline.

---

## 11. Backend integration (live)

The app is wired to the **real PitchTZ backend** for discovery, per
`assets/docs/mobile_handoff.md` and the Postman collection in `api.json`.

**Base URL:** `https://pitchtz-production.up.railway.app/v1` (override with
`--dart-define=PITCHTZ_API_BASE=http://localhost:8080/v1`). All responses use the
envelope `{ success, data, message }` / `{ success: false, error: { code, message } }`,
unwrapped centrally by `core/network/api_client.dart` into typed `ApiException`s.

### What's live (wired to the API)

| Endpoint | Used by |
|---|---|
| `GET /v1/cities` | City sheet (live + waitlist cities) |
| `GET /v1/venues` | Explore, Results, map pins (real lat/lng, bbox‑projected) |
| `GET /v1/venues/:id` | Pitch detail (amenities, rules, photos, pitches, extras) |
| `GET /v1/venues/:id/availability?date=` | Detail slot grid — the API returns **unavailable windows**; free slots are computed client‑side from the gaps |
| `GET /v1/venues/:id/reviews` | Detail reviews + aggregated tag chips |
| `GET /v1/venues/:id/extras` | Detail "Available extras" |
| `POST /v1/waitlist` | "Notify me" on waitlist cities (rate‑limited 5/min/IP) |

**Strategy: live‑only.** No mock fallback — real loading / empty / error states
(`core/widgets/status_views.dart`). Production currently has minimal seeded content,
so empty states are expected and honest.

### What's gated ("coming soon")

Per the handoff, these are `planned` on the backend (they 404 today), so the UI gates
them via `core/config/feature_flags.dart` + `StatusView.comingSoon`:

- **Player auth** — Login screen explains accounts are coming; browsing works signed‑out.
- **Booking creation / payments** — Detail keeps the live slot‑checker, but the CTA
  says "Booking coming soon" (the full summary→pay flow remains in `features/booking/`,
  compiled but unreachable, ready for when `POST /bookings` ships).
- **Bookings / Teams / Favorites tabs** and **Pitch AI** — coming‑soon screens.

### Data-layer shape

- `core/network/` — `ApiConfig`, `ApiClient` (dio + envelope unwrap), `ApiException`.
- `data/models/` — DTO mappers (`VenueDto`, `CityDto`, `ReviewDto`, `AvailabilityDto`)
  built on `J` (`json.dart`), which reads **snake_case first, then camelCase**, since
  the spec examples and handoff doc disagree. Covered by `test/api_mapping_test.dart`
  against verbatim production payloads.
- Venue IDs are **string UUIDs** end‑to‑end; venue photos come from `photos[].url`
  with the striped‑turf gradient as fallback (most venues have no photos yet).

When a `planned` endpoint goes live: flip its `FeatureFlags` entry, implement the repo
against `ApiClient`, and un‑gate the screen — the ViewModels and views are already
shaped for it.

---

## 12. Build, test & run

```bash
flutter pub get          # install dependencies

flutter run              # run on a connected device / emulator
flutter run -d chrome    # run in the browser

flutter analyze          # static analysis (currently: no issues)
flutter test             # unit tests (Formatters + BookingCalculator)
flutter build web        # full release compile
```

**Note:** pitch photos load from Unsplash (same IDs as the design) over the turf‑gradient
fallback, so the first paint of images needs a network connection — everything else runs
fully offline on mock data.

---

### Quick mental model

> **View** shows state and forwards taps → **ViewModel** holds state and calls the
> **domain** → **domain** contracts are fulfilled by the **data** layer → a change
> `notifyListeners()` → Provider rebuilds the View. **get_it** wires it all together;
> **core** supplies the look and the plumbing.
