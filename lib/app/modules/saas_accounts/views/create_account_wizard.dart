import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/saas_accounts_controller.dart';

class CreateAccountWizard extends StatelessWidget {
  const CreateAccountWizard({super.key});

  static void show() {
    final ctrl = Get.find<SaasAccountsController>();
    ctrl.resetWizard();
    Get.dialog(
      const Dialog(
        insetPadding: EdgeInsets.all(24),
        child: SizedBox(width: 560, child: CreateAccountWizard()),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SaasAccountsController>();
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WizardHeader(step: ctrl.wizardStep.value),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: [
                _Step1(ctrl: ctrl),
                _Step2(ctrl: ctrl),
                _Step3(ctrl: ctrl),
                _Step4(ctrl: ctrl),
              ][ctrl.wizardStep.value],
            ),
          ),
          const Divider(height: 1),
          _WizardFooter(ctrl: ctrl),
        ],
      );
    });
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.step});
  final int step;

  static const _titles = [
    'Step 1 — Organisation Details',
    'Step 2 — Plan Selection',
    'Step 3 — Billing Setup',
    'Step 4 — Admin User',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New SaaS Account', style: AppTextStyles.semiBold16),
                const SizedBox(height: 2),
                Text(_titles[step], style: AppTextStyles.regular14Gre),
              ],
            ),
          ),
          // Step dots
          Row(
            children: List.generate(4, (i) {
              final done = i < step;
              final active = i == step;
              return Container(
                margin: const EdgeInsets.only(left: 6),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.divColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({required this.ctrl});
  final SaasAccountsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (ctrl.wizardStep.value > 0)
            OutlinedButton(
              onPressed: ctrl.prevStep,
              child: const Text('Back'),
            )
          else
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          Obx(() => ElevatedButton(
                onPressed: ctrl.saving.value
                    ? null
                    : ctrl.wizardStep.value < 3
                        ? ctrl.nextStep
                        : ctrl.submitWizard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: ctrl.saving.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.buttonTextWhite))
                    : Text(ctrl.wizardStep.value < 3
                        ? 'Next →'
                        : 'Create Account'),
              )),
        ],
      ),
    );
  }
}

// ── Step 1: Org Details ───────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({required this.ctrl});
  final SaasAccountsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl.nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Organisation Name *',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            if (ctrl.slugCtrl.text.isEmpty) ctrl.autoGenerateSlug(v);
          },
        ),
        const SizedBox(height: 14),

        // Slug with live check
        Obx(() => TextField(
              controller: ctrl.slugCtrl,
              decoration: InputDecoration(
                labelText: 'Slug (unique URL identifier) *',
                border: const OutlineInputBorder(),
                helperText: 'lowercase letters, digits and hyphens only',
                suffixIcon: ctrl.checkingSlug.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : ctrl.slugCtrl.text.isNotEmpty
                        ? Icon(
                            ctrl.slugAvailable.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: ctrl.slugAvailable.value
                                ? Colors.green
                                : AppColor.calenderRed,
                          )
                        : null,
                errorText: ctrl.slugCheckMessage.value.isNotEmpty
                    ? ctrl.slugCheckMessage.value
                    : null,
              ),
              onChanged: ctrl.onSlugChanged,
            )),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl.phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl.addressCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// ── Step 2: Plan Selection ────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  const _Step2({required this.ctrl});
  final SaasAccountsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.loadingPlans.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: ctrl.plans.map((plan) {
          final isSelected = ctrl.selectedPlanId.value == plan.id.toString();
          final color = plan.name == 'Enterprise'
              ? Colors.purple
              : plan.name == 'Growth'
                  ? Colors.blue
                  : AppColor.fontColorGrey;
          return GestureDetector(
            onTap: () => ctrl.selectedPlanId.value = plan.id.toString(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.06)
                    : AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColor.divColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? color : Colors.transparent,
                      border: Border.all(
                          color: isSelected ? color : AppColor.divColor,
                          width: 2),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: AppColor.buttonTextWhite, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(plan.name,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                            const Spacer(),
                            Text(
                              '₹${plan.pricePerMonth.toStringAsFixed(0)}/mo',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(plan.limitLabel,
                            style: AppTextStyles.regular14Gre),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ── Step 3: Billing Setup ─────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  const _Step3({required this.ctrl});
  final SaasAccountsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: ctrl.isTrial.value,
              onChanged: (v) => ctrl.isTrial.value = v,
              title: const Text('Start as Trial'),
              subtitle: const Text('No billing during trial period'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColor.cPrimaryButtonColor,
            ),
            if (ctrl.isTrial.value) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Trial duration (days): '),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: ctrl.trialDays.value,
                    items: [7, 14, 21, 30, 60, 90]
                        .map((d) => DropdownMenuItem(
                            value: d, child: Text('$d days')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) ctrl.trialDays.value = v;
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subscription Start Date (optional)',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD',
              ),
              onChanged: (v) => ctrl.subscriptionStart.value = v,
            ),
            const SizedBox(height: 14),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subscription Expiry Date (optional)',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD',
              ),
              onChanged: (v) => ctrl.subscriptionExpiry.value = v,
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: ctrl.autoRenew.value,
              onChanged: (v) => ctrl.autoRenew.value = v,
              title: const Text('Auto-Renew'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColor.cPrimaryButtonColor,
            ),
          ],
        ));
  }
}

// ── Step 4: Admin User ────────────────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  const _Step4({required this.ctrl});
  final SaasAccountsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create an admin user for this organisation (optional).',
              style: AppTextStyles.regular14Gre,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl.adminNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Admin Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl.adminEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Admin Email',
                border: const OutlineInputBorder(),
                suffixIcon: ctrl.checkingAdminEmail.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : ctrl.adminEmailCtrl.text.isNotEmpty
                        ? Icon(
                            ctrl.adminEmailAvailable.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: ctrl.adminEmailAvailable.value
                                ? Colors.green
                                : AppColor.calenderRed,
                          )
                        : null,
                errorText: ctrl.adminEmailCtrl.text.isNotEmpty &&
                        !ctrl.adminEmailAvailable.value
                    ? 'Email already in use'
                    : null,
              ),
              onChanged: ctrl.onAdminEmailChanged,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl.adminPasswordCtrl,
              obscureText: ctrl.passwordObscure.value,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(ctrl.passwordObscure.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      ctrl.passwordObscure.value = !ctrl.passwordObscure.value,
                ),
                helperText: ctrl.adminPasswordCtrl.text.isNotEmpty
                    ? 'Strength: ${ctrl.passwordStrength(ctrl.adminPasswordCtrl.text)}'
                    : null,
              ),
              onChanged: (_) {},
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl.adminConfirmCtrl,
              obscureText: ctrl.confirmObscure.value,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(ctrl.confirmObscure.value
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      ctrl.confirmObscure.value = !ctrl.confirmObscure.value,
                ),
                errorText: ctrl.adminConfirmCtrl.text.isNotEmpty &&
                        ctrl.adminPasswordCtrl.text !=
                            ctrl.adminConfirmCtrl.text
                    ? 'Passwords do not match'
                    : null,
              ),
              onChanged: (_) {},
            ),
          ],
        ));
  }
}
