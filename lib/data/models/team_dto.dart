import '../../domain/entities/api_team.dart';
import 'json.dart';

class TeamDto {
  static Team fromJson(Map<String, dynamic> m) => Team(
        id: J.str(m, 'id'),
        name: J.str(m, 'name'),
        tag: J.str(m, 'tag'),
        city: J.str(m, 'city'),
        area: J.str(m, 'area'),
        bio: J.str(m, 'bio'),
        badgeColor: J.str(m, 'badge_color'),
        format: J.str(m, 'format'),
        recruiting: J.boolean(m, 'recruiting'),
        needs: J.str(m, 'needs'),
        memberCount: J.intVal(m, 'members'),
        openChallenges: J.intVal(m, 'open_challenges'),
        isCaptain: J.boolean(m, 'is_captain'),
        membership: J.strOrNull(m, 'membership'),
      );
}

class TeamMemberDto {
  static TeamMember fromJson(Map<String, dynamic> m) => TeamMember(
        userId: J.str(m, 'user_id'),
        name: J.str(m, 'name'),
        avatarUrl: J.strOrNull(m, 'avatar_url'),
        role: J.str(m, 'role'),
        status: J.str(m, 'status'),
      );
}

class ChallengeDto {
  static OpenChallenge fromJson(Map<String, dynamic> m) => OpenChallenge(
        id: J.str(m, 'id'),
        teamId: J.str(m, 'team_id'),
        teamName: J.str(m, 'team_name'),
        teamTag: J.str(m, 'team_tag'),
        badgeColor: J.str(m, 'badge_color'),
        city: J.str(m, 'city'),
        area: J.str(m, 'area'),
        format: J.str(m, 'format'),
        note: J.str(m, 'note'),
        proposedAt: J.date(m, 'proposed_at') ?? DateTime(0),
        status: J.str(m, 'status'),
        createdAt: J.date(m, 'created_at') ?? DateTime(0),
      );
}
