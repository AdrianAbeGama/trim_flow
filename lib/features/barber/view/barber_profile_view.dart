import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/constants/app_roles.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_crop_view.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/orders/barber_orders_view.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_admin_section.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_avatar_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_staff_section.dart';
// OCULTO por ahora (a pedido del socio): seccion "Roles y permisos". El archivo
// se conserva; reactivar descomentando este import y el sliver de mas abajo.
// import 'package:trim_flow/features/barber/view/widgets/barber_roles_section.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_data.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_edit_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_header.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_more.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_stats.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_today_agenda.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_settings_view.dart';

/// BarberProfileView — perfil del barbero: identidad + resumen real de hoy +
/// datos personales + logout. La agenda (citas, historial) vive en su pestaña,
/// no se repite aqui.
class BarberProfileView extends StatelessWidget {
  const BarberProfileView({super.key});

  @override
  Widget build(BuildContext context) => const _BarberProfileBody();
}

class _BarberProfileBody extends StatefulWidget {
  const _BarberProfileBody();

  @override
  State<_BarberProfileBody> createState() => _BarberProfileBodyState();
}

class _BarberProfileBodyState extends State<_BarberProfileBody> {
  Future<AgendaTodaySummary>? _summaryFuture;
  Future<List<AgendaAppointment>>? _agendaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    PermissionsStore.instance.load();
  }

  void _loadData() {
    final barberId = Supabase.instance.client.auth.currentUser?.id;
    if (barberId != null) {
      final repo = getIt<AgendaRepository>();
      _summaryFuture = repo.fetchTodaySummary(barberId: barberId);
      _agendaFuture =
          repo.fetchAgendaForDay(barberId: barberId, day: DateTime.now());
    }
  }

  void _editProfile(UserProfile user) {
    HapticFeedback.lightImpact();
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0E0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BarberProfileEditSheet(user: user),
    );
  }

  void _openAvatarSheet(UserProfile user) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final profileBloc = context.read<ProfileBloc>();
    BarberAvatarSheet.show(
      context,
      user: user,
      onGallery: () => _changeAvatar(ImageSource.gallery, overlay, profileBloc),
      onCamera: () => _changeAvatar(ImageSource.camera, overlay, profileBloc),
      onRemove: () => _removeAvatar(overlay, profileBloc),
      onEditData: () => _editProfile(user),
    );
  }

  /// Elegir foto → recortador premium (cuadrado) → subir, desde la pantalla de
  /// Perfil (sigue viva aunque el selector recree la activity).
  Future<void> _changeAvatar(
    ImageSource source,
    OverlayState overlay,
    ProfileBloc profileBloc,
  ) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        requestFullMetadata: false,
      );
      if (picked == null || !mounted) return;
      final croppedPath = await PremiumCropView.show(
        context,
        sourcePath: picked.path,
        initialAspect: 1.0,
      );
      if (croppedPath == null) return;
      AppToast.showOn(overlay,
          type: AppToastType.info, title: 'Subiendo foto…');
      await getIt<ProfileRepository>()
          .updateStaffAvatar(localImagePath: croppedPath);
      profileBloc.add(const ProfileEvent.load());
      AppToast.showOn(overlay,
          type: AppToastType.success,
          title: 'Foto actualizada',
          message: 'Tu nueva foto ya está lista.');
    } catch (e) {
      final raw = e.toString();
      AppToast.showOn(overlay,
          type: AppToastType.error,
          title: 'No se pudo subir',
          message: raw.length > 140 ? '${raw.substring(0, 140)}…' : raw);
    }
  }

  Future<void> _removeAvatar(
      OverlayState overlay, ProfileBloc profileBloc) async {
    if (!mounted) return;
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Quitar foto',
      message: '¿Seguro que quieres quitar tu foto de perfil?',
      confirmLabel: 'QUITAR',
      icon: Icons.person_off_rounded,
    );
    if (!ok) return;
    try {
      await getIt<ProfileRepository>().removeStaffAvatar();
      profileBloc.add(const ProfileEvent.load());
      AppToast.showOn(overlay,
          type: AppToastType.success, title: 'Foto quitada');
    } catch (_) {
      AppToast.showOn(overlay,
          type: AppToastType.error, title: 'No se pudo quitar');
    }
  }

  void _openOrders() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarberOrdersView()),
    );
  }

  void _openSettings(UserProfile user) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProfileBloc>()),
            BlocProvider.value(value: context.read<AppModeBloc>()),
          ],
          child: ProfileSettingsView(user: user, isBarber: true),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final ok = await PremiumConfirmDelete.show(
      context,
      title: 'Cerrar sesión',
      message:
          '¿Seguro que quieres salir de tu cuenta? Tendrás que volver a iniciar sesión.',
      confirmLabel: 'CERRAR SESIÓN',
      icon: Icons.logout_rounded,
    );
    if (ok && mounted) {
      context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<ProfileBloc>().add(const ProfileEvent.load());
    if (mounted) setState(_loadData);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  String _nextLabel(DateTime? next) {
    if (next == null) return '—';
    return '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return Center(
              child: CupertinoActivityIndicator(
                  color: context.primaryGold, radius: 14),
            );
          }
          final user = state.user;
          if (user == null) {
            return BarberErrorView(
              gold: context.primaryGold,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileEvent.load()),
            );
          }
          final isAdmin = isAdminRole(user.role);

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: context.primaryGold,
            backgroundColor: const Color(0xFF0E0E0E),
            displacement: 60,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<PreviewRole?>(
                    valueListenable: PermissionsStore.instance.preview,
                    builder: (context, preview, _) {
                      if (preview == null) return const SizedBox.shrink();
                      final gold = context.primaryGold;
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: gold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: gold),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Viendo como ${preview.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            PremiumPressable(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                PermissionsStore.instance.stopPreview();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Salir',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: premiumOnAccent(gold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                BarberProfileHeader(
                  user: user,
                  onAvatarTap: () => _openAvatarSheet(user),
                  onSettingsTap: () => _openSettings(user),
                  onOrdersTap: _openOrders,
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<AgendaTodaySummary>(
                    future: _summaryFuture,
                    builder: (context, snap) {
                      final s = snap.data;
                      return BarberProfileStatsRow(
                        cutsToday: s?.completedCuts ?? 0,
                        revenueToday: s?.revenue ?? 0,
                        nextLabel: _nextLabel(s?.nextStart),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<List<AgendaAppointment>>(
                    future: _agendaFuture,
                    builder: (context, snap) {
                      return BarberProfileTodayAgenda(
                        appointments: snap.data ?? const [],
                        loading: snap.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                ),
                if (isAdmin)
                  SliverToBoxAdapter(
                    child: BarberAdminSection(tenantId: user.tenantId),
                  ),
                if (isAdmin)
                  SliverToBoxAdapter(
                    child: BarberStaffSection(tenantId: user.tenantId),
                  ),
                // OCULTO (a pedido del socio, por ahora): la gestion "Roles y
                // permisos" no se muestra. No se elimina: el codigo queda en
                // barber_roles_section.dart / roles_permissions_view.dart /
                // permissions_store.dart. Con la seccion oculta, preview queda
                // null y PermissionsStore.can() devuelve true (admin ve todo),
                // asi que nada mas se rompe. Para reactivarla, descomentar:
                // if (isAdmin)
                //   SliverToBoxAdapter(
                //     child: BarberRolesSection(tenantId: user.tenantId),
                //   ),
                BarberProfilePersonalData(
                  user: user,
                  onTap: () => _editProfile(user),
                  branchName: state.branchName,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: BarberProfileLogoutButton(onTap: _confirmLogout),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

