/// Which product areas the app has built against the live backend so far.
///
/// Since the Aug 2026 handover the **whole contract is live server-side**
/// (auth, bookings & payments, teams, fixtures, shop, watch spots). Flags
/// below no longer track the backend — they track what this app has shipped:
/// flip one on once its screens talk to the real endpoints.
class FeatureFlags {
  FeatureFlags._();

  // Built against the live API
  static const bool discovery = true; // cities, venues, availability, reviews
  static const bool waitlist = true; // POST /v1/waitlist
  static const bool playerAuth = true; // email code + Google/Apple OAuth

  // Live server-side, app screens not wired yet (kept "coming soon")
  static const bool booking = false; // POST /bookings + pay/split/deposit
  static const bool favorites = false; // /me/favorite-teams
  static const bool teams = false; // /teams*, /challenges*
  static const bool aiAssistant = false; // no backend endpoint yet
  static const bool profileBookings = false; // GET /bookings
}
