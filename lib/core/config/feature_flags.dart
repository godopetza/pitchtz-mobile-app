/// Which product areas are backed by a live backend today.
///
/// Per the mobile handoff, only browsing/discovery is live. Player auth,
/// booking creation, payments, favorites sync, teams/leagues and the AI
/// assistant are `planned` (they 404 on the server), so they are gated behind
/// "coming soon" states until the backend ships them.
class FeatureFlags {
  FeatureFlags._();

  // Live
  static const bool discovery = true; // cities, venues, availability, reviews
  static const bool waitlist = true; // POST /v1/waitlist

  // Planned (backend returns 404 — keep off)
  static const bool playerAuth = false;
  static const bool booking = false;
  static const bool favorites = false;
  static const bool teams = false;
  static const bool aiAssistant = false;
  static const bool profileBookings = false;
}
