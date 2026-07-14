import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/services/food_catalog_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Food catalog loads 1000 items with images', () async {
    final catalog = await FoodCatalogService.instance.load();

    expect(catalog.foods.length, 1000);
    expect(catalog.categories, isNotEmpty);
    expect(catalog.sources.length, greaterThanOrEqualTo(2));

    final withImages = catalog.foods.where((food) {
      final url = food.imageUrl;
      return url != null && url.isNotEmpty;
    });
    expect(withImages.length, greaterThan(900));

    final salads = catalog.foods.where((food) => food.category == 'salads');
    expect(salads.length, greaterThan(10));
  });
}
