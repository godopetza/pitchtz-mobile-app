import '../entities/ai_match.dart';

/// The "Pitch AI" assistant. [search] simulates the ~1.4s thinking delay and
/// returns matching pitches.
abstract class AiRepository {
  Future<List<AiMatch>> search(String query);
}
