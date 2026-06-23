import 'package:trim_flow/features/reviews/domain/models/reviewable_reservation.dart';

abstract class ReviewsRepository {
  /// Citas completadas que el cliente aun puede reseñar (no reseñadas).
  Future<List<ReviewableReservation>> fetchReviewable({int windowDays = 30});

  /// Envia una reseña (rating 1-5 + comentario opcional). Lanza
  /// [ReviewException] con un mensaje amable si el backend la rechaza.
  Future<void> submit({
    required String reservationId,
    required int rating,
    String? comment,
  });
}

class ReviewException implements Exception {
  const ReviewException(this.message);
  final String message;
  @override
  String toString() => message;
}
