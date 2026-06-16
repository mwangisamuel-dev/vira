import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../network/api_client.dart';

/// Streams courier GPS location to the backend every 5 seconds, per spec.
///
/// IMPORTANT — gap in the original architecture doc this addresses:
/// a plain foreground geolocator stream stops the moment a courier's
/// screen locks or the OS suspends the app, which on a motorcycle in
/// Nairobi traffic is most of the ride. For a platform claiming
/// "zero-failure," location continuity needs:
///   1. A background-capable location plugin (not just `geolocator`,
///      which is foreground-oriented) — see pubspec note on
///      flutter_background_geolocation as the production replacement.
///   2. An offline queue so pings aren't silently dropped in dead zones
///      (Nairobi gridlock + variable network coverage), with retry on
///      reconnect rather than fire-and-forget.
///
/// This class models the queueing/retry contract; the actual background
/// location capture should be wired through flutter_background_geolocation
/// in production, calling `recordPing()` from its event callback instead
/// of a raw geolocator stream.
class LocationService {
  LocationService._internal();
  static final LocationService instance = LocationService._internal();

  static const String _queueBoxName = 'vira_location_queue';
  StreamSubscription<Position>? _positionSub;
  Timer? _flushTimer;
  ApiClient? _apiClient;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_queueBoxName)) {
      await Hive.openBox<Map>(_queueBoxName);
    }
    _apiClient = await ApiClient.getInstance();

    // Periodically attempt to flush any queued pings that failed to send
    // while offline. 10s interval balances battery cost against how
    // quickly a reconnect should clear the backlog.
    _flushTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _flushQueue(),
    );
  }

  /// Starts the 5-second foreground location stream. In production this
  /// is superseded by background_geolocation's continuous tracking mode —
  /// kept here as the foreground fallback and for simulator/testing.
  Future<void> startForegroundStream() async {
    final permission = await _ensurePermission();
    if (!permission) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
      recordPing(position.latitude, position.longitude);
    });
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Records a single location ping. Tries to send immediately; on
  /// failure (offline, dead zone), queues it in Hive for retry rather
  /// than dropping it — this is the difference between "location updates
  /// every 5s" working on paper vs. surviving real Nairobi connectivity.
  Future<void> recordPing(double lat, double lng) async {
    final box = Hive.box<Map>(_queueBoxName);
    final pingId = DateTime.now().microsecondsSinceEpoch.toString();

    try {
      await _apiClient?.postLocation(lat, lng);
    } catch (_) {
      await box.put(pingId, {
        'lat': lat,
        'lng': lng,
        'ts': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<void> _flushQueue() async {
    final box = Hive.box<Map>(_queueBoxName);
    if (box.isEmpty) return;

    final keys = box.keys.toList();
    for (final key in keys) {
      final entry = box.get(key);
      if (entry == null) continue;

      try {
        await _apiClient?.postLocation(
          entry['lat'] as double,
          entry['lng'] as double,
        );
        await box.delete(key);
      } catch (_) {
        // Still offline — leave it queued, try again next tick.
        break;
      }
    }
  }

  void stop() {
    _positionSub?.cancel();
    _flushTimer?.cancel();
  }
}
