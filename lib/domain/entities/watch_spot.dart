class WatchSpot {
  const WatchSpot({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    this.latitude,
    this.longitude,
    required this.screens,
    required this.capacity,
    required this.entryTzs,
    required this.features,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String area;
  final String address;
  final double? latitude;
  final double? longitude;
  final int screens;
  final String capacity;
  final int entryTzs;
  final List<String> features;
  final String? photoUrl;

  bool get isFree => entryTzs == 0;
}
