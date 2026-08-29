import '../entities/team.dart';

/// Teams, standings, open challenges and recruiting sides.
abstract class TeamsRepository {
  MyTeam getMyTeam();
  List<StandingRow> getStandings();
  List<Challenge> getChallenges();
  List<JoinableTeam> getJoinableTeams();
  FplInfo getFpl({required bool linked});
}
