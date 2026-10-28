import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/hp_auth_controller.dart';
import 'hp_widgets.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class HpLoginView extends GetView<HpAuthController> {
  const HpLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneCtrl = controller.phoneCtrl;
    final otpCtrl = controller.otpCtrl;
    final slugCtrl = controller.slugCtrl;
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: narrow ? 24 : 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: EdgeInsets.all(narrow ? 24 : 32),
                    child: Obx(() {
                      final orgKnown = controller.orgId.value != null;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: HpUi.brandMark(size: 44),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Caregiver login',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.4,
                                color: AppColor.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          if (orgKnown)
                            _OrgPill(name: controller.orgName.value)
                          else
                            Text(
                              'Open the link shared by your organisation',
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.textTertiary),
                            ),
                          const SizedBox(height: 24),

                          // Fallback org entry when the link carried no slug.
                          if (!orgKnown) ...[
                            HpUi.field(
                              'Organisation code',
                              TextField(
                                controller: slugCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. SUN-482913',
                                  prefixIcon: Icon(LucideIcons.building2,
                                      size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            HpUi.primaryButton(
                              label: 'Continue',
                              loading: controller.resolvingOrg.value,
                              onTap: () =>
                                  controller.resolveManualEntry(slugCtrl.text),
                            ),
                          ] else if (!controller.otpSent.value) ...[
                            HpUi.field(
                              'Phone number',
                              TextField(
                                controller: phoneCtrl,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  hintText: '10-digit mobile number',
                                  prefixText: '+91 ',
                                  counterText: '',
                                  prefixIcon: Icon(LucideIcons.smartphone,
                                      size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            HpUi.primaryButton(
                              label: 'Send OTP',
                              loading: controller.sendingOtp.value,
                              onTap: () => controller.requestOtp(phoneCtrl.text),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: controller.changeOrganisation,
                                child: const Text('Not your organisation? Change'),
                              ),
                            ),
                          ] else ...[
                            _OtpSentNote(phone: controller.phone.value),
                            const SizedBox(height: 16),
                            HpUi.field(
                              'Enter OTP',
                              TextField(
                                controller: otpCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 8,
                                  color: AppColor.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '••••••',
                                  counterText: '',
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            HpUi.primaryButton(
                              label: 'Verify & Login',
                              loading: controller.verifying.value,
                              onTap: () => controller.verifyOtp(otpCtrl.text),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: controller.resetOtp,
                                child: const Text('Change number / resend'),
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Powered by Eldivex',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

class _OtpSentNote extends StatelessWidget {
  const _OtpSentNote({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.successSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.mailCheck,
              size: 18, color: AppColor.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text('OTP sent to +91 $phone',
                style: TextStyle(fontSize: 13.5, color: AppColor.textPrimary)),
          ),
        ],
      ),
    );
  }
}
