import '../entities/ai_match.dart';
import '../repositories/ai_repository.dart';

/// Runs a natural-language pitch search via the AI assistant.
class SearchPitchesWithAi {
  const SearchPitchesWithAi(this._repository);

  final AiRepository _repository;

  Future<List<AiMatch>> call(String query) => _repository.search(query);
}
