import 'package:flutter/widgets.dart';

/// Calcula el ancho (en pixeles fisicos) al que conviene DECODIFICAR una imagen
/// segun el tamano logico real en el que se muestra. Usarlo como `memCacheWidth`
/// (red) o `cacheWidth` (asset/file) evita decodificar fotos de 2000px en celdas
/// de 170px (ahorra mucha RAM y evita jank). Devuelve null si no se puede
/// determinar un ancho finito (en ese caso no se limita, sin regresion).
int? targetCacheWidth(BuildContext context, double? logicalWidth) {
  if (logicalWidth == null || !logicalWidth.isFinite || logicalWidth <= 0) {
    return null;
  }
  final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
  return (logicalWidth * dpr).round();
}
