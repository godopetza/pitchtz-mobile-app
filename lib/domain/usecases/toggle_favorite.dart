import '../repositories/favorites_repository.dart';

/// Toggles a pitch's favourite status.
class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  void call(int pitchId) => _repository.toggle(pitchId);
}
