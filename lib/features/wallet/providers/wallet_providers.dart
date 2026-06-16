import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/payment.dart';

/// Earnings summary for the courier wallet header. FutureProvider rather
/// than StreamProvider since this is a point-in-time snapshot the screen
/// re-fetches on pull-to-refresh, not something that needs live push —
/// contrast with trip/location state, which genuinely needs WebSocket
/// streaming.
final earningsSummaryProvider = FutureProvider.autoDispose<EarningsSummary>((ref) async {
  final api = await ApiClient.getInstance();
  final response = await api.getEarningsSummary();
  return EarningsSummary.fromJson(response.data as Map<String, dynamic>);
});

final paymentHistoryProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final api = await ApiClient.getInstance();
  final response = await api.getPaymentHistory();
  final list = response.data['payments'] as List<dynamic>;
  return list.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
});

/// Triggers a B2C payout request. Exposed as a provider-held function so
/// the wallet screen can invalidate earningsSummaryProvider/paymentHistoryProvider
/// after a successful call without manually wiring callback plumbing.
final requestPayoutProvider = FutureProvider.autoDispose<void>((ref) async {
  final api = await ApiClient.getInstance();
  await api.requestPayout();
  ref.invalidate(earningsSummaryProvider);
  ref.invalidate(paymentHistoryProvider);
});
