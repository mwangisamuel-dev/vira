import 'package:equatable/equatable.dart';
import '../../shared/models/vira_enums.dart';

/// Represents the current authenticated session. Holding `role` here is
/// what the router's redirect guard reads to decide which of the three
/// app surfaces (Rider/Courier/Dispatch) a given user is allowed into.
class ViraSession extends Equatable {
  final String userId;
  final String displayName;
  final String phone;
  final ViraRole role;
  final String? facilityId; // set for Rider role (hospital/clinic/blood bank)
  final String? facilityName;
  final bool isVerified; // institutional verification, required for Rider role

  const ViraSession({
    required this.userId,
    required this.displayName,
    required this.phone,
    required this.role,
    this.facilityId,
    this.facilityName,
    this.isVerified = false,
  });

  @override
  List<Object?> get props =>
      [userId, displayName, phone, role, facilityId, facilityName, isVerified];
}
