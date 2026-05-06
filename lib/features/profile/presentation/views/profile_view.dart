import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:trim_flow/core/constants/app_colors.dart';
import 'package:trim_flow/core/utils/date_input_formatter.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfileEvent()),
      child: const ProfileContent(),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  bool _isLoyaltyExpanded = false;
  bool _isHistoryExpanded = false;

  void _showEditSheet(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final phoneController = TextEditingController(text: user.phone);
    final birthDateController = TextEditingController(text: user.birthDate);
    
    // Obtenemos el bloc ANTES de abrir el modal
    final profileBloc = context.read<ProfileBloc>();

    showModalSheet(
      context: context,
      swipeDismissible: true,
      builder: (sheetContext) => BlocProvider.value(
        value: profileBloc,
        child: Sheet(
          initialOffset: const RelativeSheetOffset(0.85),
          physics: const ClampingSheetPhysics(),
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final name = nameController.text.trim();
              final lastName = lastNameController.text.trim();
              final phone = phoneController.text.trim();
              final birthDate = birthDateController.text.trim();

              final isNameValid = name.isNotEmpty && name.length <= 15;
              final isLastNameValid = lastName.isNotEmpty && lastName.length <= 10;
              final isPhoneValid = phone.length == 9 && RegExp(r'^\d+$').hasMatch(phone);
              final isBirthDateValid = _isValidDate(birthDate);

              final canSave = isNameValid && isLastNameValid && isPhoneValid && isBirthDateValid;

              return BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final isLoading = state.status == ProfileStatus.loading;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'EDITAR PERFIL',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ObInputField(
                            label: 'Nombre',
                            controller: nameController,
                            maxLength: 15,
                            showCounter: true,
                            onChanged: (_) => setSheetState(() {}),
                          ),
                          ObInputField(
                            label: 'Apellido',
                            controller: lastNameController,
                            maxLength: 10,
                            showCounter: true,
                            onChanged: (_) => setSheetState(() {}),
                          ),
                          ObInputField(
                            label: 'WhatsApp',
                            controller: phoneController,
                            prefix: '+51',
                            hasPrefixDivider: true,
                            maxLength: 9,
                            keyboardType: TextInputType.phone,
                            errorText: (phone.isNotEmpty && !isPhoneValid) ? 'Este no es un número válido' : null,
                            onChanged: (_) => setSheetState(() {}),
                          ),
                          ObInputField(
                            label: 'Fecha de Nacimiento',
                            controller: birthDateController,
                            hintText: 'DD / MM / AAAA',
                            keyboardType: TextInputType.number,
                            inputFormatters: [DateInputFormatter()],
                            errorText: (birthDate.isNotEmpty && !isBirthDateValid) ? 'Esta no es una fecha válida' : null,
                            onChanged: (_) => setSheetState(() {}),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: (isLoading || !canSave)
                                ? null
                                : () {
                                    context.read<ProfileBloc>().add(SaveProfileData(
                                          firstName: nameController.text,
                                          lastName: lastNameController.text,
                                          phone: phoneController.text,
                                          birthDate: birthDateController.text,
                                        ));
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.black,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                              disabledForegroundColor: Colors.white10,
                            ),
                            child: isLoading
                                ? const CupertinoActivityIndicator(color: AppColors.black)
                                : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isValidDate(String date) {
    final cleanDate = date.replaceAll(' ', '');
    final regExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regExp.hasMatch(cleanDate)) return false;

    try {
      final parts = cleanDate.split('/');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);

      if (m < 1 || m > 12) return false;
      if (d < 1 || d > 31) return false;

      if (m == 2) {
        final isLeap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
        if (d > (isLeap ? 29 : 28)) return false;
      } else if ([4, 6, 9, 11].contains(m)) {
        if (d > 30) return false;
      }

      final now = DateTime.now();
      if (y < now.year - 100 || y > now.year) return false;
      if (y == now.year) {
        if (m > now.month) return false;
        if (m == now.month && d > now.day) return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.user == null) {
            return const Center(child: CupertinoActivityIndicator(color: AppColors.gold));
          }

          final user = state.user;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildHeader(context, user),
                const SizedBox(height: 40),

                _buildSection('NOTIFICACIONES', [
                  _buildNotificationControls(context, user),
                ]),

                const SizedBox(height: 32),

                _buildSection('DATOS PERSONALES', [
                  _buildDetailItem('WhatsApp', '+51 ${user.phone}', Icons.chat_bubble_outline_rounded),
                  _buildDetailItem('Nacimiento', user.birthDate, Icons.cake_outlined),
                ]),

                const SizedBox(height: 32),
                _buildLoyaltyCard(state),

                const SizedBox(height: 20),
                _buildHistoryCard(user.history),

                const SizedBox(height: 48),
                _buildLogout(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: const Center(
                  child: Text(
                    'ID: 001',
                    style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: TextButton(
                  onPressed: () => _showEditSheet(context, user),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('EDITAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAvatar(user.photoUrl),
          const SizedBox(height: 24),
          _buildIdentity(user),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.all(5),
      child: CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  Widget _buildIdentity(UserProfile user) {
    return Column(
      children: [
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1.5),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLoyaltyCard(ProfileState state) {
    return _buildPremiumCard(
      title: 'VIP MEMBER',
      subtitle: 'Cartilla de Fidelización',
      isExpanded: _isLoyaltyExpanded,
      onTap: () => setState(() => _isLoyaltyExpanded = !_isLoyaltyExpanded),
      children: [
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(7, (index) {
            final isCompleted = index < state.completedCuts;
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.gold : Colors.transparent,
                border: Border.all(color: AppColors.gold.withValues(alpha: isCompleted ? 1 : 0.3), width: 1.5),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.black, size: 20)
                    : Text('${index + 1}', style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: state.isRewardAvailable ? () => context.read<ProfileBloc>().add(ClaimReward()) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
            disabledForegroundColor: Colors.white10,
            elevation: 0,
          ),
          child: const Text('RECLAMAR RECOMPENSA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(List<CuttingRecord> history) {
    return _buildPremiumCard(
      title: 'HISTORIAL',
      subtitle: 'Tus últimos cortes realizados',
      isExpanded: _isHistoryExpanded,
      onTap: () => setState(() => _isHistoryExpanded = !_isHistoryExpanded),
      children: [
        const SizedBox(height: 16),
        ...history.map((record) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.day, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(record.time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(record.price, style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 20),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gold,
                  ),
                ],
              ),
              if (isExpanded) ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationControls(BuildContext context, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notificaciones de Sistema', style: TextStyle(color: Colors.white, fontSize: 15)),
              TextButton(
                onPressed: () => context.read<ProfileBloc>().add(RequestNotificationPermissionEvent()),
                style: TextButton.styleFrom(
                  backgroundColor: user.notificationsEnabled ? Colors.green.withValues(alpha: 0.05) : AppColors.gold.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  user.notificationsEnabled ? 'HABILITADO' : 'HABILITAR',
                  style: TextStyle(
                    color: user.notificationsEnabled ? Colors.greenAccent : AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTestNotificationMenu(context),
        ],
      ),
    );
  }

  Widget _buildTestNotificationMenu(BuildContext context) {
    return PopupMenuButton<ProfileNotificationType>(
      onSelected: (type) => context.read<ProfileBloc>().add(TestNotificationEvent(type: type)),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildPopupItem(ProfileNotificationType.offer, 'Prueba de Oferta', Icons.local_offer_rounded),
        _buildPopupItem(ProfileNotificationType.birthday, 'Prueba de Cumpleaños', Icons.cake_rounded),
        _buildPopupItem(ProfileNotificationType.reservation, 'Prueba de Reserva', Icons.alarm_rounded),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 16),
            SizedBox(width: 12),
            Text('PRUEBA DE NOTIFICACIONES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ProfileNotificationType> _buildPopupItem(ProfileNotificationType value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 18),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white38, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildLogout() {
    return TextButton(
      onPressed: () {},
      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
    );
  }
}
