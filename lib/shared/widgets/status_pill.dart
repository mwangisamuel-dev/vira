import 'package:flutter/material.dart';
import '../../core/theme/vira_colors.dart';
import '../../core/theme/vira_type.dart';
import '../../core/theme/vira_space.dart';

/// Pill-shaped status indicator. Used for "ON DUTY", priority badges
/// (CRITICAL/URGENT/SCHEDULED), and trip status throughout the app.
/// `pulse: true` adds the animated dot for live/active states.
class StatusPill extends StatefulWidget {
  final String label;
  final Color color;
  final bool pulse;

  const StatusPill({
    super.key,
    required this.label,
    this.color = ViraColors.crimson,
    this.pulse = false,
  });

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViraSpace.md,
        vertical: ViraSpace.xs,
      ),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ViraRadius.pill),
        border: Border.all(color: widget.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.pulse) ...[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(1 - t * 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: ViraSpace.sm),
          ],
          Text(
            widget.label,
            style: ViraType.badge.copyWith(color: widget.color),
          ),
        ],
      ),
    );
  }
}
