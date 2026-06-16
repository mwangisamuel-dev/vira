import 'package:flutter/material.dart';

/// VIRA Brand Color System — Premium Dark Mode.
///
/// Source of truth: VIRA brand & UX blueprint.
/// These four colors are the ENTIRE palette. Do not introduce new brand
/// colors without updating this file — every screen in Rider, Courier,
/// and Dispatch derives from these tokens.
class ViraColors {
  ViraColors._();

  /// Midnight Obsidian — master canvas tone.
  /// Projects structural stability, seriousness, advanced technical infra.
  static const Color obsidian = Color(0xFF0B0C10);

  /// Slightly lifted surface tones, derived from obsidian for card layering.
  /// Not in the original spec as named colors, but needed for elevation —
  /// kept strictly monochrome (no hue shift) so the brand palette stays pure.
  static const Color obsidianSurface1 = Color(0xFF111318);
  static const Color obsidianSurface2 = Color(0xFF181A21);
  static const Color obsidianSurface3 = Color(0xFF1E2028);

  /// Vivid Crimson — primary operational accent.
  /// Used STRICTLY for: emergency alerts, high-priority trip routing,
  /// active dispatch components. Do not use for decorative purposes —
  /// overuse dilutes its meaning as "this needs attention now."
  static const Color crimson = Color(0xFFFF1E27);
  static const Color crimsonDim = Color(0x26FF1E27); // 15% opacity wash
  static const Color crimsonGlow = Color(0x59FF1E27); // 35% opacity glow

  /// Trusted Cyan — medical health-tech accent.
  /// Sterile, clean clinical authority: user details, medical item
  /// checklists, network connection nodes, system health indicators.
  static const Color cyan = Color(0xFF00F2FE);
  static const Color cyanDim = Color(0x1F00F2FE); // 12% opacity wash
  static const Color cyanGlow = Color(0x4D00F2FE); // 30% opacity glow

  /// Platinum White — high-contrast text.
  static const Color platinum = Color(0xFFF8F9FA);
  static const Color platinum60 = Color(0x99F8F9FA);
  static const Color platinum30 = Color(0x4DF8F9FA);
  static const Color platinum10 = Color(0x12F8F9FA);

  /// Semantic status colors — NOT part of the core 4-color brand system,
  /// but required for system health / SLA states (service up/warn/down).
  /// Kept desaturated relative to crimson/cyan so they don't compete with
  /// the brand accents for visual priority.
  static const Color statusOk = Color(0xFF00E676);
  static const Color statusWarn = Color(0xFFFFD600);
  static const Color statusCrit = crimson; // critical reuses brand crimson intentionally
}
