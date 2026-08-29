/// A rentable add-on offered by a venue (`GET /v1/venues/:id/extras`).
class VenueExtra {
  const VenueExtra({
    required this.id,
    required this.kind,
    required this.name,
    required this.priceTzs,
    required this.unit,
    required this.available,
  });

  final String id;
  final String kind; // e.g. "equipment"
  final String name; // e.g. "Football boots"
  final int priceTzs;
  final String unit; // e.g. "pair", "carton"
  final bool available;
}
