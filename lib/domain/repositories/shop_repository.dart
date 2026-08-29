import '../entities/shop_product.dart';

abstract class ShopRepository {
  Future<List<ShopProduct>> getProducts();
  Future<List<ShopProduct>> getVenueProducts(String venueId);
  Future<String> createOrder(List<ShopOrderItem> items); // returns orderId
  Future<Map<String, dynamic>> getOrder(String orderId);
  Future<void> payOrder({required String orderId, required String phone, required String operator});
}
