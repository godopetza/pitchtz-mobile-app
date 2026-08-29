/// A city the app serves (`GET /v1/cities`). `status` is either "live" or
/// "waitlist"; waitlist cities show an ETA and a "Notify me" action.
class City {
  const City({
    required this.id,
    required this.name,
    required this.live,
    this.venueCount,
    this.eta,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final bool live;
  final int? venueCount; // not provided by the API today
  final String? eta; // from launch_eta, when on the waitlist
  final double? latitude;
  final double? longitude;
}
