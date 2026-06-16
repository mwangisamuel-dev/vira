import 'package:equatable/equatable.dart';

/// Mirrors the Payments table from the backend spec (id, trip_id, rider_id,
/// driver_id, amount, status, method). M-Pesa STK push (rider pays in) and
/// B2C disbursement (courier gets paid out) are both backend-initiated via
/// the Daraja API — this client NEVER talks to Daraja directly. It only
/// renders status that arrives via REST poll or the 'payment.*' Kafka
/// stream relayed over WebSocket.
enum PaymentMethod { mpesaStk, mpesaB2c, cash }

enum PaymentStatus { pending, processing, completed, failed, reversed }

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'Pending',
        PaymentStatus.processing => 'Processing',
        PaymentStatus.completed => 'Completed',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.reversed => 'Reversed',
      };
}

class Payment extends Equatable {
  final String id;
  final String tripId;
  final double amountKes;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? mpesaReceiptNumber; // populated once Daraja confirms

  const Payment({
    required this.id,
    required this.tripId,
    required this.amountKes,
    required this.method,
    required this.status,
    required this.createdAt,
    this.mpesaReceiptNumber,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      amountKes: (json['amount_kes'] as num).toDouble(),
      method: PaymentMethod.values.byName(json['method'] as String),
      status: PaymentStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      mpesaReceiptNumber: json['mpesa_receipt_number'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, tripId, amountKes, method, status, createdAt, mpesaReceiptNumber];
}

/// Courier earnings summary — aggregated server-side, this is just the
/// display shape for the wallet screen's headline numbers.
class EarningsSummary extends Equatable {
  final double todayKes;
  final double weekKes;
  final double pendingPayoutKes;
  final int tripsToday;

  const EarningsSummary({
    required this.todayKes,
    required this.weekKes,
    required this.pendingPayoutKes,
    required this.tripsToday,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayKes: (json['today_kes'] as num).toDouble(),
      weekKes: (json['week_kes'] as num).toDouble(),
      pendingPayoutKes: (json['pending_payout_kes'] as num).toDouble(),
      tripsToday: json['trips_today'] as int,
    );
  }

  @override
  List<Object?> get props => [todayKes, weekKes, pendingPayoutKes, tripsToday];
}
