# PitchTZ Mobile — API Handover

Everything the mobile app needs is **live in production today**. Nothing in
this contract is planned or aspirational.

## Start here

1. **Play with the reference implementation first:**
   👉 **https://pitchtz.flutterai.dev**
   The client web exercises every flow in this contract end-to-end — booking
   with the 10-minute hold countdown, full and split (QR) mobile-money
   payments, Teams & open challenges, Google-Maps discovery, watch areas with
   the live match board, the shop, and reviews. If you're unsure how a flow
   should behave, the web app is the answer.

2. **Interactive API docs (Swagger UI):**
   👉 **https://pitchtz-production.up.railway.app/docs**
   Backed by [`openapi.yaml`](./openapi.yaml) in this folder (same file,
   version-controlled here for the mobile team).

## The contract in one minute

- **Base URL:** `https://pitchtz-production.up.railway.app/v1`
- **Envelope:** every response is `{ "success": bool, "data": …, "message": str }`;
  errors are `{ "success": false, "error": { "code", "message" } }`.
- **Money:** integer Tanzanian shillings. **Time:** RFC 3339 UTC — display in
  `Africa/Dar_es_Salaam` (+03:00).
- **Auth:** Bearer JWT (30-day). Email code: `POST /auth/email/start` →
  `POST /auth/email/verify`. Google/Apple: open `/auth/google/start` in a
  custom tab and intercept the redirect's `#oauth_token=`. Refresh a
  still-valid token past half-life with `POST /auth/refresh`.
- **Bookings are per pitch, never per venue.** `POST /bookings` holds the slot
  for 10 minutes (`hold_expires_at` — show a countdown); pay in full
  (`/bookings/{id}/pay`) or split into QR share links (`/bookings/{id}/split`).
  Poll the booking; the server settles payments even if callbacks are lost.
- **Slot grid** is built client-side from the venue's `open_hours` plus the
  `unavailable` windows from `/venues/{id}/availability`; `kind: processing`
  = someone is paying right now (render orange, not bookable).
- **Payment operators** are never hardcoded — fetch them from the Malipo
  gateway: `GET https://api.malipo.flutterai.dev/v1/providers/active`.
- **Fixtures** (`GET /v1/fixtures`) carry football + basketball with live
  scores; keep the "courtesy of LiveScore" credit visible.

## Feature map

| Feature | Endpoints | Web reference |
| --- | --- | --- |
| Discover venues & pitches | `/cities`, `/venues`, `/venues/{id}`, `…/availability`, `…/extras`, `…/reviews` | Home, `/results`, venue pages |
| Sign in | `/auth/email/*`, `/auth/google/start`, `/auth/me`, `/auth/refresh` | Top-right sign-in |
| Book & pay | `/bookings`, `…/pay`, `…/split`, `/pay/shares/{id}` | Venue page booking panel |
| Teams & challenges | `/teams*`, `/me/teams`, `/challenges*` | `/teams` |
| Match board | `/fixtures` | `/watch-parties` |
| Shop | `/shop/*` | `/shop` |
| City waitlist & venue leads | `/waitlist`, `/venues/enroll` | Homepage cities section, `/owners` |

Questions → Ben (PitchTZ founder).
