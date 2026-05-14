import 'package:injectable/injectable.dart';
import '../../domain/models/home_content.dart';
import '../../domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeContent> getHomeContent() async {
    // Simular carga de datos (luego vendrá de Supabase)
    await Future.delayed(const Duration(milliseconds: 800));
    return const HomeContent(
      stories: [
        {'label': 'Look 1', 'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800'},
        {'label': 'Look 2', 'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800'},
        {'label': 'Look 3', 'image': 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800'},
        {'label': 'Look 4', 'image': 'https://images.unsplash.com/photo-1512690196252-741ef2ae7626?w=800'},
      ],
      services: [
        {'title': 'CORTE CLÁSICO', 'desc': 'Técnica artesanal con tijera y peine.', 'price': 'S/ 35.00', 'time': '45 min', 'img': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800'},
        {'title': 'BARBA LUXURY', 'desc': 'Ritual de toallas calientes y perfilado.', 'price': 'S/ 25.00', 'time': '30 min', 'img': 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800'},
        {'title': 'TRIMFLOW SPECIAL', 'desc': 'Diseño personalizado y asesoría.', 'price': 'S/ 45.00', 'time': '60 min', 'img': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800'},
        {'title': 'LIMPIEZA FACIAL', 'desc': 'Hidratación con mascarilla premium.', 'price': 'S/ 30.00', 'time': '30 min', 'img': 'https://images.unsplash.com/photo-1621605815841-2dddbaa20b2a?w=800'},
      ],
      products: [
        {
          'name': 'POMADA MATE',
          'desc': 'Fijación fuerte y acabado sin brillo para un look natural todo el día.',
          'price': 'S/ 45.00',
          'img': 'https://images.unsplash.com/photo-1590159443202-05459341777d?w=800'
        },
        {
          'name': 'ACEITE BARBA',
          'desc': 'Hidrata y suaviza el vello facial dándole un brillo natural y aroma premium.',
          'price': 'S/ 35.00',
          'img': 'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=800'
        },
        {
          'name': 'CERA PEINADO',
          'desc': 'Ideal para estilos clásicos con fijación flexible y fácil lavado.',
          'price': 'S/ 40.00',
          'img': 'https://images.unsplash.com/photo-1621605815841-2dddbaa20b2a?w=800'
        },
        {
          'name': 'AFTER SHAVE',
          'desc': 'Calma la irritación post-afeitado con un efecto refrescante instantáneo.',
          'price': 'S/ 30.00',
          'img': 'https://images.unsplash.com/photo-1634480251976-88062030061e?w=800'
        },
      ],
    );
  }

  @override
  Future<void> saveHomeContent(HomeContent content) async {
    // Simular guardado
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
