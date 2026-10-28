import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../../login/views/login_view.dart';
import '../controllers/hp_auth_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Caregiver sign-in: organisation code (only when the link carried none)
/// → phone → OTP. Same frame as the admin login.
class HpLoginView extends GetView<HpAuthController> {
  const HpLoginView({super.key});

  static const _brand = AuthBrandCopy(
    headline: 'Your shifts, attendance and pay in one place.',
    description: 'Sign in with your phone number to check in, see your '
        'bookings and keep track of what you have earned.',
    bullets: [
      (LucideIcons.clipboardCheck, 'Check in and out of your shifts'),
      (LucideIcons.briefcase, 'Current and upcoming bookings'),
      (LucideIcons.banknote, 'Daily earnings and payslips'),
      (LucideIcons.umbrella, 'Leave requests and support tickets'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: AuthSplitLayout(brand: _brand, child: Obx(_form)),
    );
  }

  Widget _form() {
    final orgKnown = controller.orgId.value != null;
    final otpSent = orgKnown && controller.otpSent.value;
    final subtitle = !orgKnown
        ? 'Enter the organisation code shared by your organisation.'
        : otpSent
            ? 'Enter the code we sent to +91 ${controller.phone.value}.'
            : 'Enter your registered phone number to get a one-time code.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Caregiver sign in',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textTertiary),
        ),
        if (orgKnown) ...[
          const SizedBox(height: 16),
          _OrgPill(name: controller.orgName.value),
        ],
        const SizedBox(height: 28),
        if (!orgKnown)
          ..._orgStep()
        else if (!otpSent)
          ..._phoneStep()
        else
          ..._otpStep(),
      ],
    );
  }

  // Fallback org entry when the link carried no slug.
  List<Widget> _orgStep() {
    void submit() => controller.resolveManualEntry(controller.slugCtrl.text);
    return [
      const AuthFieldLabel('Organisation code'),
      TextField(
        controller: controller.slugCtrl,
        textCapitalization: TextCapitalization.characters,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          hintText: 'e.g. SUN-482913',
          prefixIcon:
              Icon(LucideIcons.building2, size: 18, color: AppColor.textTertiary),
        ),
      ),
      const SizedBox(height: 24),
      _submitButton('Continue', controller.resolvingOrg.value, submit),
    ];
  }

  List<Widget> _phoneStep() {
    void submit() => controller.requestOtp(controller.phoneCtrl.text);
    return [
      const AuthFieldLabel('Phone number'),
      TextField(
        controller: controller.phoneCtrl,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          hintText: '10-digit mobile number',
          prefixText: '+91 ',
          counterText: '',
          prefixIcon:
              Icon(LucideIcons.smartphone, size: 18, color: AppColor.textTertiary),
        ),
      ),
      const SizedBox(height: 24),
      _submitButton('Send OTP', controller.sendingOtp.value, submit),
      ..._footerLink(
        'Not your organisation?',
        'Change',
        controller.changeOrganisation,
      ),
    ];
  }

  List<Widget> _otpStep() {
    void submit() => controller.verifyOtp(controller.otpCtrl.text);
    return [
      const AuthFieldLabel('One-time code'),
      TextField(
        controller: controller.otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => submit(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 8,
          color: AppColor.textPrimary,
        ),
        decoration: const InputDecoration(hintText: '••••••', counterText: ''),
      ),
      const SizedBox(height: 24),
      _submitButton('Verify & sign in', controller.verifying.value, submit),
      ..._footerLink(
        "Didn't get the code?",
        'Change number or resend',
        controller.resetOtp,
      ),
    ];
  }

  /// Full-width primary action; keeps its brand fill and shows a white
  /// spinner while [loading].
  Widget _submitButton(String label, bool loading, VoidCallback onTap) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: authPrimaryButtonStyle(),
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.buttonTextWhite,
                ),
              )
            : Text(label),
      ),
    );
  }

  /// Hairline, then "prompt  Action" centred under the form.
  List<Widget> _footerLink(String prompt, String action, VoidCallback onTap) {
    return [
      const SizedBox(height: 24),
      Divider(height: 1, color: AppColor.borderSubtle),
      const SizedBox(height: 14),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$prompt ',
            style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontFamily: 'inter_regular',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(action),
          ),
        ],
      ),
    ];
  }
}

/// Organisation the caregiver is signing in to.
class _OrgPill extends StatelessWidget {
  const _OrgPill({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    if (name.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColor.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColor.divColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.building2,
                size: 16, color: AppColor.textTertiary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
