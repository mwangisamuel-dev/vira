import 'package:equatable/equatable.dart';
import 'vira_enums.dart';
import 'geo_point.dart';
import 'cargo_manifest.dart';

/// A single dispatch journey. Note this model intentionally does NOT carry
/// pricing/fare logic inline — that's owned by the Pricing microservice and
/// arrives via the trip.* Kafka stream as a separate field set, kept here
/// minimally so the client model doesn't silently drift from the backend
/// event contract.
class Trip extends Equatable {
  final String id;
  final CargoManifest manifest;
  final TripStatus status;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final String? courierId;
  final String? courierName;
  final String? courierPhone;
  final GeoPoint? courierLiveLocation; // updated via WebSocket, not REST
  final DateTime requestedAt;
  final DateTime? matchedAt;
  final DateTime? completedAt;
  final int? etaSeconds;
  final double? fareKes;

  const Trip({
    required this.id,
    required this.manifest,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.requestedAt,
    this.courierId,
    this.courierName,
    this.courierPhone,
    this.courierLiveLocation,
    this.matchedAt,
    this.completedAt,
    this.etaSeconds,
    this.fareKes,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      manifest:
          CargoManifest.fromJson(json['manifest'] as Map<String, dynamic>),
      status: TripStatus.values.byName(json['status'] as String),
      pickup: GeoPoint.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: GeoPoint.fromJson(json['dropoff'] as Map<String, dynamic>),
      courierId: json['courier_id'] as String?,
      courierName: json['courier_name'] as String?,
      courierPhone: json['courier_phone'] as String?,
      courierLiveLocation: json['courier_live_location'] == null
          ? null
          : GeoPoint.fromJson(
              json['courier_live_location'] as Map<String, dynamic>),
      requestedAt: DateTime.parse(json['requested_at'] as String),
      matchedAt: json['matched_at'] == null
          ? null
          : DateTime.parse(json['matched_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      etaSeconds: json['eta_seconds'] as int?,
      fareKes: (json['fare_kes'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'manifest': manifest.toJson(),
        'status': status.name,
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
        'courier_id': courierId,
        'courier_name': courierName,
        'courier_phone': courierPhone,
        'courier_live_location': courierLiveLocation?.toJson(),
        'requested_at': requestedAt.toIso8601String(),
        'matched_at': matchedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'eta_seconds': etaSeconds,
        'fare_kes': fareKes,
      };

  Trip copyWith({
    TripStatus? status,
    String? courierId,
    String? courierName,
    String? courierPhone,
    GeoPoint? courierLiveLocation,
    DateTime? matchedAt,
    DateTime? completedAt,
    int? etaSeconds,
    double? fareKes,
  }) {
    return Trip(
      id: id,
      manifest: manifest,
      status: status ?? this.status,
      pickup: pickup,
      dropoff: dropoff,
      requestedAt: requestedAt,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      courierLiveLocation: courierLiveLocation ?? this.courierLiveLocation,
      matchedAt: matchedAt ?? this.matchedAt,
      completedAt: completedAt ?? this.completedAt,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      fareKes: fareKes ?? this.fareKes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        manifest,
        status,
        pickup,
        dropoff,
        courierId,
        courierName,
        courierPhone,
        courierLiveLocation,
        requestedAt,
        matchedAt,
        completedAt,
        etaSeconds,
        fareKes,
      ];
}
