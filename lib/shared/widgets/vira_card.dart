import 'package:flutter/material.dart';
import '../../core/theme/vira_colors.dart';
import '../../core/theme/vira_space.dart';

/// Standard card surface used throughout the app. `accentColor` draws a
/// thin top border glow — use crimson for urgent/active cargo, cyan for
/// informational/health content, omit for neutral content.
class ViraCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ViraCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(ViraSpace.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: ViraColors.obsidianSurface1,
        borderRadius: BorderRadius.circular(ViraRadius.lg),
        border: Border.all(
          color: accentColor?.withOpacity(0.4) ?? ViraColors.platinum10,
        ),
        boxShadow: accentColor != null
            ? [
                BoxShadow(
                  color: accentColor!.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ViraRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ViraRadius.lg),
        child: card,
      ),
    );
  }
}
