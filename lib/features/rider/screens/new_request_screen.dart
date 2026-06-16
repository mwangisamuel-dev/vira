import 'package:flutter/material.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../shared/widgets/vira_card.dart';
import '../../../shared/models/vira_enums.dart';

/// Cargo manifest builder — the form that creates a CargoManifest BEFORE
/// any trip exists. Priority tier and cold-chain are first-class fields
/// here, not buried metadata, because they're what the matching service
/// uses to set SLA and filter eligible couriers.
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  CargoType _selectedType = CargoType.bloodProduct;
  PriorityTier _selectedPriority = PriorityTier.critical;
  int _quantity = 2;
  bool _coldChain = true;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coldChain = _selectedType.typicallyColdChain;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      appBar: AppBar(title: const Text('New Dispatch Request')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ViraSpace.lg),
          children: [
            Text('Cargo Type', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),
            Wrap(
              spacing: ViraSpace.sm,
              runSpacing: ViraSpace.sm,
              children: CargoType.values.map((type) {
                final selected = type == _selectedType;
                return ChoiceChip(
                  label: Text(type.label),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedType = type;
                    _coldChain = type.typicallyColdChain;
                  }),
                  selectedColor: ViraColors.cyanDim,
                  backgroundColor: ViraColors.obsidianSurface2,
                  labelStyle: ViraType.body.copyWith(
                    color: selected ? ViraColors.cyan : ViraColors.platinum60,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected ? ViraColors.cyan : ViraColors.platinum10,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: ViraSpace.xxl),

            Text('Priority Tier', style: ViraType.h3),
            const SizedBox(height: ViraSpace.sm),
            Text(
              'CRITICAL dispatches auto-escalate to Dispatch Ops if unmatched within 90s.',
              style: ViraType.bodySmall,
            ),
            const SizedBox(height: ViraSpace.md),
            Column(
              children: PriorityTier.values.map((tier) {
                final selected = tier == _selectedPriority;
                final color = switch (tier) {
                  PriorityTier.critical => ViraColors.crimson,
                  PriorityTier.urgent => ViraColors.statusWarn,
                  PriorityTier.scheduled => ViraColors.cyan,
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: ViraSpace.sm),
                  child: ViraCard(
                    accentColor: selected ? color : null,
                    onTap: () => setState(() => _selectedPriority = tier),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ViraSpace.lg,
                      vertical: ViraSpace.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? color : ViraColors.platinum30,
                              width: 2,
                            ),
                            color: selected ? color : Colors.transparent,
                          ),
                        ),
                        const SizedBox(width: ViraSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tier.label, style: ViraType.h3.copyWith(fontSize: 14)),
                              Text(
                                'Match SLA: ${tier.matchSlaSeconds}s',
                                style: ViraType.monoCaption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: ViraSpace.xxl),

            Text('Quantity', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: ViraColors.platinum60,
                ),
                Text('$_quantity', style: ViraType.monoValueLarge),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: ViraColors.cyan,
                ),
              ],
            ),
            const SizedBox(height: ViraSpace.lg),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Cold Chain Required', style: ViraType.body),
              subtitle: Text(
                'Only couriers with refrigerated transport will be matched',
                style: ViraType.bodySmall,
              ),
              value: _coldChain,
              activeColor: ViraColors.cyan,
              onChanged: (v) => setState(() => _coldChain = v),
            ),
            const SizedBox(height: ViraSpace.lg),

            Text('Notes', style: ViraType.h3),
            const SizedBox(height: ViraSpace.md),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: ViraType.body,
              decoration: const InputDecoration(
                hintText: 'e.g. O-Neg, cross-matched for patient in Theatre 3',
              ),
            ),
            const SizedBox(height: ViraSpace.xxxl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPriority == PriorityTier.critical
                      ? ViraColors.crimson
                      : null,
                ),
                child: Text(
                  _selectedPriority == PriorityTier.critical
                      ? 'Dispatch Now — CRITICAL'
                      : 'Submit Request',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    // Builds the CargoManifest payload and POSTs to /v1/trips via
    // ApiClient.requestTrip(). Wiring to a live tripProvider happens once
    // the backend contract is available — left as a stub here so this
    // screen compiles standalone within the scaffold.
    Navigator.of(context).pop();
  }
}
