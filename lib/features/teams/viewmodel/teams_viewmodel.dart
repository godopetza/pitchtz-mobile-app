import 'package:flutter/foundation.dart';

import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/team.dart';
import '../../../domain/repositories/teams_repository.dart';

class TeamsViewModel extends ChangeNotifier {
  TeamsViewModel(this._repo, this._toast);

  final TeamsRepository _repo;
  final ToastController _toast;

  final Set<int> _challengesSent = {};
  final Set<String> _joinRequested = {};
  bool _fplLinked = false;

  MyTeam get myTeam => _repo.getMyTeam();
  List<StandingRow> get standings => _repo.getStandings();
  List<Challenge> get challenges => _repo.getChallenges();
  List<JoinableTeam> get joinable => _repo.getJoinableTeams();
  FplInfo get fpl => _repo.getFpl(linked: _fplLinked);

  bool isChallengeSent(int id) => _challengesSent.contains(id);
  void sendChallenge(int id) {
    if (_challengesSent.add(id)) notifyListeners();
  }

  bool isJoinRequested(String id) => _joinRequested.contains(id);
  void requestJoin(String id) {
    if (_joinRequested.add(id)) notifyListeners();
  }

  void tapFpl() {
    if (!_fplLinked) {
      _fplLinked = true;
      _toast.show('FPL team linked — check the Teams tab');
      notifyListeners();
    }
  }
}
