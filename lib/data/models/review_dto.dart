import '../../domain/entities/review.dart';
import 'json.dart';

/// Maps a review JSON object to the [Review] entity.
class ReviewDto {
  static Review toEntity(Map<String, dynamic> m) => Review(
        stars: J.intVal(m, 'stars').clamp(0, 5),
        text: J.str(m, 'text'),
        tags: J.strList(m, 'tags'),
        date: Display.monthYear(J.date(m, 'created_at')),
        ownerReply: J.strOrNull(m, 'owner_reply'),
      );
}
