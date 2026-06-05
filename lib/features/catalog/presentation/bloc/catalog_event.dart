import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_event.freezed.dart';

@freezed
abstract class CatalogEvent with _$CatalogEvent {
  const factory CatalogEvent.load() = CatalogLoadEvent;
}
