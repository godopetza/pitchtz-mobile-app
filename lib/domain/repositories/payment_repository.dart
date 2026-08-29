import '../entities/malipo_operator.dart';
import '../entities/payment_method.dart';

/// Available payment methods and live Malipo operator catalogue.
abstract class PaymentRepository {
  /// Returns the user's saved payment methods (static / mock list).
  List<PaymentMethod> getMethods();

  /// Fetches active payment operators from the Malipo gateway.
  /// Falls back to a hardcoded list when the network call fails.
  Future<List<MalipoOperator>> getOperators();
}
