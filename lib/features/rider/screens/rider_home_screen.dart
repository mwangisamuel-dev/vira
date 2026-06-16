import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../core/state/auth_provider.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../../shared/widgets/route_timeline.dart';
import '../../../shared/models/vira_enums.dart';
import '../../../shared/models/geo_point.dart';
import '../../trip/widgets/trip_state_tracker.dart';

/// Home dashboard for the Rider (hospital/facility) app. Surfaces the
/// single active dispatch prominently — in a medical context, a facility
/// almost always cares about "where is MY blood/oxygen right now" far
/// more than browsing a feed, so this screen is built around that one
/// active-trip card rather than a generic activity list.
class RiderHomeScreen extends ConsumerWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ViraSpace.lg),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.facilityName ?? 'Facility',
                      style: ViraType.h2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'FACILITY_ID · ${session?.facilityId ?? '—'}',
                      style: ViraType.monoCaption,
                    ),
                  ],
                ),
                const StatusPill(label: 'VERIFIED', color: ViraColors.cyan),
              ],
            ),
            const SizedBox(height: ViraSpace.xxl),

            // Active dispatch
            ViraCard(
              accentColor: ViraColors.crimson,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ViraColors.crimsonDim,
                              borderRadius: BorderRadius.circular(ViraRadius.sm),
                            ),
                            child: const Text('🩸', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: ViraSpace.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Blood Product · O-Neg', style: ViraType.h3),
                              Text(
                                '2 units · Cold chain',
                                style: ViraType.monoCaption,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const StatusPill(
                        label: 'CRITICAL',
                        color: ViraColors.crimson,
                        pulse: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: ViraSpace.lg),
                  const RouteTimeline(
                    pickup: _kKnhBloodBank,
                    dropoff: _kKenyattaIcu,
                    pickupEta: 'PICKED UP',
                    dropoffEta: '4 MIN',
                  ),
                  const SizedBox(height: ViraSpace.lg),
                  const TripStateTracker(status: TripStatus.arriving),
                  const SizedBox(height: ViraSpace.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/trip/demo-trip-001'),
                      child: const Text('Track Live'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ViraSpace.xl),

            Text('Request New Dispatch', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: ViraSpace.md,
              crossAxisSpacing: ViraSpace.md,
              childAspectRatio: 1.5,
              children: const [
                _CargoQuickAction(icon: '🩸', label: 'Blood Product'),
                _CargoQuickAction(icon: '🫁', label: 'Oxygen'),
                _CargoQuickAction(icon: '🧪', label: 'Lab Sample'),
                _CargoQuickAction(icon: '💊', label: 'Medication'),
              ],
            ),
            const SizedBox(height: ViraSpace.xl),

            Text('Recent Activity', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),
            ViraCard(
              child: Column(
                children: [
                  _historyRow('🫁', 'Oxygen × 2', 'Completed · 09:42', done: true),
                  const Divider(height: ViraSpace.xl),
                  _historyRow('🧪', 'Lab Sample Batch #1042', 'Completed · Yesterday', done: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(String icon, String title, String meta, {bool done = false}) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: ViraSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ViraType.body.copyWith(fontWeight: FontWeight.w600)),
              Text(meta, style: ViraType.monoCaption),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: ViraColors.statusOk, size: 18),
      ],
    );
  }
}

class _CargoQuickAction extends StatelessWidget {
  final String icon;
  final String label;
  const _CargoQuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ViraCard(
      onTap: () => context.push('/rider/new-request'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: ViraSpace.sm),
          Text(label, style: ViraType.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// Placeholder geo points for the demo card — replace with live trip data
// from tripProvider once the backend is wired up.
const _kKnhBloodBank = GeoPoint(lat: -1.3007, lng: 36.8073, label: 'KNH Blood Bank');
const _kKenyattaIcu = GeoPoint(lat: -1.2989, lng: 36.8095, label: 'Kenyatta ICU');
