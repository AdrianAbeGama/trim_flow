import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

class AdminBusinessView extends StatefulWidget {
  const AdminBusinessView({super.key, required this.tenantId});

  final String tenantId;

  @override
  State<AdminBusinessView> createState() => _AdminBusinessViewState();
}

class _AdminBusinessViewState extends State<AdminBusinessView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _reminder = false;

  bool _loading = true;
  bool _error = false;
  bool _saving = false;

  AdminRepository get _repo => getIt<AdminRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _daysCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final s = await _repo.fetchTenantSettings(tenantId: widget.tenantId);
      if (!mounted) return;
      _nameCtrl.text = s.name;
      _phoneCtrl.text = s.phone;
      _addressCtrl.text = s.address;
      _emailCtrl.text = s.email;
      _daysCtrl.text = '${s.reminderDays}';
      _messageCtrl.text = s.reminderMessage;
      setState(() {
        _reminder = s.reminderEnabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return adminSnack(context, 'Ponle un nombre a tu barbería');
    final actorId = Supabase.instance.client.auth.currentUser?.id;
    if (actorId == null) {
      adminSnack(context, 'Tu sesión expiró, vuelve a entrar');
      return;
    }
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 15;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await _repo.saveTenantGeneral(
        tenantId: widget.tenantId,
        actorId: actorId,
        name: name,
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      await _repo.saveTenantAutomation(
        tenantId: widget.tenantId,
        actorId: actorId,
        enabled: _reminder,
        days: days,
        message: _messageCtrl.text.trim(),
      );
      if (!mounted) return;
      adminSnack(context, 'Cambios guardados');
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo guardar. Revisa tu conexión o permisos.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminScreenHeader(
              title: 'Mi barbería',
              subtitle: 'Datos y recordatorios',
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const AdminLoader();
    if (_error) return AdminErrorView(onRetry: _load);
    final gold = context.primaryGold;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            physics: const BouncingScrollPhysics(),
            children: [
              const PremiumSectionLabel('Datos'),
              const SizedBox(height: 12),
              AdminTextField(controller: _nameCtrl, label: 'Nombre'),
              const SizedBox(height: 12),
              AdminTextField(
                  controller: _phoneCtrl,
                  label: 'Teléfono / WhatsApp',
                  hint: '+51...'),
              const SizedBox(height: 12),
              AdminTextField(
                  controller: _addressCtrl, label: 'Dirección', maxLines: 2),
              const SizedBox(height: 12),
              AdminTextField(
                  controller: _emailCtrl, label: 'Correo', hint: 'correo@...'),
              const SizedBox(height: 26),
              const PremiumSectionLabel('Recordatorio automático'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Avisar a clientes que no vienen hace tiempo',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: _reminder,
                    activeThumbColor: gold,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _reminder = v);
                    },
                  ),
                ],
              ),
              if (_reminder) ...[
                const SizedBox(height: 12),
                AdminTextField(
                    controller: _daysCtrl,
                    label: 'Días sin venir',
                    number: true,
                    hint: '15'),
                const SizedBox(height: 12),
                AdminTextField(
                    controller: _messageCtrl,
                    label: 'Mensaje',
                    maxLines: 3,
                    hint: '¡Te extrañamos! Vuelve y...'),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: AdminPrimaryButton(
            label: 'Guardar cambios',
            loading: _saving,
            onTap: _save,
          ),
        ),
      ],
    );
  }
}
