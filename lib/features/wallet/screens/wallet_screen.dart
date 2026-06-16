import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';
import '../models/payment.dart';
import '../providers/wallet_providers.dart';

/// Courier wallet — earnings summary + payment history. This screen only
/// ever displays status; it never initiates an M-Pesa transaction
/// directly. STK push happens when a rider pays at trip completion
/// (server-side), and B2C payout is requested here but executed by the
/// Payment microservice via Daraja — `requestPayoutProvider` just asks
/// the backend to start that process and refreshes once it's done.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(earningsSummaryProvider);
    final paymentsAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      appBar: AppBar(title: const Text('Wallet')),
      body: SafeArea(
        child: RefreshIndicator(
          color: ViraColors.cyan,
          backgroundColor: ViraColors.obsidianSurface1,
          onRefresh: () async {
            ref.invalidate(earningsSummaryProvider);
            ref.invalidate(paymentHistoryProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(ViraSpace.lg),
            children: [
              earningsAsync.when(
                data: (earnings) => _earningsHero(context, ref, earnings),
                loading: () => const _EarningsHeroSkeleton(),
                error: (err, _) => _errorCard('Couldn\'t load earnings'),
              ),
              const SizedBox(height: ViraSpace.xl),
              Text('Payment History', style: ViraType.h3),
              const SizedBox(height: ViraSpace.md),
              paymentsAsync.when(
                data: (payments) => payments.isEmpty
                    ? _emptyHistory()
                    : Column(
                        children: [
                          for (final payment in payments) ...[
                            _PaymentRow(payment: payment),
                            const SizedBox(height: ViraSpace.sm),
                          ],
                        ],
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: ViraSpace.xxl),
                  child: Center(
                    child: CircularProgressIndicator(color: ViraColors.cyan),
                  ),
                ),
                error: (err, _) => _errorCard('Couldn\'t load payment history'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningsHero(BuildContext context, WidgetRef ref, EarningsSummary earnings) {
    return ViraCard(
      accentColor: ViraColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PENDING PAYOUT', style: ViraType.monoLabel),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${earnings.pendingPayoutKes.toStringAsFixed(0)}',
                style: ViraType.displayLarge.copyWith(color: ViraColors.cyan, fontSize: 30),
              ),
            ],
          ),
          const SizedBox(height: ViraSpace.lg),
          Row(
            children: [
              Expanded(
                child: _miniStat('KES ${earnings.todayKes.toStringAsFixed(0)}', 'Today'),
              ),
              const SizedBox(width: ViraSpace.sm),
              Expanded(
                child: _miniStat('KES ${earnings.weekKes.toStringAsFixed(0)}', 'This Week'),
              ),
              const SizedBox(width: ViraSpace.sm),
              Expanded(
                child: _miniStat('${earnings.tripsToday}', 'Trips Today'),
              ),
            ],
          ),
          const SizedBox(height: ViraSpace.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: earnings.pendingPayoutKes > 0
                  ? () => _requestPayout(context, ref)
                  : null,
              child: const Text('Request M-Pesa Payout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ViraSpace.sm, horizontal: ViraSpace.xs),
      decoration: BoxDecoration(
        color: ViraColors.obsidian,
        borderRadius: BorderRadius.circular(ViraRadius.sm),
      ),
      child: Column(
        children: [
          Text(value, style: ViraType.monoValue.copyWith(fontSize: 13)),
          const SizedBox(height: 2),
          Text(label, style: ViraType.monoCaption),
        ],
      ),
    );
  }

  Future<void> _requestPayout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(requestPayoutProvider.future);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout requested — funds typically arrive within minutes via M-Pesa.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout request failed. Try again shortly.')),
      );
    }
  }

  Widget _emptyHistory() {
    return ViraCard(
      child: Column(
        children: [
          Text('No payments yet', style: ViraType.body),
          const SizedBox(height: 4),
          Text('Completed trips will show up here', style: ViraType.bodySmall),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return ViraCard(
      accentColor: ViraColors.crimson,
      child: Text(message, style: ViraType.body),
    );
  }
}

class _EarningsHeroSkeleton extends StatelessWidget {
  const _EarningsHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ViraCard(
      child: SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: ViraColors.cyan)),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (payment.status) {
      PaymentStatus.completed => (ViraColors.statusOk, 'COMPLETED'),
      PaymentStatus.processing => (ViraColors.statusWarn, 'PROCESSING'),
      PaymentStatus.pending => (ViraColors.platinum30, 'PENDING'),
      PaymentStatus.failed => (ViraColors.crimson, 'FAILED'),
      PaymentStatus.reversed => (ViraColors.crimson, 'REVERSED'),
    };

    return ViraCard(
      padding: const EdgeInsets.symmetric(horizontal: ViraSpace.lg, vertical: ViraSpace.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KES ${payment.amountKes.toStringAsFixed(0)}',
                  style: ViraType.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.mpesaReceiptNumber != null
                      ? 'M-Pesa · ${payment.mpesaReceiptNumber}'
                      : 'Trip #${payment.tripId.substring(payment.tripId.length - 6)}',
                  style: ViraType.monoCaption,
                ),
              ],
            ),
          ),
          StatusPill(label: label, color: color),
        ],
      ),
    );
  }
}
