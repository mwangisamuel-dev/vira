import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/vira_colors.dart';
import '../../../core/theme/vira_type.dart';
import '../../../core/theme/vira_space.dart';
import '../../../core/state/auth_provider.dart';
import '../../../core/state/vira_session.dart';
import '../../../shared/models/vira_enums.dart';

/// Phone OTP entry, branching by role afterward:
/// - rider: goes to facility verification before reaching home (a
///   facility must be institutionally verified before it can request
///   blood/oxygen dispatch — this is a fraud and safety boundary, not
///   just a formality).
/// - courier/dispatch: goes straight to onboarding/home.
class OtpScreen extends ConsumerStatefulWidget {
  final ViraRole role;
  const OtpScreen({super.key, required this.role});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  bool _otpSent = false;
  bool _verifying = false;

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: ViraType.h2.copyWith(fontFamily: ViraType.mono),
      decoration: BoxDecoration(
        color: ViraColors.obsidianSurface2,
        borderRadius: BorderRadius.circular(ViraRadius.md),
        border: Border.all(color: ViraColors.platinum10),
      ),
    );

    return Scaffold(
      backgroundColor: ViraColors.obsidian,
      appBar: AppBar(title: Text(_otpSent ? 'Verify Code' : 'Sign In')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ViraSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_otpSent) ...[
                Text('Enter your phone number', style: ViraType.h2),
                const SizedBox(height: ViraSpace.sm),
                Text(
                  'We\'ll send a verification code via SMS',
                  style: ViraType.bodySmall,
                ),
                const SizedBox(height: ViraSpace.xxl),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: ViraType.bodyLarge,
                  decoration: const InputDecoration(
                    prefixText: '+254 ',
                    hintText: '7XX XXX XXX',
                  ),
                ),
                const SizedBox(height: ViraSpace.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _otpSent = true),
                    child: const Text('Send Code'),
                  ),
                ),
              ] else ...[
                Text('Enter the 6-digit code', style: ViraType.h2),
                const SizedBox(height: ViraSpace.sm),
                Text(
                  'Sent to +254 ${_phoneController.text}',
                  style: ViraType.bodySmall,
                ),
                const SizedBox(height: ViraSpace.xxl),
                Pinput(
                  length: 6,
                  defaultPinTheme: pinTheme,
                  focusedPinTheme: pinTheme.copyWith(
                    decoration: pinTheme.decoration!.copyWith(
                      border: Border.all(color: ViraColors.cyan, width: 1.5),
                    ),
                  ),
                  onCompleted: (pin) => _verify(pin),
                ),
                const SizedBox(height: ViraSpace.xl),
                if (_verifying)
                  const Center(
                    child: CircularProgressIndicator(color: ViraColors.cyan),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify(String pin) async {
    setState(() => _verifying = true);

    // Stub: in production this calls /v1/auth/verify-otp and receives
    // a session token + role-scoped profile back from the Auth service.
    await Future.delayed(const Duration(milliseconds: 600));

    final session = ViraSession(
      userId: 'demo-user-001',
      displayName: widget.role == ViraRole.rider ? 'Kenyatta Hospital' : 'James K.',
      phone: '+254${_phoneController.text}',
      role: widget.role,
      facilityId: widget.role == ViraRole.rider ? 'facility-001' : null,
      facilityName: widget.role == ViraRole.rider ? 'Kenyatta National Hospital' : null,
      isVerified: widget.role != ViraRole.rider, // riders need separate verification step
    );

    await ref.read(authProvider.notifier).signIn(session, 'demo-token-001');

    if (!mounted) return;

    final home = switch (widget.role) {
      ViraRole.rider => '/rider/home',
      ViraRole.courier => '/courier/home',
      ViraRole.dispatch => '/dispatch/console',
    };
    context.go(home);
  }
}
