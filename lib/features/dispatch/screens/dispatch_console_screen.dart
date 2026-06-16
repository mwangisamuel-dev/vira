import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/vira_enums.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/models/cargo_manifest.dart';
import '../../trip/providers/trip_providers.dart';

/// Dispatch Operations console — the "web dispatch monitor" surface
/// called out in the architecture spec. Built mobile-first like the rest
/// of the app, but the layout below switches to a multi-column grid past
/// 900px so the same Flutter codebase serves a genuine desktop ops view
/// without a separate web project.
class DispatchConsoleScreen extends ConsumerWidget {
  const DispatchConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTripsAsync = ref.watch(activeTripsProvider);

    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(ViraSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('System Health', style: ViraType.h1),
                      const StatusPill(label: 'PRODUCTION', color: ViraColors.cyan),
                    ],
                  ),
                  Text('INFRA · ALL_REGIONS', style: ViraType.monoCaption),
                  const SizedBox(height: ViraSpace.xl),
                  isWide
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _uptimeHero()),
                              const SizedBox(width: ViraSpace.lg),
                              Expanded(flex: 3, child: _servicesGrid()),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            _uptimeHero(),
                            const SizedBox(height: ViraSpace.lg),
                            _servicesGrid(),
                          ],
                        ),
                  const SizedBox(height: ViraSpace.xl),
                  Text('Request Throughput', style: ViraType.h3),
                  const SizedBox(height: ViraSpace.md),
                  _gaugeCard('7,241 RPS', 0.72, ViraColors.cyan, '0', '10k'),
                  const SizedBox(height: ViraSpace.md),
                  _gaugeCard('99% Cache Hit', 0.99, ViraColors.statusOk, '0%', '100%'),
                  const SizedBox(height: ViraSpace.xl),
                  Text('Latency SLA', style: ViraType.h3),
                  const SizedBox(height: ViraSpace.md),
                  Row(
                    children: [
                      Expanded(child: _latCard('<1s', 'Match', ViraColors.crimson)),
                      const SizedBox(width: ViraSpace.sm),
                      Expanded(child: _latCard('<5s', 'Loc Update', ViraColors.cyan)),
                      const SizedBox(width: ViraSpace.sm),
                      Expanded(child: _latCard('<200ms', 'API P99', ViraColors.statusOk)),
                    ],
                  ),
                  const SizedBox(height: ViraSpace.xl),
                  Text('Active Critical Dispatches', style: ViraType.h3),
                  const SizedBox(height: ViraSpace.md),
                  activeTripsAsync.when(
                    data: (trips) {
                      final critical = trips
                          .where((t) => t.manifest.priority == PriorityTier.critical)
                          .toList();
                      if (critical.isEmpty) {
                        return _emptyCriticalCard();
                      }
                      return Column(
                        children: [
                          for (final trip in critical) ...[
                            _criticalDispatchRow(context, trip),
                            const SizedBox(height: ViraSpace.sm),
                          ],
                        ],
                      );
                    },
                    // No live backend wired yet in this scaffold — fall
                    // back to one representative demo row rather than a
                    // blank/error state.
                    loading: () => _criticalDispatchRow(context, _demoTrip()),
                    error: (err, _) => _criticalDispatchRow(context, _demoTrip()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _criticalDispatchRow(BuildContext context, Trip trip) {
    final etaLabel = trip.etaSeconds != null
        ? 'ETA ${(trip.etaSeconds! / 60).ceil()}m'
        : '—';

    return ViraCard(
      accentColor: ViraColors.crimson,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${trip.manifest.type.label} · ${trip.pickup.label ?? 'Pickup'} → ${trip.dropoff.label ?? 'Drop-off'}',
              style: ViraType.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(etaLabel, style: ViraType.monoValue.copyWith(color: ViraColors.crimson)),
          ),
          TextButton(
            onPressed: () => context.push('/trip/${trip.id}'),
            child: const Text('Override', style: TextStyle(color: ViraColors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _emptyCriticalCard() {
    return ViraCard(
      child: Text('No critical dispatches active right now', style: ViraType.bodySmall),
    );
  }

  static Trip _demoTrip() {
    return Trip(
      id: 'demo-trip-001',
      manifest: CargoManifest(
        id: 'manifest-demo',
        type: CargoType.bloodProduct,
        priority: PriorityTier.critical,
        quantity: 2,
        unit: 'units',
        coldChainRequired: true,
        requestingFacilityId: 'facility-001',
        requestingFacilityName: 'Kenyatta National Hospital',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      status: TripStatus.arriving,
      pickup: const GeoPoint(lat: -1.3007, lng: 36.8073, label: 'KNH'),
      dropoff: const GeoPoint(lat: -1.2989, lng: 36.8095, label: 'Agha Khan'),
      requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      etaSeconds: 240,
    );
  }

  Widget _uptimeHero() {
    return Container(
      padding: const EdgeInsets.all(ViraSpace.xl),
      decoration: BoxDecoration(
        color: ViraColors.obsidianSurface1,
        borderRadius: BorderRadius.circular(ViraRadius.lg),
        border: Border.all(color: ViraColors.cyanGlow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('99.99', style: ViraType.displayLarge.copyWith(
                color: ViraColors.cyan, fontFamily: ViraType.mono, fontSize: 42,
              )),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text('%', style: ViraType.h3.copyWith(color: ViraColors.cyan)),
              ),
            ],
          ),
          Text('PLATFORM UPTIME · ALL REGIONS', style: ViraType.monoCaption),
          const SizedBox(height: ViraSpace.lg),
          Wrap(
            spacing: ViraSpace.sm,
            runSpacing: ViraSpace.sm,
            children: const [
              StatusPill(label: 'Kafka ✓', color: ViraColors.cyan),
              StatusPill(label: 'Redis ✓', color: ViraColors.statusOk),
              StatusPill(label: 'PostgreSQL ✓', color: ViraColors.statusOk),
              StatusPill(label: 'Failover <30s', color: ViraColors.statusWarn),
            ],
          ),
        ],
      ),
    );
  }

  Widget _servicesGrid() {
    final services = [
      ('Auth', '42ms', ViraColors.statusOk),
      ('Matching', '180ms', ViraColors.statusOk),
      ('Trip', '95ms', ViraColors.statusOk),
      ('Payment', '130ms', ViraColors.statusOk),
      ('Pricing', '312ms ⚠', ViraColors.statusWarn),
      ('Notifications', '55ms', ViraColors.statusOk),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: ViraSpace.sm,
      crossAxisSpacing: ViraSpace.sm,
      childAspectRatio: 2.6,
      children: services.map((s) {
        return ViraCard(
          padding: const EdgeInsets.symmetric(horizontal: ViraSpace.md, vertical: ViraSpace.sm),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: s.$3,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: s.$3.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: ViraSpace.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1, style: ViraType.monoValue.copyWith(fontSize: 11)),
                  Text(s.$2, style: ViraType.monoCaption.copyWith(
                    color: s.$3 == ViraColors.statusWarn ? ViraColors.statusWarn : ViraColors.platinum30,
                  )),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _gaugeCard(String value, double pct, Color color, String minLabel, String maxLabel) {
    return ViraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live', style: ViraType.body),
              Text(value, style: ViraType.monoValue.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: ViraSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: ViraColors.obsidian,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: ViraType.monoCaption),
              Text(maxLabel, style: ViraType.monoCaption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _latCard(String value, String label, Color color) {
    return ViraCard(
      padding: const EdgeInsets.symmetric(vertical: ViraSpace.md),
      child: Column(
        children: [
          Text(value, style: ViraType.monoValue.copyWith(color: color, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: ViraType.monoCaption),
        ],
      ),
    );
  }
}
