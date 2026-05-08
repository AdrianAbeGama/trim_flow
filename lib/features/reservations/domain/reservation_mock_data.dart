import 'package:core/core.dart';

class ReservationMockData {
  static const tenantId = 'barberia_alpha';

  static final centers = [
    const BarberCenter(
      tenantId: tenantId,
      id: '1',
      name: 'Cercado - Principal',
      location: 'Av. Principal 123',
      imageUrl:
          'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&q=80',
    ),
    const BarberCenter(
      tenantId: tenantId,
      id: '2',
      name: 'Cercado - Sucursal',
      location: 'Calle Secundaria 456',
      imageUrl:
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&q=80',
    ),
  ];

  static final services = [
    const Service(
      tenantId: tenantId,
      id: 's1',
      name: 'Corte Clásico',
      price: 35.0,
      durationInMinutes: 30,
      category: 'Cortes',
      isFeatured: true,
    ),
    const Service(
      tenantId: tenantId,
      id: 's2',
      name: 'Corte + Barba',
      price: 50.0,
      durationInMinutes: 45,
      category: 'Cortes',
      isFeatured: true,
    ),
    const Service(
      tenantId: tenantId,
      id: 's3',
      name: 'Ondulación',
      price: 80.0,
      durationInMinutes: 90,
      category: 'Ondulaciones',
      isFeatured: true,
    ),
    const Service(
      tenantId: tenantId,
      id: 's4',
      name: 'Perfilado de Cejas',
      price: 15.0,
      durationInMinutes: 15,
      category: 'Extras',
    ),
    const Service(
      tenantId: tenantId,
      id: 's5',
      name: 'Tinte Completo',
      price: 100.0,
      durationInMinutes: 120,
      category: 'Colorimetría',
    ),
    const Service(
      tenantId: tenantId,
      id: 's6',
      name: 'Hidratación Capilar',
      price: 60.0,
      durationInMinutes: 60,
      category: 'Colorimetría',
    ),
    const Service(
      tenantId: tenantId,
      id: 's7',
      name: 'Corte Infantil',
      price: 20.0,
      durationInMinutes: 20,
      category: 'Cortes',
    ),
  ];

  static final professionals = [
    const Professional(
      tenantId: tenantId,
      id: 'p1',
      name: 'Juan Pérez',
      specialties: ['Clásicos', 'Barba'],
      yearsOfExperience: 8,
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1618077360395-f3068be8e001?w=500&q=80',
    ),
    const Professional(
      tenantId: tenantId,
      id: 'p2',
      name: 'Carlos Díaz',
      specialties: ['Ondulaciones', 'Color'],
      yearsOfExperience: 5,
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1534308143481-c55f00be8bd7?w=500&q=80',
    ),
    const Professional(
      tenantId: tenantId,
      id: 'p3',
      name: 'Luis Gómez',
      specialties: ['Cortes Urbanos'],
      yearsOfExperience: 3,
      isAvailable: false,
      statusLabel: 'En servicio',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
    ),
    const Professional(
      tenantId: tenantId,
      id: 'p4',
      name: 'Marco Torres',
      specialties: ['Colorimetría', 'Tratamientos'],
      yearsOfExperience: 12,
      isAvailable: false,
      statusLabel: 'De baja',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&q=80',
    ),
  ];

  static const occupiedTimes = ['09:00', '10:30', '14:00', '15:30', '17:00'];
}
