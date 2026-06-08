import '../models/home_content.dart';

abstract class HomeRepository {
  Future<HomeContent> getHomeContent();
  Future<void> saveHomeContent(HomeContent content);
}
