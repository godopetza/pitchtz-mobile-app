import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/mock_data.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl();

  @override
  List<PaymentMethod> getMethods() => MockData.paymentMethods;
}
