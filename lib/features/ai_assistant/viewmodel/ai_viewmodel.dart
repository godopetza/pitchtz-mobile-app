import 'package:flutter/foundation.dart';

import '../../../domain/entities/ai_match.dart';
import '../../../domain/usecases/search_pitches_with_ai.dart';

class AiViewModel extends ChangeNotifier {
  AiViewModel(this._search);

  final SearchPitchesWithAi _search;

  bool _thinking = false;
  bool _done = false;
  List<AiMatch> _results = [];

  bool get thinking => _thinking;
  bool get done => _done;
  List<AiMatch> get results => _results;

  static const prompt =
      'Find me somewhere for 10 people tonight after 8 around Mikocheni, max 80k.';

  Future<void> start() async {
    _thinking = true;
    _done = false;
    notifyListeners();
    _results = await _search(prompt);
    _thinking = false;
    _done = true;
    notifyListeners();
  }
}
