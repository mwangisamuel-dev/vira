import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';

/// Job feed — couriers accept dispatches here. Sorted by priority tier
/// first (CRITICAL always surfaces above URGENT/SCHEDULED regardless of
/// distance), since the whole premise of the platform is that medical
/// urgency outranks courier convenience.
class JobFeedScreen extends StatelessWidget {
  const JobFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      appBar: AppBar(title: const Text('Available Jobs')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ViraSpace.lg),
          children: [
            _JobCard(
              icon: '🩸',
              title: 'Blood Product · O-Neg',
              route: 'KNH Blood Bank → Agha Khan ICU',
              distance: '3.2km',
              priority: 'CRITICAL',
              priorityColor: ViraColors.crimson,
              fare: '850',
              onAccept: () => context.push('/trip/demo-trip-001'),
            ),
            const SizedBox(height: ViraSpace.md),
            _JobCard(
              icon: '🫁',
              title: 'Oxygen Cylinder × 2',
              route: 'Nairobi West Clinic → Mbagathi Hospital',
              distance: '5.6km',
              priority: 'URGENT',
              priorityColor: ViraColors.statusWarn,
              fare: '650',
              onAccept: () => context.push('/trip/demo-trip-002'),
            ),
            const SizedBox(height: ViraSpace.md),
            _JobCard(
              icon: '🧪',
              title: 'Lab Sample Batch #1042',
              route: 'Aga Khan Lab → Pathologists Lancet',
              distance: '1.8km',
              priority: 'SCHEDULED',
              priorityColor: ViraColors.cyan,
              fare: '400',
              onAccept: () => context.push('/trip/demo-trip-003'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String icon;
  final String title;
  final String route;
  final String distance;
  final String priority;
  final Color priorityColor;
  final String fare;
  final VoidCallback onAccept;

  const _JobCard({
    required this.icon,
    required this.title,
    required this.route,
    required this.distance,
    required this.priority,
    required this.priorityColor,
    required this.fare,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return ViraCard(
      accentColor: priorityColor,
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
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(ViraRadius.sm),
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: ViraSpace.md),
                  Text(title, style: ViraType.h3),
                ],
              ),
              StatusPill(label: priority, color: priorityColor),
            ],
          ),
          const SizedBox(height: ViraSpace.md),
          Text(route, style: ViraType.bodySmall),
          const SizedBox(height: ViraSpace.md),
          Row(
            children: [
              Icon(Icons.near_me, size: 14, color: ViraColors.platinum30),
              const SizedBox(width: 4),
              Text(distance, style: ViraType.monoCaption),
              const SizedBox(width: ViraSpace.lg),
              const Icon(Icons.payments, size: 14, color: ViraColors.platinum30),
              const SizedBox(width: 4),
              Text('KES $fare', style: ViraType.monoCaption.copyWith(color: ViraColors.cyan)),
            ],
          ),
          const SizedBox(height: ViraSpace.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: priorityColor == ViraColors.crimson
                    ? ViraColors.crimson
                    : ViraColors.obsidianSurface2,
                foregroundColor: priorityColor == ViraColors.crimson
                    ? ViraColors.platinum
                    : priorityColor,
              ),
              child: const Text('Accept Dispatch'),
            ),
          ),
        ],
      ),
    );
  }
}
