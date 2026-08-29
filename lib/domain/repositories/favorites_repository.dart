import 'package:flutter/foundation.dart';

/// Tracks which pitches the user has favourited. Extends [Listenable] so any
/// screen (Explore, Detail, Favorites…) can react to changes app-wide.
abstract class FavoritesRepository implements Listenable {
  Set<int> get favoriteIds;
  bool isFavorite(int pitchId);
  void toggle(int pitchId);
}
