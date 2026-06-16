import 'package:flutter/material.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../shared/models/vira_enums.dart';

/// Visualizes the rigid 5-stage trip state machine:
/// REQUESTED -> MATCHED -> ARRIVING -> IN_PROGRESS -> COMPLETED.
///
/// Renders identically across Rider, Courier, and Dispatch surfaces —
/// trust in the platform depends on every party seeing the same state
/// at the same time, so this widget takes TripStatus directly rather
/// than letting each feature reimplement its own version.
class TripStateTracker extends StatelessWidget {
  final TripStatus status;

  const TripStateTracker({super.key, required this.status});

  static const _steps = [
    (TripStatus.requested, 'Requested'),
    (TripStatus.matched, 'Matched'),
    (TripStatus.arriving, 'Arriving'),
    (TripStatus.inProgress, 'In Transit'),
    (TripStatus.completed, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = status.stepIndex;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final connectorIndex = i ~/ 2;
          final isDone = connectorIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.only(bottom: 18),
              color: isDone ? ViraColors.cyan : ViraColors.platinum10,
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final (stepStatus, label) = _steps[stepIndex];
        final isDone = stepIndex < currentIndex;
        final isActive = stepIndex == currentIndex;

        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? ViraColors.crimson
                    : ViraColors.obsidianSurface2,
                border: Border.all(
                  color: isDone
                      ? ViraColors.cyan
                      : isActive
                          ? ViraColors.crimson
                          : ViraColors.platinum10,
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: ViraColors.crimsonGlow,
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                isDone ? '✓' : isActive ? '→' : '·',
                style: ViraType.monoValue.copyWith(
                  fontSize: 12,
                  color: isDone || isActive
                      ? (isActive ? ViraColors.platinum : ViraColors.cyan)
                      : ViraColors.platinum30,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: ViraType.monoCaption.copyWith(
                  color: isActive
                      ? ViraColors.crimson
                      : isDone
                          ? ViraColors.cyan
                          : ViraColors.platinum30,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
