class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.priceTzs,
    required this.imageUrl,
    required this.stock,
  });

  final String id;
  final String name;
  final String description;
  final int priceTzs;
  final String? imageUrl;
  final int stock;

  bool get inStock => stock > 0;
}

class ShopOrderItem {
  const ShopOrderItem({required this.productId, required this.quantity});
  final String productId;
  final int quantity;
}
