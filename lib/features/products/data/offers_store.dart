import 'package:flutter/foundation.dart';
import 'package:trim_flow/features/products/domain/models/promo_offer.dart';

/// Store en memoria (mock) de ofertas/promociones del banner de productos.
/// Singleton simple basado en ValueNotifier — sin backend ni DI.
class OffersStore {
  OffersStore._();
  static final OffersStore instance = OffersStore._();

  final ValueNotifier<List<PromoOffer>> offers =
      ValueNotifier<List<PromoOffer>>([]);

  int _seq = 0;

  String _newId() {
    _seq++;
    return 'offer-$_seq-${offers.value.length}';
  }

  void add({
    required String iconKey,
    required String eyebrow,
    required String title,
    required String caption,
  }) {
    offers.value = [
      ...offers.value,
      PromoOffer(
        id: _newId(),
        iconKey: iconKey,
        eyebrow: eyebrow,
        title: title,
        caption: caption,
      ),
    ];
  }

  void update(PromoOffer updated) {
    offers.value = [
      for (final o in offers.value) o.id == updated.id ? updated : o,
    ];
  }

  void remove(String id) {
    offers.value = offers.value.where((o) => o.id != id).toList();
  }
}
