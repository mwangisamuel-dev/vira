import 'package:equatable/equatable.dart';
import 'vira_enums.dart';

/// The primary entity of a VIRA trip. A trip is just metadata around the
/// movement of a CargoManifest — this model should be created BEFORE a
/// trip is requested, not as an afterthought field on the Trips table.
class CargoManifest extends Equatable {
  final String id;
  final CargoType type;
  final PriorityTier priority;
  final int quantity;
  final String unit; // e.g. "units", "cylinders", "samples"
  final bool coldChainRequired;
  final String? notes; // e.g. "O-Neg, cross-matched for patient in Theatre 3"
  final String requestingFacilityId;
  final String requestingFacilityName;
  final DateTime createdAt;

  const CargoManifest({
    required this.id,
    required this.type,
    required this.priority,
    required this.quantity,
    required this.unit,
    required this.coldChainRequired,
    required this.requestingFacilityId,
    required this.requestingFacilityName,
    required this.createdAt,
    this.notes,
  });

  factory CargoManifest.fromJson(Map<String, dynamic> json) {
    return CargoManifest(
      id: json['id'] as String,
      type: CargoType.values.byName(json['type'] as String),
      priority: PriorityTier.values.byName(json['priority'] as String),
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      coldChainRequired: json['cold_chain_required'] as bool,
      notes: json['notes'] as String?,
      requestingFacilityId: json['requesting_facility_id'] as String,
      requestingFacilityName: json['requesting_facility_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'quantity': quantity,
        'unit': unit,
        'cold_chain_required': coldChainRequired,
        'notes': notes,
        'requesting_facility_id': requestingFacilityId,
        'requesting_facility_name': requestingFacilityName,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        quantity,
        unit,
        coldChainRequired,
        notes,
        requestingFacilityId,
        requestingFacilityName,
        createdAt,
      ];
}
