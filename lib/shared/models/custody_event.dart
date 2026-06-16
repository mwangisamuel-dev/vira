import 'package:equatable/equatable.dart';
import 'vira_enums.dart';
import 'geo_point.dart';

/// An immutable, geo-tagged, timestamped record of a single handoff or
/// status change in a cargo's journey. This is the backbone of hospital
/// trust in the platform and the primary compliance artifact under
/// Kenya's Data Protection Act for anything patient-adjacent (blood type,
/// sample provenance).
///
/// CustodyEvents are append-only — never updated or deleted client-side.
/// The backend should treat this table as a ledger, not a mutable record.
class CustodyEvent extends Equatable {
  final String id;
  final String tripId;
  final CustodyEventType type;
  final DateTime timestamp;
  final GeoPoint location;
  final String actorId; // courier or facility staff ID who triggered this
  final String actorName;
  final String? photoUrl; // delivery confirmation photo, if captured
  final String? signatureUrl; // recipient signature, if captured
  final String? note;

  const CustodyEvent({
    required this.id,
    required this.tripId,
    required this.type,
    required this.timestamp,
    required this.location,
    required this.actorId,
    required this.actorName,
    this.photoUrl,
    this.signatureUrl,
    this.note,
  });

  factory CustodyEvent.fromJson(Map<String, dynamic> json) {
    return CustodyEvent(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      type: CustodyEventType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>),
      actorId: json['actor_id'] as String,
      actorName: json['actor_name'] as String,
      photoUrl: json['photo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_id': tripId,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'location': location.toJson(),
        'actor_id': actorId,
        'actor_name': actorName,
        if (photoUrl != null) 'photo_url': photoUrl,
        if (signatureUrl != null) 'signature_url': signatureUrl,
        if (note != null) 'note': note,
      };

  @override
  List<Object?> get props => [
        id,
        tripId,
        type,
        timestamp,
        location,
        actorId,
        actorName,
        photoUrl,
        signatureUrl,
        note,
      ];
}
