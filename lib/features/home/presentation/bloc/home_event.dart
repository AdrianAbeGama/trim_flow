import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/home_content.dart';

part 'home_event.freezed.dart';

@freezed
abstract class HomeEvent with _$HomeEvent {
  const factory HomeEvent.load() = LoadHomeEvent;
  const factory HomeEvent.toggleEditMode() = ToggleHomeEditMode;
  const factory HomeEvent.updateContent(HomeContent content) = UpdateHomeContent;
  
  const factory HomeEvent.updateHero({
    String? title,
    String? subtitle,
    String? imageUrl,
    String? tag1,
    String? tag2,
  }) = UpdateHomeHero;

  const factory HomeEvent.updateAboutUs({
    String? title,
    String? text,
    String? imageUrl,
    String? videoUrl,
  }) = UpdateHomeAboutUs;

  const factory HomeEvent.updateSocialLink(String platform, String url) = UpdateHomeSocialLink;
  const factory HomeEvent.updateLocation(int index, Map<String, String> location) = UpdateHomeLocation;

  const factory HomeEvent.addStory(Map<String, String> story) = AddHomeStory;
  const factory HomeEvent.removeStory(int index) = RemoveHomeStory;
  
  const factory HomeEvent.addService(Map<String, String> service) = AddHomeService;
  const factory HomeEvent.updateService(int index, Map<String, String> service) = UpdateHomeService;
  const factory HomeEvent.removeService(int index) = RemoveHomeService;

  const factory HomeEvent.addProduct(Map<String, String> product) = AddHomeProduct;
  const factory HomeEvent.updateProduct(int index, Map<String, String> product) = UpdateHomeProduct;
  const factory HomeEvent.removeProduct(int index) = RemoveHomeProduct;
}
