import '../../domain/entities/ai_match.dart';
import '../../domain/repositories/ai_repository.dart';

/// Placeholder implementation. The AI assistant is a `planned` backend feature
/// (no endpoint yet), so the UI is gated behind a "coming soon" state and this
/// returns nothing.
class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl();

  @override
  Future<List<AiMatch>> search(String query) async => const <AiMatch>[];
}
