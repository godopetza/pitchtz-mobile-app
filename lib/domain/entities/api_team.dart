/// API-shaped team returned by GET /teams and GET /teams/{id}.
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.tag,
    required this.city,
    required this.area,
    required this.bio,
    required this.badgeColor,
    required this.format,
    required this.recruiting,
    required this.needs,
    required this.memberCount,
    required this.openChallenges,
    required this.isCaptain,
    required this.membership,
  });

  final String id;
  final String name;
  final String tag;           // "SU" — short badge label
  final String city;
  final String area;
  final String bio;
  final String badgeColor;    // hex string, e.g. "#E53935"
  final String format;        // "5" | "7" | "futsal"
  final bool recruiting;
  final String needs;         // "Needs 2 players"
  final int memberCount;
  final int openChallenges;
  final bool isCaptain;
  final String? membership;   // "member" | "pending" | null
}

/// A player who is a member of a team.
class TeamMember {
  const TeamMember({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.role,
    required this.status,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
  final String role;    // "captain" | "member"
  final String status;  // "active" | "inactive"
}

/// A challenge issued by one team to any willing opponent.
class OpenChallenge {
  const OpenChallenge({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.teamTag,
    required this.badgeColor,
    required this.city,
    required this.area,
    required this.format,
    required this.note,
    required this.proposedAt,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String teamId;
  final String teamName;
  final String teamTag;
  final String badgeColor;
  final String city;
  final String area;
  final String format;
  final String note;
  final DateTime proposedAt;
  final String status;  // "open" | "accepted" | "cancelled"
  final DateTime createdAt;
}
