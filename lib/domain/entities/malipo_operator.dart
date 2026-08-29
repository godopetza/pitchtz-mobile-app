class MalipoOperator {
  const MalipoOperator({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.color,
  });

  final String id;       // e.g. "MPESA_TZA"
  final String name;     // e.g. "M-Pesa"
  final String? logoUrl;
  final int color;       // ARGB int for Color(color)
}
