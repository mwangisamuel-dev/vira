import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../core/state/auth_provider.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/widgets/status_pill.dart';

/// Courier home — the frontline. On-duty toggle is the single most
/// important control on this screen: going on-duty is what starts the
/// background location stream (see LocationService) and makes this
/// courier eligible for matching. Everything else is secondary.
class CourierHomeScreen extends ConsumerStatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  ConsumerState<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends ConsumerState<CourierHomeScreen> {
  bool _onDuty = true;

  @override
  Widget build(BuildContext context) {
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
                    Text('Hey, ${session?.displayName ?? 'Courier'}', style: ViraType.h2),
                    const SizedBox(height: 2),
                    Text(session?.phone ?? '', style: ViraType.monoCaption),
                  ],
                ),
                StatusPill(
                  label: _onDuty ? 'ON DUTY' : 'OFFLINE',
                  color: _onDuty ? ViraColors.crimson : ViraColors.platinum30,
                  pulse: _onDuty,
                ),
              ],
            ),
            const SizedBox(height: ViraSpace.xl),

            // On-duty toggle card
            ViraCard(
              accentColor: _onDuty ? ViraColors.crimson : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _onDuty ? 'You\'re visible to dispatch' : 'You\'re offline',
                          style: ViraType.h3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _onDuty
                              ? 'Location streaming every 5s'
                              : 'Go on-duty to receive jobs',
                          style: ViraType.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _onDuty,
                    activeColor: ViraColors.crimson,
                    onChanged: (v) => setState(() => _onDuty = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ViraSpace.lg),

            // Stats row
            Row(
              children: [
                Expanded(child: _statCard('7', 'Trips Today', ViraColors.crimson)),
                const SizedBox(width: ViraSpace.sm),
                Expanded(
                  child: _statCard(
                    '3.4k',
                    'KES Earned',
                    ViraColors.cyan,
                    onTap: () => context.push('/wallet'),
                  ),
                ),
                const SizedBox(width: ViraSpace.sm),
                Expanded(child: _statCard('4.9', '★ Rating', ViraColors.statusWarn)),
              ],
            ),
            const SizedBox(height: ViraSpace.xl),

            Text('Available Jobs', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),

            ViraCard(
              accentColor: ViraColors.crimson,
              onTap: () => context.push('/courier/jobs'),
              child: Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Blood · KNH → Agha Khan', style: ViraType.body.copyWith(fontWeight: FontWeight.w700)),
                        Text('3.2km · CRITICAL', style: ViraType.monoCaption.copyWith(color: ViraColors.crimson)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: ViraColors.platinum30),
                ],
              ),
            ),
            const SizedBox(height: ViraSpace.sm),
            ViraCard(
              onTap: () => context.push('/courier/jobs'),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ViraColors.cyanDim,
                      borderRadius: BorderRadius.circular(ViraRadius.sm),
                    ),
                    child: const Text('🧪', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: ViraSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lab Sample Batch #1042', style: ViraType.body.copyWith(fontWeight: FontWeight.w700)),
                        Text('1.8km · SCHEDULED', style: ViraType.monoCaption.copyWith(color: ViraColors.cyan)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: ViraColors.platinum30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, {VoidCallback? onTap}) {
    return ViraCard(
      padding: const EdgeInsets.symmetric(vertical: ViraSpace.md, horizontal: ViraSpace.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: ViraType.monoValueLarge.copyWith(color: color, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: ViraType.monoCaption),
        ],
      ),
    );
  }
}
