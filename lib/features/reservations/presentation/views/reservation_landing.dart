import 'dart:async';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_ticket_modal.dart';

/// Landing de "Tu Cita" cuando el cliente YA tiene su reserva: una sola cita a
/// la vez, mostrada abierta (sin cajas de fondo) con cuenta regresiva en vivo,
/// barbero, sede (con acceso a mapa) y acciones. La cancelacion la gestiona la
/// barberia.
class ReservationLanding extends StatelessWidget {
  const ReservationLanding({super.key, required this.appointments, required this.onNew});

  final List<Reservation> appointments;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final cita = appointments.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PremiumPill(icon: Icons.event_available_rounded, label: 'TU PRÓXIMA CITA'),
                    const SizedBox(height: 22),
                    Text(
                      'Tu',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cita',
                      style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text(
                          'Todo listo para tu próximo corte',
                          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AppointmentDetails(reservation: cita)
                      .animate()
                      .fadeIn(delay: 160.ms, duration: 500.ms)
                      .slideY(begin: 0.06, end: 0, delay: 160.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentDetails extends StatelessWidget {
  const _AppointmentDetails({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasDate = reservation.date != null;
    final dateLine = hasDate
        ? _cap(DateFormat("EEEE d 'de' MMMM", 'es').format(reservation.date!))
        : 'Fecha por confirmar';
    final timeStr = reservation.time ?? '—';
    final service = reservation.services.isNotEmpty ? reservation.services.first.name : 'Servicio';
    final extraServices = reservation.services.length - 1;
    final duration = reservation.totalDurationInMinutes;
    final subtitle = [
      if (extraServices > 0) '+$extraServices servicio${extraServices > 1 ? 's' : ''}',
      if (duration > 0) '$duration min',
    ].join('  ·  ');
    final barber = reservation.professional;
    final barberName = barber?.name ?? 'Máxima disponibilidad';
    final center = reservation.center;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado: cuenta regresiva en vivo + confirmada
        _CountdownBar(date: reservation.date, time: reservation.time),
        const SizedBox(height: 24),
        // Hora gigante + fecha
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: GoogleFonts.inter(fontSize: 56, fontWeight: FontWeight.w900, color: gold, height: 0.95, letterSpacing: -2.5),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  dateLine,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85), letterSpacing: -0.3, height: 1.2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Servicio + total
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.6, height: 1.1),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('TOTAL',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.35), letterSpacing: 1.4)),
                const SizedBox(height: 3),
                Text('S/ ${reservation.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 26),
        _hairline(),
        const SizedBox(height: 20),
        // Barbero
        Row(
          children: [
            AvatarPremium(displayName: barberName, photoUrl: barber?.imageUrl, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TU BARBERO',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: gold.withValues(alpha: 0.85), letterSpacing: 1.4)),
                  const SizedBox(height: 3),
                  Text(barberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                  if (barber != null && barber.yearsOfExperience > 0) ...[
                    const SizedBox(height: 1),
                    Text('${barber.yearsOfExperience} años de experiencia',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (center != null) ...[
          const SizedBox(height: 20),
          _hairline(),
          const SizedBox(height: 20),
          _SedeLocation(center: center),
        ],
        const SizedBox(height: 24),
        _hairline(),
        const SizedBox(height: 18),
        // Acciones (sin cajas)
        _Actions(reservation: reservation),
        const SizedBox(height: 28),
        // Nota
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Solo puedes tener una cita a la vez. Si no podrás asistir, avísale a la barbería.',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.38), fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.45),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hairline() => Container(height: 1, color: Colors.white.withValues(alpha: 0.06));

  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

bool _mapsHybridSet = false;

/// Fuerza "Hybrid Composition" en Android. El modo por defecto (TLHC) renderiza
/// el mapa en negro/parcial en varios dispositivos; esto lo corrige. Se llama
/// una vez antes de crear cualquier GoogleMap.
void _ensureMapsHybridComposition() {
  if (_mapsHybridSet) return;
  _mapsHybridSet = true;
  final platform = GoogleMapsFlutterPlatform.instance;
  if (platform is GoogleMapsFlutterAndroid) {
    platform.useAndroidViewSurface = true;
  }
}

/// Sede con mapa de Google colapsable (solo Android). El mapa esta oculto por
/// defecto: solo se construye cuando el usuario lo abre, asi no cuenta como
/// "uso" en Google hasta que lo abren. Pin personalizado minimalista en el
/// color del tenant. Coordenadas de demo (Arequipa) mientras el backend no
/// envia lat/lng por sede.
class _SedeLocation extends StatefulWidget {
  const _SedeLocation({required this.center});

  final BarberCenter center;

  @override
  State<_SedeLocation> createState() => _SedeLocationState();
}

class _SedeLocationState extends State<_SedeLocation> {
  static const _coords = LatLng(-16.4090, -71.5375);

  bool _open = false;
  bool _loading = false;
  BitmapDescriptor? _pin;

  @override
  void initState() {
    super.initState();
    _ensureMapsHybridComposition();
  }

  Future<void> _toggle() async {
    if (_open) {
      setState(() => _open = false);
      return;
    }
    if (_pin == null) {
      if (_loading) return;
      setState(() => _loading = true);
      final pin = await _buildPin(context.primaryGold);
      if (!mounted) return;
      setState(() {
        _pin = pin;
        _loading = false;
        _open = true;
      });
    } else {
      setState(() => _open = true);
    }
  }

  Future<BitmapDescriptor> _buildPin(Color color) async {
    const double scale = 3;
    const double w = 34 * scale;
    const double h = 46 * scale;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final cx = w / 2;
    const double r = 15 * scale;
    final headCenter = Offset(cx, r + 3 * scale);

    final fill = Paint()
      ..isAntiAlias = true
      ..color = color;
    final tri = Path()
      ..moveTo(cx - r * 0.6, headCenter.dy + r * 0.45)
      ..lineTo(cx, h - 2 * scale)
      ..lineTo(cx + r * 0.6, headCenter.dy + r * 0.45)
      ..close();
    canvas.drawPath(tri, fill);
    canvas.drawCircle(headCenter, r, fill);
    canvas.drawCircle(
      headCenter,
      r,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * scale,
    );
    canvas.drawCircle(
      headCenter,
      r * 0.38,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.white,
    );

    final img = await recorder.endRecording().toImage(w.round(), h.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List(), imagePixelRatio: scale);
  }

  Set<Marker> _markers() => _pin == null
      ? const <Marker>{}
      : {Marker(markerId: const MarkerId('sede'), position: _coords, icon: _pin!)};

  Future<void> _openMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_coords.latitude},${_coords.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openFullscreen() async {
    // Solo un GoogleMap vivo a la vez: cerramos el inline (libera su vista
    // nativa) antes de abrir el de pantalla completa.
    final wasOpen = _open;
    if (_open) setState(() => _open = false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenMap(coords: _coords, pin: _pin, title: widget.center.name),
      ),
    );
    if (!mounted) return;
    if (wasOpen) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _open = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final center = widget.center;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumPressable(
          pressedScale: 0.99,
          onTap: _toggle,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 16),
                child: Icon(Icons.place_rounded, size: 22, color: gold.withValues(alpha: 0.85)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                    if (center.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(center.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: gold.withValues(alpha: 0.7)),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_open ? 'Ocultar' : 'Ver mapa',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: gold, letterSpacing: -0.1)),
                    const SizedBox(width: 3),
                    AnimatedRotation(
                      turns: _open ? 0.25 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.expand_more_rounded, size: 20, color: gold),
                    ),
                  ],
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          // Mapa estático (lite): no captura el scroll de la página.
                          child: IgnorePointer(
                            child: GoogleMap(
                              initialCameraPosition: const CameraPosition(target: _coords, zoom: 15),
                              liteModeEnabled: true,
                              markers: _markers(),
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              compassEnabled: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MapActionBtn(
                              icon: Icons.directions_rounded,
                              label: 'Abrir en Maps',
                              onTap: _openMaps,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MapActionBtn(
                              icon: Icons.fullscreen_rounded,
                              label: 'Pantalla completa',
                              onTap: _openFullscreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _MapActionBtn extends StatelessWidget {
  const _MapActionBtn({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: gold),
            const SizedBox(width: 7),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapa a pantalla completa, interactivo (pan/zoom). Aquí sí se permiten gestos.
/// El GoogleMap se crea DESPUÉS de la transición de ruta: si se crea durante la
/// animación, el platform view se renderiza en negro / con tamaño incorrecto.
class _FullscreenMap extends StatefulWidget {
  const _FullscreenMap({required this.coords, required this.pin, required this.title});

  final LatLng coords;
  final BitmapDescriptor? pin;
  final String title;

  @override
  State<_FullscreenMap> createState() => _FullscreenMapState();
}

class _FullscreenMapState extends State<_FullscreenMap> {
  bool _ready = false;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  Future<void> _openInMaps() async {
    final c = widget.coords;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${c.latitude},${c.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toggleLayer() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coords = widget.coords;
    final pin = widget.pin;
    final gold = context.primaryGold;
    final isSat = _mapType == MapType.satellite;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _ready
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(target: coords, zoom: 16),
                    mapType: _mapType,
                    markers: pin == null
                        ? {Marker(markerId: const MarkerId('sede'), position: coords)}
                        : {Marker(markerId: const MarkerId('sede'), position: coords, icon: pin)},
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
                    },
                  )
                : Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: gold),
                    ),
                  ),
          ),
          // Barra superior: atrás + título + capas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _circleBtn(Icons.arrow_back_rounded, () => Navigator.of(context).pop()),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Text(widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botón inferior: abrir en Google Maps + capas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: PremiumPressable(
                        pressedScale: 0.97,
                        onTap: _openInMaps,
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('Abrir en Google Maps',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: premiumOnAccent(gold), letterSpacing: -0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PremiumPressable(
                      pressedScale: 0.95,
                      onTap: _toggleLayer,
                      child: Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSat ? gold.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSat ? gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: FaIcon(
                          isSat ? FontAwesomeIcons.solidMap : FontAwesomeIcons.earthAmericas,
                          color: isSat ? gold : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {bool active = false, Color? activeColor}) {
    final accent = activeColor ?? Colors.white;
    return PremiumPressable(
      pressedScale: 0.92,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: active ? accent.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: active ? accent : Colors.white, size: 20),
      ),
    );
  }
}

/// Contador en vivo con segundos (HH:MM:SS) + línea que baja a medida que se
/// acerca la cita y se pone roja en los últimos 15 minutos.
class _CountdownBar extends StatefulWidget {
  const _CountdownBar({required this.date, required this.time});

  final DateTime? date;
  final String? time;

  static const _urgentColor = Color(0xFFFF5A5A);
  static const _window = Duration(hours: 24);

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime? get _target {
    final d = widget.date;
    if (d == null) return null;
    var hh = 0;
    var mm = 0;
    final t = widget.time;
    if (t != null && t.contains(':')) {
      final parts = t.split(':');
      hh = int.tryParse(parts[0].trim()) ?? 0;
      mm = int.tryParse(parts[1].trim()) ?? 0;
    }
    return DateTime(d.year, d.month, d.day, hh, mm);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final target = _target;
    var rem = target?.difference(DateTime.now()) ?? Duration.zero;
    if (rem.isNegative) rem = Duration.zero;
    final secs = rem.inSeconds;
    final ended = target != null && secs <= 0;
    final urgent = target != null && secs > 0 && secs <= 15 * 60;
    final accent = urgent ? _CountdownBar._urgentColor : gold;

    String label;
    if (target == null) {
      label = 'Programada';
    } else if (ended) {
      label = 'En curso';
    } else {
      final d = rem.inDays;
      final time = '${_two(rem.inHours % 24)}:${_two(rem.inMinutes % 60)}:${_two(rem.inSeconds % 60)}';
      label = d >= 1 ? '${d}d $time' : time;
    }

    final frac = target == null
        ? 0.0
        : (secs / _CountdownBar._window.inSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(urgent ? Icons.timelapse_rounded : Icons.schedule_rounded, size: 15, color: accent),
            const SizedBox(width: 7),
            Text('FALTAN',
                style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 1.4)),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: 0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF6FAE8A), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('CONFIRMADA',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF6FAE8A), letterSpacing: 1.2)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 4, color: Colors.white.withValues(alpha: 0.08)),
              FractionallySizedBox(
                widthFactor: frac,
                child: Container(height: 4, color: accent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.reservation});

  final Reservation reservation;

  Future<void> _share() async {
    final date = reservation.date != null ? DateFormat("EEEE d 'de' MMMM", 'es').format(reservation.date!) : '';
    final service = reservation.services.isNotEmpty ? reservation.services.first.name : 'corte';
    final place = reservation.center?.name ?? 'la barbería';
    final msg = 'Mi cita en $place: $service · $date a las ${reservation.time ?? ''}.';
    await SharePlus.instance.share(ShareParams(text: msg));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Row(
      children: [
        Expanded(
          child: _TextAction(
            icon: Icons.confirmation_number_rounded,
            label: 'Ver ticket',
            color: gold,
            onTap: () => ProfileTicketModal.show(context, reservation),
          ),
        ),
        _divider(),
        Expanded(
          child: _TextAction(
            icon: Icons.ios_share_rounded,
            label: 'Compartir',
            color: Colors.white.withValues(alpha: 0.85),
            onTap: _share,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.07));
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.95,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 7),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.2)),
          ],
        ),
      ),
    );
  }
}
