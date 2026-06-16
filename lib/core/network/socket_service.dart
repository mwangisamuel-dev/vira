import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connects to VIRA's WebSocket Gateway for real-time push: live courier
/// location, trip state transitions, and dispatch escalation alerts.
///
/// This is a thin client over a single multiplexed connection — the
/// backend gateway fans out Kafka events (ride.*, payment.*, trip.*) to
/// subscribed clients. We don't open a new socket per trip; instead we
/// subscribe/unsubscribe to topics over one persistent connection, which
/// matters on courier devices given the bandwidth and battery cost of
/// repeated handshakes.
class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();

  WebSocketChannel? _channel;
  final _topicControllers = <String, StreamController<Map<String, dynamic>>>{};
  final _subscribedTopics = <String>{};

  bool get isConnected => _channel != null;

  Future<void> connect(String wsUrl, {required String authToken}) async {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUrl?token=$authToken'),
    );

    _channel!.stream.listen(
      _handleMessage,
      onError: (_) => _scheduleReconnect(wsUrl, authToken),
      onDone: () => _scheduleReconnect(wsUrl, authToken),
    );

    // Re-subscribe to any topics that were active before a reconnect.
    for (final topic in _subscribedTopics) {
      _sendSubscribe(topic);
    }
  }

  void _scheduleReconnect(String wsUrl, String authToken) {
    _channel = null;
    Future.delayed(const Duration(seconds: 3), () {
      connect(wsUrl, authToken: authToken);
    });
  }

  void _handleMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      final topic = decoded['topic'] as String?;
      if (topic == null) return;

      _topicControllers[topic]?.add(decoded['payload'] as Map<String, dynamic>);
    } catch (_) {
      // Malformed frame — drop silently rather than crash the socket loop.
    }
  }

  void _sendSubscribe(String topic) {
    _channel?.sink.add(jsonEncode({'action': 'subscribe', 'topic': topic}));
  }

  /// Subscribe to a topic (e.g. 'trip.abc123', 'courier.location.abc123',
  /// 'dispatch.fleet', 'dispatch.alerts') and get a stream of decoded
  /// payloads for it.
  Stream<Map<String, dynamic>> subscribe(String topic) {
    _subscribedTopics.add(topic);
    _sendSubscribe(topic);

    return (_topicControllers[topic] ??=
            StreamController<Map<String, dynamic>>.broadcast())
        .stream;
  }

  void unsubscribe(String topic) {
    _subscribedTopics.remove(topic);
    _channel?.sink.add(jsonEncode({'action': 'unsubscribe', 'topic': topic}));
    _topicControllers[topic]?.close();
    _topicControllers.remove(topic);
  }

  void send(String topic, Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode({
      'action': 'publish',
      'topic': topic,
      'payload': payload,
    }));
  }

  void dispose() {
    for (final c in _topicControllers.values) {
      c.close();
    }
    _topicControllers.clear();
    _channel?.sink.close();
    _channel = null;
  }
}
