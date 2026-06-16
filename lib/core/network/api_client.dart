import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps Dio for all REST calls through the API Gateway.
/// The gateway itself handles load balancing / auth wall / rate limiting
/// server-side — this client's job is just to attach the session token
/// and provide a single configured instance app-wide.
class ApiClient {
  ApiClient._internal(this._dio);

  static ApiClient? _instance;

  final Dio _dio;

  static const String _baseUrlDev = 'https://api.vira.dev'; // placeholder
  static const String _baseUrlProd = 'https://api.vira.health'; // placeholder

  static Future<ApiClient> getInstance({bool isProd = false}) async {
    if (_instance != null) return _instance!;

    final dio = Dio(
      BaseOptions(
        baseUrl: isProd ? _baseUrlProd : _baseUrlDev,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('vira_session_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Centralized error logging hook — wire to crash reporting here.
          return handler.next(error);
        },
      ),
    );

    _instance = ApiClient._internal(dio);
    return _instance!;
  }

  Dio get client => _dio;

  // ── Trip endpoints ──
  Future<Response> requestTrip(Map<String, dynamic> manifestPayload) {
    return _dio.post('/v1/trips', data: manifestPayload);
  }

  Future<Response> getTrip(String tripId) {
    return _dio.get('/v1/trips/$tripId');
  }

  Future<Response> getActiveTrips() {
    return _dio.get('/v1/trips', queryParameters: {'status': 'active'});
  }

  Future<Response> cancelTrip(String tripId, {String? reason}) {
    return _dio.post('/v1/trips/$tripId/cancel', data: {'reason': reason});
  }

  // ── Courier endpoints ──
  Future<Response> postLocation(double lat, double lng) {
    return _dio.post('/location', data: {
      'lat': lat,
      'lng': lng,
      'ts': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<Response> acceptJob(String tripId) {
    return _dio.post('/v1/trips/$tripId/accept');
  }

  Future<Response> confirmPickup(String tripId) {
    return _dio.post('/v1/trips/$tripId/confirm-pickup');
  }

  Future<Response> confirmDelivery(
    String tripId, {
    String? photoUrl,
    String? signatureUrl,
  }) {
    return _dio.post('/v1/trips/$tripId/confirm-delivery', data: {
      'photo_url': photoUrl,
      'signature_url': signatureUrl,
    });
  }

  // ── Dispatch endpoints ──
  Future<Response> getFleetStatus() {
    return _dio.get('/v1/dispatch/fleet');
  }

  Future<Response> getSystemHealth() {
    return _dio.get('/v1/dispatch/health');
  }

  Future<Response> manualOverride(String tripId, String action) {
    return _dio.post('/v1/dispatch/trips/$tripId/override', data: {
      'action': action,
    });
  }

  // ── Wallet / Payment endpoints ──
  // M-Pesa STK push (rider payment-in) and B2C disbursement (courier
  // payout) are both initiated server-side via Daraja — these calls only
  // read status the backend has already resolved, they never touch
  // Daraja directly from the client.
  Future<Response> getEarningsSummary() {
    return _dio.get('/v1/wallet/earnings');
  }

  Future<Response> getPaymentHistory({int limit = 20}) {
    return _dio.get('/v1/wallet/payments', queryParameters: {'limit': limit});
  }

  Future<Response> getPaymentForTrip(String tripId) {
    return _dio.get('/v1/trips/$tripId/payment');
  }

  Future<Response> requestPayout() {
    return _dio.post('/v1/wallet/payout');
  }
}
