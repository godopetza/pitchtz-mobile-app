/// A pitch suggestion returned by the "Pitch AI" assistant.
class AiMatch {
  const AiMatch({
    required this.pitchId,
    required this.name,
    required this.time,
    required this.price,
    required this.distance,
    required this.imageId,
    required this.gradient1,
    required this.gradient2,
    required this.bookHour,
  });

  final int pitchId;
  final String name;
  final String time;
  final String price;
  final String distance;
  final String imageId;
  final int gradient1;
  final int gradient2;
  final int bookHour;
}
