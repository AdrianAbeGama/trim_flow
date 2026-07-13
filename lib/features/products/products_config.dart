/// Compra de productos como pedido independiente (carrito -> checkout -> pedido).
/// Deshabilitado: el backend no soporta pedidos independientes. Los productos se
/// venden dentro de una reserva (ver ReservationProductsSelector). La Tienda queda
/// como catalogo de solo lectura hasta que exista backend de pedidos.
final bool kProductPurchaseEnabled = false;
