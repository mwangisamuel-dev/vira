import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_mark.dart';
import '../../../shared/models/vira_enums.dart';

/// Entry point for all three sides of the marketplace. A single codebase,
/// single app store listing — role determines everything downstream, so
/// this choice (plus subsequent OTP + verification) is the only branch
/// point in the entire auth flow.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ViraSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const ViraMark(size: 56),
              const SizedBox(height: ViraSpace.lg),
              Text('VIRA', style: ViraType.displayLarge.copyWith(letterSpacing: 4)),
              const SizedBox(height: ViraSpace.xs),
              Row(
                children: [
                  Container(width: 24, height: 1, color: ViraColors.crimson),
                  const SizedBox(width: ViraSpace.sm),
                  Text(
                    'CRITICAL INFRASTRUCTURE',
                    style: ViraType.monoLabel.copyWith(color: ViraColors.platinum60),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Text('I am signing in as a...', style: ViraType.h2),
              const SizedBox(height: ViraSpace.xl),
              _RoleCard(
                icon: '🏥',
                title: 'Hospital / Facility',
                subtitle: 'Request blood, oxygen, samples & emergency transit',
                role: ViraRole.rider,
              ),
              const SizedBox(height: ViraSpace.md),
              _RoleCard(
                icon: '🏍',
                title: 'Courier',
                subtitle: 'Accept dispatches, ride, deliver — the frontline',
                role: ViraRole.courier,
              ),
              const SizedBox(height: ViraSpace.md),
              _RoleCard(
                icon: '📡',
                title: 'Dispatch Operations',
                subtitle: 'Fleet monitoring, overrides, system health',
                role: ViraRole.dispatch,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final ViraRole role;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ViraColors.obsidianSurface1,
      borderRadius: BorderRadius.circular(ViraRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(ViraRadius.lg),
        onTap: () => context.push('/auth/otp', extra: role),
        child: Container(
          padding: const EdgeInsets.all(ViraSpace.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ViraRadius.lg),
            border: Border.all(color: ViraColors.platinum10),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ViraColors.obsidianSurface2,
                  borderRadius: BorderRadius.circular(ViraRadius.md),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: ViraSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ViraType.h3),
                    const SizedBox(height: 2),
                    Text(subtitle, style: ViraType.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ViraColors.platinum30),
            ],
          ),
        ),
      ),
    );
  }
}
