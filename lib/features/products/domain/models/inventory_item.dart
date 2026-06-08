import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
abstract class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String name,
    @Default(0) int quantity,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
