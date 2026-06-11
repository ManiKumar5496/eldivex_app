import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/hp_auth_controller.dart';
import 'hp_widgets.dart';

class HpLoginView extends GetView<HpAuthController> {
  const HpLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final slugCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: HpUi.card(
              padding: const EdgeInsets.all(28),
              child: Obx(() {
                final orgKnown = controller.orgId.value != null;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.health_and_safety,
                        size: 48, color: AppColor.cAppPrimaryColor),
                    const SizedBox(height: 12),
                    Text(
                      'Caregiver Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cPrimaryHeadingColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orgKnown
                          ? controller.orgName.value
                          : 'Open the link shared by your organisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.fontColorGrey),
                    ),
                    const SizedBox(height: 24),

                    // Fallback org entry when the link carried no slug.
                    if (!orgKnown) ...[
                      TextField(
                        controller: slugCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Organisation code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _primaryButton(
                        label: 'Continue',
                        loading: controller.resolvingOrg.value,
                        onTap: () => controller.resolveOrg(slugCtrl.text),
                      ),
                    ] else if (!controller.otpSent.value) ...[
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixText: '+91 ',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _primaryButton(
                        label: 'Send OTP',
                        loading: controller.sendingOtp.value,
                        onTap: () => controller.requestOtp(phoneCtrl.text),
                      ),
                    ] else ...[
                      Text('OTP sent to +91 ${controller.phone.value}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColor.fontColorGrey)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Enter OTP',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _primaryButton(
                        label: 'Verify & Login',
                        loading: controller.verifying.value,
                        onTap: () => controller.verifyOtp(otpCtrl.text),
                      ),
                      TextButton(
                        onPressed: controller.resetOtp,
                        child: const Text('Change number / resend'),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.cPrimaryButtonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
                height: 22, width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: TextStyle(
                    color: AppColor.buttonTextWhite, fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}
