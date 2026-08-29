/// A mobile-money / card payment option.
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.mark,
    required this.brandColor,
  });

  final String id; // 'mpesa', 'airtel', ...
  final String name;
  final String subtitle; // masked number or "Visa · Mastercard"
  final String mark; // single-letter badge
  final int brandColor;
}
