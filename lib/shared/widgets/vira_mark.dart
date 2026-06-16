import 'package:flutter/material.dart';
import '../../core/theme/vira_colors.dart';

/// Renders the VIRA "V" mark to match the actual brand assets supplied
/// (logo.png / favicons.png) — NOT the favicon description in the original
/// architecture brief, which described a different left-wing/right-wing-slash
/// construction. The real mark is two overlapping V-strokes:
///
///   - Left stroke: navy/obsidian-tone, thinner, top-left down to the point.
///   - Right stroke: crimson, a wider diagonal slab from top-right down to
///     the same point, with a sharp diagonal notch cut into its lower-left
///     edge (the "slashed" look in the source logo).
///   - A short cyan heartbeat pulse crosses horizontally where the two
///     strokes meet, with a small triangular wing accent.
///
/// `full` (default) reproduces the two-tone lockup mark seen in logo.png.
/// `simplified` reproduces the single-color favicon mark (crimson only,
/// no navy stroke, no pulse line) — use this for app icons and any context
/// where the mark needs to read at very small sizes.
/// `statusDot` adds the small cyan dot at the top-right tip, as seen on
/// the app-icon variants in favicons.png.
class ViraMark extends StatelessWidget {
  final double size;
  final bool simplified;
  final bool statusDot;
  final Color? overrideColor; // forces a single flat color (e.g. platinum on dark)

  const ViraMark({
    super.key,
    this.size = 32,
    this.simplified = false,
    this.statusDot = false,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ViraMarkPainter(
          simplified: simplified,
          statusDot: statusDot,
          overrideColor: overrideColor,
        ),
      ),
    );
  }
}

class _ViraMarkPainter extends CustomPainter {
  final bool simplified;
  final bool statusDot;
  final Color? overrideColor;

  _ViraMarkPainter({
    required this.simplified,
    required this.statusDot,
    this.overrideColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final navyColor = overrideColor ?? const Color(0xFF0B1226);
    final crimsonColor = overrideColor ?? ViraColors.crimson;
    final cyanColor = overrideColor ?? ViraColors.cyan;

    // ── Left stroke (navy in full mode, omitted in simplified favicon mode) ──
    // A V-arm running from upper-left down to the central point, with a
    // slight forward lean matching the source mark.
    if (!simplified) {
      final leftStroke = Path()
        ..moveTo(w * 0.10, h * 0.22)
        ..lineTo(w * 0.30, h * 0.22)
        ..lineTo(w * 0.50, h * 0.66)
        ..lineTo(w * 0.40, h * 0.86)
        ..close();
      canvas.drawPath(leftStroke, Paint()..color = navyColor);
    } else {
      // Favicon mark's left arm is thinner and fully crimson, sharper point.
      final leftStrokeSimple = Path()
        ..moveTo(w * 0.16, h * 0.24)
        ..lineTo(w * 0.34, h * 0.24)
        ..lineTo(w * 0.50, h * 0.62)
        ..lineTo(w * 0.42, h * 0.78)
        ..close();
      canvas.drawPath(leftStrokeSimple, Paint()..color = crimsonColor);
    }

    // ── Right stroke (crimson slab with diagonal notch) ──
    // Wide diagonal slab from top-right down to the V point, with a
    // triangular notch cut from its lower-left edge — this is what gives
    // the mark its "slashed" velocity look in both full and favicon forms.
    final rightOuter = Path()
      ..moveTo(w * 0.40, h * 0.86)
      ..lineTo(w * 0.50, h * 0.66)
      ..lineTo(w * 0.86, h * 0.14)
      ..lineTo(w * 0.66, h * 0.14)
      ..lineTo(w * 0.46, h * 0.50)
      ..close();
    canvas.drawPath(rightOuter, Paint()..color = crimsonColor);

    // Notch: a thin dark sliver cut diagonally into the right stroke's
    // lower portion, matching the gap visible in the source logo.
    final notch = Path()
      ..moveTo(w * 0.47, h * 0.58)
      ..lineTo(w * 0.53, h * 0.50)
      ..lineTo(w * 0.50, h * 0.66)
      ..lineTo(w * 0.44, h * 0.74)
      ..close();
    canvas.drawPath(notch, Paint()..color = const Color(0xFF000000).withOpacity(0.55));

    // ── Heartbeat pulse line (full mode only) ──
    if (!simplified) {
      final pulsePaint = Paint()
        ..color = cyanColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final pulse = Path()
        ..moveTo(w * 0.08, h * 0.46)
        ..lineTo(w * 0.26, h * 0.46)
        ..lineTo(w * 0.31, h * 0.30)
        ..lineTo(w * 0.37, h * 0.58)
        ..lineTo(w * 0.41, h * 0.46)
        ..lineTo(w * 0.50, h * 0.46);
      canvas.drawPath(pulse, pulsePaint);

      // Small triangular wing accent to the right of the pulse, echoing
      // the source mark's arrow-like flourish at the crossing point.
      final wing = Path()
        ..moveTo(w * 0.50, h * 0.41)
        ..lineTo(w * 0.60, h * 0.46)
        ..lineTo(w * 0.50, h * 0.51)
        ..close();
      canvas.drawPath(wing, Paint()..color = cyanColor.withOpacity(0.85));
    }

    // ── Status dot (app-icon variant only) ──
    if (statusDot) {
      final dotCenter = Offset(w * 0.84, h * 0.13);
      final dotRadius = w * 0.075;
      canvas.drawCircle(
        dotCenter,
        dotRadius * 1.8,
        Paint()
          ..color = cyanColor.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(dotCenter, dotRadius, Paint()..color = cyanColor);
    }
  }

  @override
  bool shouldRepaint(covariant _ViraMarkPainter oldDelegate) =>
      oldDelegate.simplified != simplified ||
      oldDelegate.statusDot != statusDot ||
      oldDelegate.overrideColor != overrideColor;
}
