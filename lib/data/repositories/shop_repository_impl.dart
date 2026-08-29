import '../../core/network/api_client.dart';
import '../../domain/entities/shop_product.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/json.dart';
import '../models/shop_dto.dart';

/// Real implementation backed by the live `/shop` and `/venues` endpoints.
class ShopRepositoryImpl implements ShopRepository {
  const ShopRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<ShopProduct>> getProducts() async {
    final raw = await _api.getList('/shop/products');
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShopProductDto.fromJson)
        .toList();
  }

  @override
  Future<List<ShopProduct>> getVenueProducts(String venueId) async {
    final raw = await _api.getList('/venues/$venueId/products');
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShopProductDto.fromJson)
        .toList();
  }

  @override
  Future<String> createOrder(List<ShopOrderItem> items) async {
    final data = await _api.post(
      '/shop/orders',
      body: {
        'items': items
            .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
            .toList(),
      },
    );
    if (data is Map<String, dynamic>) {
      final id = J.strOrNull(data, 'order_id') ?? J.strOrNull(data, 'id');
      if (id != null && id.isNotEmpty) return id;
    }
    throw ArgumentError('createOrder: response contained no order id');
  }

  @override
  Future<Map<String, dynamic>> getOrder(String orderId) =>
      _api.getObject('/shop/orders/$orderId');

  @override
  Future<void> payOrder({
    required String orderId,
    required String phone,
    required String operator,
  }) =>
      _api.post(
        '/shop/orders/$orderId/pay',
        body: {'phone': phone, 'operator': operator},
      );
}
