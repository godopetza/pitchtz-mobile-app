import '../entities/payment_method.dart';

/// Available payment methods.
abstract class PaymentRepository {
  List<PaymentMethod> getMethods();
}
