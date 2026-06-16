import 'package:flutter/material.dart';
import '../../core/theme/vira_colors.dart';
import '../../core/theme/vira_type.dart';
import '../../core/theme/vira_space.dart';
import '../models/geo_point.dart';

/// Compact pickup -> dropoff route display, used inside active dispatch
/// cards on Rider home and Courier job feed. Cyan dot = pickup (source of
/// truth / clinical), crimson dot = dropoff (urgency / destination).
class RouteTimeline extends StatelessWidget {
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final String? pickupEta;
  final String? dropoffEta;

  const RouteTimeline({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.pickupEta,
    this.dropoffEta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ViraSpace.md),
      decoration: BoxDecoration(
        color: ViraColors.obsidian,
        borderRadius: BorderRadius.circular(ViraRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            dotColor: ViraColors.cyan,
            label: pickup.label ?? 'Pickup',
            eta: pickupEta,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3.5),
            child: Container(width: 1, height: 18, color: ViraColors.platinum10),
          ),
          _row(
            dotColor: ViraColors.crimson,
            label: dropoff.label ?? 'Drop-off',
            eta: dropoffEta,
          ),
        ],
      ),
    );
  }

  Widget _row({required Color dotColor, required String label, String? eta}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: ViraSpace.sm),
        Expanded(
          child: Text(
            label,
            style: ViraType.body.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (eta != null)
          Text(
            eta,
            style: ViraType.monoCaption.copyWith(
              color: dotColor == ViraColors.crimson
                  ? ViraColors.crimson
                  : ViraColors.cyan,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
