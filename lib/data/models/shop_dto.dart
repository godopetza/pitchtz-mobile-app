import '../../domain/entities/shop_product.dart';
import 'json.dart';

class ShopProductDto {
  static ShopProduct fromJson(Map<String, dynamic> m) => ShopProduct(
        id: J.str(m, 'id'),
        name: J.str(m, 'name'),
        description: J.str(m, 'description'),
        priceTzs: J.intVal(m, 'price_tzs'),
        imageUrl: J.strOrNull(m, 'image_url'),
        stock: J.intVal(m, 'stock'),
      );
}
