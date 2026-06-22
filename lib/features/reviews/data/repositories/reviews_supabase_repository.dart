import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/reviews/domain/models/reviewable_reservation.dart';
import 'package:trim_flow/features/reviews/domain/repositories/reviews_repository.dart';

/// Reseñas conectadas al backend del socio (RPCs bloque5, ADR-0015).
@LazySingleton(as: ReviewsRepository)
class ReviewsSupabaseRepository implements ReviewsRepository {
  ReviewsSupabaseRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReviewableReservation>> fetchReviewable(
      {int windowDays = 30}) async {
    final res = await _client.rpc('get_my_reviewable_reservations',
        params: {'p_window_days': windowDays, 'p_limit': 50});
    final list = (res as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((m) => ReviewableReservation.fromMap(m.cast<String, dynamic>()))
        .whereType<ReviewableReservation>()
        .toList();
  }

  @override
  Future<void> submit({
    required String reservationId,
    required int rating,
    String? comment,
  }) async {
    final clean = comment?.trim();
    try {
      await _client.rpc('submit_review', params: {
        'p_reservation_id': reservationId,
        'p_rating': rating,
        'p_comment': (clean == null || clean.isEmpty) ? null : clean,
      });
    } on PostgrestException catch (e) {
      throw ReviewException(_friendly(e.message));
    }
  }

  String _friendly(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('review_already_exists')) return 'Ya reseñaste esta cita.';
    if (s.contains('invalid_rating')) return 'Elige de 1 a 5 estrellas.';
    if (s.contains('comment_too_long')) return 'El comentario es muy largo.';
    if (s.contains('reservation_not_completed')) {
      return 'Esta cita aún no se completó.';
    }
    if (s.contains('not_reservation_owner')) {
      return 'No puedes reseñar esta cita.';
    }
    return 'No se pudo enviar la reseña. Intenta de nuevo.';
  }
}
