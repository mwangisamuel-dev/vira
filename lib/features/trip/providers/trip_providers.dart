import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/socket_service.dart';
import '../../../shared/models/trip.dart';

/// Live trip state for a single trip ID. Combines an initial REST fetch
/// (so the screen has data immediately) with a WebSocket subscription for
/// every subsequent update (status transitions, courier location ticks).
///
/// This is the provider every trip-facing screen (Rider home's active
/// dispatch card, Courier's accepted job, Dispatch's override list,
/// LiveTrackingScreen) should read from instead of the inline demo data
/// used during early scaffolding — same trip ID, same stream, same state
/// rendered identically across all three roles.
final tripProvider = StreamProvider.autoDispose.family<Trip, String>((ref, tripId) async* {
  final api = await ApiClient.getInstance();

  // Seed with a REST snapshot first so the UI isn't blank while waiting
  // for the first WebSocket frame.
  try {
    final response = await api.getTrip(tripId);
    yield Trip.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    // No initial snapshot available (e.g. backend not reachable yet in
    // this scaffold) — fall through to the socket stream only.
  }

  final socket = SocketService.instance;
  yield* socket.subscribe('trip.$tripId').map(Trip.fromJson);
});

/// All trips currently active for the signed-in session's relevant scope
/// (a rider's facility, a courier's assigned jobs, or dispatch's full
/// fleet view depending on which screen reads this). The backend scopes
/// the response by auth token, so the client doesn't need to filter.
final activeTripsProvider = FutureProvider.autoDispose<List<Trip>>((ref) async {
  final api = await ApiClient.getInstance();
  final response = await api.getActiveTrips();
  final list = response.data['trips'] as List<dynamic>;
  return list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
});
