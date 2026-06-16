import 'package:flutter/material.dart';
import 'vira_colors.dart';

/// VIRA Typography — two families, deliberately:
///
/// - Inter: all human-facing copy (greetings, names, descriptions).
///   Humane, legible, doesn't feel cold despite the dark UI.
/// - JetBrains Mono: all SYSTEM/DATA copy — labels, timestamps, ETAs,
///   coordinates, status codes, metrics. This is what gives VIRA its
///   "elite operations console" feel rather than reading as a generic
///   consumer ride app. Use mono ANY time you're displaying a number,
///   a status, or a system-generated value.
class ViraType {
  ViraType._();

  static const String sans = 'Inter';
  static const String mono = 'JetBrainsMono';

  // ── Display / Hero ──
  static const TextStyle displayLarge = TextStyle(
    fontFamily: sans,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.02,
    color: ViraColors.platinum,
    height: 1.05,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: sans,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    color: ViraColors.platinum,
    height: 1.1,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: sans,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    color: ViraColors.platinum,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ViraColors.platinum,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: ViraColors.platinum,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ViraColors.platinum,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ViraColors.platinum60,
  );

  // ── System / Mono (labels, metrics, codes, timestamps) ──
  static const TextStyle monoLabel = TextStyle(
    fontFamily: mono,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: ViraColors.platinum30,
  );

  static const TextStyle monoValue = TextStyle(
    fontFamily: mono,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: ViraColors.platinum,
  );

  static const TextStyle monoValueLarge = TextStyle(
    fontFamily: mono,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.04,
    color: ViraColors.cyan,
  );

  static const TextStyle monoCaption = TextStyle(
    fontFamily: mono,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: ViraColors.platinum30,
  );

  // ── Badge / pill text ──
  static const TextStyle badge = TextStyle(
    fontFamily: mono,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: ViraColors.crimson,
  );
}
