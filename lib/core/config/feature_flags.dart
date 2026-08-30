/// Which product areas the app has built against the live backend so far.
///
/// Since the Aug 2026 handover the **whole contract is live server-side**
/// (auth, bookings & payments, teams, fixtures, shop, watch spots). Flags
/// below no longer track the backend — they track what this app has shipped:
/// flip one on once its screens talk to the real endpoints.
class FeatureFlags {
  FeatureFlags._();

  // Built against the live API
  static const bool discovery = true;        // cities, venues, availability, reviews
  static const bool waitlist = true;         // POST /v1/waitlist
  static const bool playerAuth = true;       // email code + Google/Apple OAuth
  static const bool booking = true;          // NOW LIVE — POST /bookings + pay/split/deposit
  static const bool favorites = false;       // still in-memory (no backend fav-venues endpoint)
  static const bool teams = true;            // NOW LIVE — /teams*, /challenges*
  static const bool fixtures = true;         // NOW LIVE — /fixtures*, /fixtures/:id/detail
  static const bool shop = true;             // NOW LIVE — /shop/products, /shop/orders
  static const bool watchSpots = true;       // NOW LIVE — /watch-spots
  static const bool aiAssistant = false;     // no backend endpoint yet
  static const bool profileBookings = true;  // NOW LIVE — GET /bookings
}
