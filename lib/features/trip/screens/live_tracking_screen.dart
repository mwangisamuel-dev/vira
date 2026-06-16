import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/vira_enums.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/models/cargo_manifest.dart';
import '../providers/trip_providers.dart';
import '../widgets/trip_state_tracker.dart';

/// Shared live tracking screen — same widget tree regardless of whether
/// the viewer is the requesting facility, the courier, or a dispatch
/// operator watching for SLA breach. Identical state across all three
/// is the trust mechanism; this screen is where that promise is kept
/// or broken.
///
/// Reads from `tripProvider(tripId)`, which seeds from a REST snapshot
/// and then follows the 'trip.<id>' WebSocket topic for live updates —
/// see lib/features/trip/providers/trip_providers.dart. Until a real
/// backend is wired up, the `error`/`loading` branches fall back to a
/// representative demo trip so the screen is still useful to look at
/// during scaffold review; swap that fallback out once /v1/trips/:id
/// is live.
///
/// Map rendering is a placeholder pending google_maps_flutter API key
/// wiring — the live courier marker would update from the same
/// trip stream's `courierLiveLocation` field.
class LiveTrackingScreen extends ConsumerWidget {
  final String tripId;
  const LiveTrackingScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));

    final shortId = tripId.length > 6 ? tripId.substring(tripId.length - 6) : tripId;

    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      appBar: AppBar(
        title: Text('Trip #$shortId'),
      ),
      body: SafeArea(
        child: tripAsync.when(
          data: (trip) => _TrackingBody(trip: trip),
          loading: () => const _TrackingBody(trip: null, loading: true),
          // No live backend yet in this scaffold — show the demo trip
          // rather than an error screen so the UI remains reviewable.
          error: (err, _) => _TrackingBody(trip: _demoTrip(tripId)),
        ),
      ),
    );
  }

  static Trip _demoTrip(String id) {
    return Trip(
      id: id,
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
      pickup: const GeoPoint(lat: -1.3007, lng: 36.8073, label: 'KNH Blood Bank'),
      dropoff: const GeoPoint(lat: -1.2989, lng: 36.8095, label: 'Kenyatta ICU'),
      requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      matchedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      courierId: 'courier-demo',
      courierName: 'James K.',
      courierPhone: '+254700000000',
      etaSeconds: 240,
      fareKes: 850,
    );
  }
}

class _TrackingBody extends StatelessWidget {
  final Trip? trip;
  final bool loading;

  const _TrackingBody({required this.trip, this.loading = false});

  @override
  Widget build(BuildContext context) {
    if (loading && trip == null) {
      return const Center(child: CircularProgressIndicator(color: ViraColors.cyan));
    }

    final t = trip!;
    final priorityColor = switch (t.manifest.priority) {
      PriorityTier.critical => ViraColors.crimson,
      PriorityTier.urgent => ViraColors.statusWarn,
      PriorityTier.scheduled => ViraColors.cyan,
    };

    return ListView(
      padding: const EdgeInsets.all(ViraSpace.lg),
      children: [
        // Map placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: ViraColors.obsidianSurface1,
            borderRadius: BorderRadius.circular(ViraRadius.lg),
            border: Border.all(color: ViraColors.platinum10),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏍', style: TextStyle(fontSize: 28)),
              const SizedBox(height: ViraSpace.sm),
              Text(
                t.courierLiveLocation != null ? 'LIVE MAP · GPS_SYNC' : 'MAP · AWAITING_GPS',
                style: ViraType.monoCaption,
              ),
            ],
          ),
        ),
        const SizedBox(height: ViraSpace.xl),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${t.manifest.type.label} · ${t.manifest.quantity} ${t.manifest.unit}',
              style: ViraType.h3,
            ),
            StatusPill(
              label: t.manifest.priority.label,
              color: priorityColor,
              pulse: t.manifest.priority == PriorityTier.critical,
            ),
          ],
        ),
        const SizedBox(height: ViraSpace.xl),

        TripStateTracker(status: t.status),
        const SizedBox(height: ViraSpace.xl),

        ViraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Courier', style: ViraType.monoLabel),
              const SizedBox(height: ViraSpace.sm),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: ViraColors.obsidianSurface2,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🏍'),
                  ),
                  const SizedBox(width: ViraSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.courierName ?? 'Awaiting match',
                          style: ViraType.body.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (t.etaSeconds != null)
                          Text('ETA ${(t.etaSeconds! / 60).ceil()} min', style: ViraType.monoCaption),
                      ],
                    ),
                  ),
                  if (t.courierPhone != null)
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call, color: ViraColors.cyan),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ViraSpace.xl),

        Text('Chain of Custody', style: ViraType.h3),
        const SizedBox(height: ViraSpace.md),
        ViraCard(
          child: Column(
            children: _custodyRowsFor(t),
          ),
        ),
      ],
    );
  }

  /// Until /v1/trips/:id/custody-events is wired up, derive a plausible
  /// custody trail from the trip's current status so the screen still
  /// demonstrates the feature. Replace with a real custodyEventsProvider
  /// once the backend ships that endpoint.
  List<Widget> _custodyRowsFor(Trip t) {
    final stepIndex = t.status.stepIndex;
    final steps = [
      ('Manifest Created', stepIndex >= 0),
      ('Courier Assigned${t.courierName != null ? ' · ${t.courierName}' : ''}', stepIndex >= 1),
      ('Pickup Confirmed · ${t.pickup.label ?? 'Pickup'}', stepIndex >= 2),
      ('In Transit · approaching ${t.dropoff.label ?? 'destination'}', stepIndex >= 3),
      ('Delivery Confirmation', stepIndex >= 4),
    ];

    final widgets = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final (label, done) = steps[i];
      final active = !done && (i == 0 || steps[i - 1].$2);
      widgets.add(_custodyRow(label, done ? '✓' : (active ? 'now' : '—'), done: done, active: active));
      if (i != steps.length - 1) widgets.add(_custodyDivider());
    }
    return widgets;
  }

  Widget _custodyDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: ViraSpace.sm),
        child: Divider(height: 1),
      );

  Widget _custodyRow(String label, String time, {required bool done, bool active = false}) {
    final color = done
        ? ViraColors.cyan
        : active
            ? ViraColors.crimson
            : ViraColors.platinum30;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: (done || active)
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(width: ViraSpace.md),
        Expanded(
          child: Text(
            label,
            style: ViraType.body.copyWith(
              fontSize: 12,
              color: done || active ? ViraColors.platinum : ViraColors.platinum60,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(time, style: ViraType.monoCaption),
      ],
    );
  }
}
