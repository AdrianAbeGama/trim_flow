import 'package:trim_flow/core/staff/domain/models/staff_member.dart';

abstract class StaffRepository {
  Future<List<StaffMember>> listActiveBarbers({String? tenantId});
}
