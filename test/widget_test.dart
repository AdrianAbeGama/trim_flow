import 'package:flutter_test/flutter_test.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';

void main() {
  test('ProductCatalog model test', () {
    final catalog = ProductCatalog(id: 'c1', name: 'Cabello', isActive: true);

    expect(catalog.id, equals('c1'));
    expect(catalog.name, equals('Cabello'));
    expect(catalog.isActive, isTrue);

    final copied = catalog.copyWith(name: 'Barba', isActive: false);
    expect(copied.id, equals('c1'));
    expect(copied.name, equals('Barba'));
    expect(copied.isActive, isFalse);
  });
}
