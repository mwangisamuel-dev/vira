/// The three sides of the VIRA marketplace.
/// Drives routing (core/router), not just display logic — a Rider account
/// must never be able to reach Courier or Dispatch routes, and vice versa.
enum ViraRole {
  rider, // hospitals, clinics, blood banks — cargo requesters
  courier, // motorcycle riders — the frontline
  dispatch, // ops/admin — fleet monitoring & overrides
}

/// Priority tier of a cargo manifest. This is the field that should have
/// existed in the original Trips schema but didn't — it's what
/// differentiates "routine sample run" from "blood for a patient in active
/// surgery," and it drives matching radius, pricing override, and whether
/// Dispatch gets auto-escalated.
enum PriorityTier {
  critical, // <90s unmatched -> auto-escalate to Dispatch
  urgent, // standard emergency restock
  scheduled, // routine, batchable, lowest cost tier
}

extension PriorityTierX on PriorityTier {
  String get label => switch (this) {
        PriorityTier.critical => 'CRITICAL',
        PriorityTier.urgent => 'URGENT',
        PriorityTier.scheduled => 'SCHEDULED',
      };

  /// Match SLA in seconds, per tier.
  int get matchSlaSeconds => switch (this) {
        PriorityTier.critical => 90,
        PriorityTier.urgent => 300,
        PriorityTier.scheduled => 1800,
      };
}

/// What's actually moving. Cargo — not the rider — is the primary entity
/// in this domain. A trip without a typed, specced cargo manifest is
/// meaningless in a medical logistics context.
enum CargoType {
  bloodProduct,
  oxygenCylinder,
  labSample,
  medication,
  firstResponder,
  other,
}

extension CargoTypeX on CargoType {
  String get label => switch (this) {
        CargoType.bloodProduct => 'Blood Product',
        CargoType.oxygenCylinder => 'Oxygen Cylinder',
        CargoType.labSample => 'Lab Sample',
        CargoType.medication => 'Medication',
        CargoType.firstResponder => 'First Responder',
        CargoType.other => 'Other',
      };

  /// Whether this cargo type requires temperature-controlled transit.
  /// Surfaces as a hard filter when matching couriers — a courier whose
  /// vehicle_info doesn't list refrigeration capability cannot be matched
  /// to a coldChainRequired manifest, regardless of proximity.
  bool get typicallyColdChain =>
      this == CargoType.bloodProduct || this == CargoType.labSample;
}

/// Trip lifecycle state machine. Strictly linear, no skipping stages —
/// matches the "rigid, deterministic finite state machine" requirement.
enum TripStatus {
  requested,
  matched,
  arriving,
  inProgress,
  completed,
  cancelled, // not in the original 5-stage spec, but a real system needs
  // an explicit terminal failure state rather than letting trips
  // hang indefinitely — cancellation must still be auditable.
}

extension TripStatusX on TripStatus {
  String get label => switch (this) {
        TripStatus.requested => 'Requested',
        TripStatus.matched => 'Matched',
        TripStatus.arriving => 'Arriving',
        TripStatus.inProgress => 'In Progress',
        TripStatus.completed => 'Completed',
        TripStatus.cancelled => 'Cancelled',
      };

  int get stepIndex => switch (this) {
        TripStatus.requested => 0,
        TripStatus.matched => 1,
        TripStatus.arriving => 2,
        TripStatus.inProgress => 3,
        TripStatus.completed => 4,
        TripStatus.cancelled => -1,
      };
}

/// Chain-of-custody event types. Required for hospital trust and Kenya
/// Data Protection Act compliance — every handoff of medical cargo needs
/// an immutable, geo-tagged, timestamped record independent of trip status.
enum CustodyEventType {
  manifestCreated,
  courierAssigned,
  pickupConfirmed,
  inTransitCheckpoint,
  deliveryConfirmed,
  signatureCaptured,
  photoCaptured,
}
