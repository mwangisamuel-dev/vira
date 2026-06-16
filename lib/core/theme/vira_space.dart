/// VIRA spatial system — 4px base unit.
/// Consistent spacing keeps the dense, data-heavy dispatch screens from
/// feeling cluttered. Always pull from here rather than hardcoding values.
class ViraSpace {
  ViraSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class ViraRadius {
  ViraRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Standard glow shadows used to give crimson/cyan elements their
/// "active system" feel against the obsidian canvas. Use sparingly —
/// glow signals state (active, live, alert), not decoration.
class ViraElevation {
  ViraElevation._();
}
