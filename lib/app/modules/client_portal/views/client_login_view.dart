import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_auth_controller.dart';

class ClientLoginView extends GetView<ClientAuthController> {
  const ClientLoginView({super.key});

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
                    Icon(Icons.account_circle, size: 48, color: AppColor.cAppPrimaryColor),
                    const SizedBox(height: 12),
                    Text('Client Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppColor.cPrimaryHeadingColor)),
                    const SizedBox(height: 4),
                    Text(
                      orgKnown ? controller.orgName.value : 'Open the link shared by your organisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.fontColorGrey),
                    ),
                    const SizedBox(height: 24),
                    if (!orgKnown) ...[
                      TextField(
                        controller: slugCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Organisation code', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      _btn('Continue', controller.resolvingOrg.value,
                          () => controller.resolveOrg(slugCtrl.text)),
                    ] else if (!controller.otpSent.value) ...[
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                            labelText: 'Phone number', prefixText: '+91 ',
                            counterText: '', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      _btn('Send OTP', controller.sendingOtp.value,
                          () => controller.requestOtp(phoneCtrl.text)),
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
                            labelText: 'Enter OTP', counterText: '', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      _btn('Verify & Login', controller.verifying.value,
                          () => controller.verifyOtp(otpCtrl.text)),
                      TextButton(
                          onPressed: controller.resetOtp,
                          child: const Text('Change number / resend')),
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

  Widget _btn(String label, bool loading, VoidCallback onTap) {
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
