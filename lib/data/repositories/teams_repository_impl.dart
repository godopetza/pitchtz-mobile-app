import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';
import '../datasources/mock_data.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  const TeamsRepositoryImpl();

  @override
  MyTeam getMyTeam() => MockData.myTeam;

  @override
  List<StandingRow> getStandings() => MockData.standings;

  @override
  List<Challenge> getChallenges() => MockData.challenges;

  @override
  List<JoinableTeam> getJoinableTeams() => MockData.joinable;

  @override
  FplInfo getFpl({required bool linked}) => FplInfo(linked: linked);
}
