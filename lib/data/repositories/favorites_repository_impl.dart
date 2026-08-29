import 'package:flutter/foundation.dart';

import '../../domain/repositories/favorites_repository.dart';

/// In-memory favourites store. Notifies listeners so favourite hearts stay in
/// sync everywhere. Seeded with pitches 2 & 5, matching the design's initial
/// `favIds:[2,5]`.
class FavoritesRepositoryImpl extends ChangeNotifier
    implements FavoritesRepository {
  final Set<int> _ids = {2, 5};

  @override
  Set<int> get favoriteIds => Set.unmodifiable(_ids);

  @override
  bool isFavorite(int pitchId) => _ids.contains(pitchId);

  @override
  void toggle(int pitchId) {
    if (!_ids.remove(pitchId)) _ids.add(pitchId);
    notifyListeners();
  }
}
