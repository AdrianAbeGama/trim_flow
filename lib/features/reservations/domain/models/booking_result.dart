class BookingResult {
  final String reservationId;
  final String confirmationCode;
  final double originalPrice;
  final double finalPrice;
  final double discount;
  final bool couponApplied;
  final String? couponCode;

  const BookingResult({
    required this.reservationId,
    required this.confirmationCode,
    this.originalPrice = 0,
    this.finalPrice = 0,
    this.discount = 0,
    this.couponApplied = false,
    this.couponCode,
  });
}
