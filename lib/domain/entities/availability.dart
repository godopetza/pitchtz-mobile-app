/// A window during which a pitch is not bookable
/// (`GET /v1/venues/:id/availability`). The API returns *unavailable* windows;
/// free slots are computed client-side from the gaps.
class UnavailableWindow {
  const UnavailableWindow({
    required this.startsAt,
    required this.endsAt,
    required this.kind,
  });

  final DateTime startsAt;
  final DateTime endsAt;
  final String kind; // "booked" | "blocked"
}

/// Per-pitch availability for a venue on a given date/window.
class PitchAvailability {
  const PitchAvailability({
    required this.pitchId,
    required this.pitchName,
    required this.format,
    required this.basePriceTzs,
    required this.unavailable,
  });

  final String pitchId;
  final String pitchName;
  final String format;
  final int basePriceTzs;
  final List<UnavailableWindow> unavailable;
}
