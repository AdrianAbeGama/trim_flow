import 'package:supabase_flutter/supabase_flutter.dart';

/// Sucursal seleccionable al crear un barbero (todas las del tenant, incluso
/// las que aun no tienen barberos — por eso se lee directo, no del catalogo
/// filtrado).
class BranchOption {
  const BranchOption({required this.id, required this.name});
  final String id;
  final String name;
}

/// Resultado de crear un barbero via la Edge Function `create-barber`.
class CreateBarberResult {
  const CreateBarberResult({
    required this.fullName,
    required this.email,
    this.activationLink,
    this.emailSent = false,
  });

  final String fullName;
  final String email;
  final String? activationLink;
  final bool emailSent;
}

class CreateBarberException implements Exception {
  const CreateBarberException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Acceso de admin para gestionar barberos del tenant. Crear barbero NO puede
/// ser una RPC (crea una cuenta de auth con service-role), por eso va por la
/// Edge Function `create-barber`; `functions.invoke` adjunta el JWT del admin.
class StaffAdminRepository {
  StaffAdminRepository(this._client);
  final SupabaseClient _client;

  Future<List<BranchOption>> fetchBranches({required String tenantId}) async {
    final rows = await _client
        .from('branches')
        .select('id, name')
        .eq('tenant_id', tenantId)
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('display_order', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map((r) => BranchOption(
              id: r['id'] as String? ?? '',
              name: r['name'] as String? ?? 'Sucursal',
            ))
        .where((b) => b.id.isNotEmpty)
        .toList();
  }

  Future<CreateBarberResult> createBarber({
    required String email,
    required String fullName,
    required String branchId,
    String? specialty,
    String? phone,
  }) async {
    try {
      final res = await _client.functions.invoke('create-barber', body: {
        'email': email.trim(),
        'fullName': fullName.trim(),
        'branchId': branchId,
        if (specialty != null && specialty.trim().isNotEmpty)
          'specialty': specialty.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      });
      final data = (res.data as Map?)?.cast<String, dynamic>() ?? const {};
      final barber = (data['barber'] as Map?)?.cast<String, dynamic>();
      return CreateBarberResult(
        fullName: (barber?['fullName'] as String?) ?? fullName.trim(),
        email: (barber?['email'] as String?) ?? email.trim(),
        activationLink: data['activationLink'] as String?,
        emailSent: data['emailSent'] as bool? ?? false,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final code = (details is Map) ? (details['error']?.toString() ?? '') : '';
      throw CreateBarberException(_friendly(code));
    } catch (_) {
      throw const CreateBarberException(
          'No se pudo crear el barbero. Intenta de nuevo.');
    }
  }

  String _friendly(String code) {
    switch (code) {
      case 'not_authenticated':
        return 'Tu sesión expiró. Inicia sesión de nuevo.';
      case 'forbidden':
        return 'No tienes permiso para crear barberos.';
      case 'branch_not_in_tenant':
        return 'Elige una sucursal válida de tu barbería.';
      case 'missing_fields':
        return 'Completa correo, nombre y sucursal.';
      case 'invalid_email':
        return 'El correo no es válido.';
      case 'email_already_registered':
        return 'Ese correo ya está en uso.';
      case 'auth_create_failed':
      case 'create_failed':
        return 'No se pudo crear. Intenta de nuevo en un momento.';
      default:
        return 'No se pudo crear el barbero. Intenta de nuevo.';
    }
  }
}
