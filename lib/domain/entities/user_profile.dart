/// The signed-in player, as returned by `GET /auth/me` / the auth grants.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.language = 'en',
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl; // Google/Apple picture when available
  final String language; // 'en' | 'sw' — the account's preferred language

  /// "Juma Mwakalinga" -> "JM" for the avatar chip.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
