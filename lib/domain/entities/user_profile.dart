/// The locally signed-in player.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    this.provider = 'phone',
  });

  final String name;
  final String phone; // e.g. "+255 754 123 456" (may be empty for OAuth)
  final String provider; // 'phone' | 'google' | 'apple'

  /// "Juma Mwakalinga" -> "JM" for the avatar chip.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
