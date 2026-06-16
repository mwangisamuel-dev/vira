import 'package:equatable/equatable.dart';

/// Lightweight lat/lng value object. Kept independent of any specific
/// maps package type so domain models don't import google_maps_flutter —
/// conversion to LatLng happens only at the widget layer.
class GeoPoint extends Equatable {
  final double lat;
  final double lng;
  final String? label; // e.g. "KNH Blood Bank", "Kenyatta ICU"

  const GeoPoint({required this.lat, required this.lng, this.label});

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        label: json['label'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        if (label != null) 'label': label,
      };

  @override
  List<Object?> get props => [lat, lng, label];
}
