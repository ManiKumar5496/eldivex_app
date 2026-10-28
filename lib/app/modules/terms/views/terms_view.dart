import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../controllers/terms_controller.dart';

/// First-login Terms & Conditions gate.
///
/// The reader must scroll to the bottom before the acknowledgement checkbox
/// unlocks, and must tick it before "Agree & Continue" unlocks.
class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.loadError.value.isNotEmpty) {
                return _ErrorState(
                  message: controller.loadError.value,
                  onRetry: controller.fetchTerms,
                );
              }
              return _buildCard(context);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          Divider(height: 1, color: AppColor.divColor),
          Flexible(child: _body()),
          Divider(height: 1, color: AppColor.divColor),
          _footer(context),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.cAppPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.gpp_good_outlined,
                color: AppColor.cAppPrimaryColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.title.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColor.cPrimaryHeadingColor,
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      _subtitle(),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.cPrimarySubHeadingColorGrey,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final v = controller.version.value;
    final eff = controller.effectiveFrom.value;
    final parts = <String>[];
    if (v > 0) parts.add('Version $v');
    if (eff.isNotEmpty) {
      final date = eff.length >= 10 ? eff.substring(0, 10) : eff;
      parts.add('Effective $date');
    }
    parts.add('Please read to the end to continue');
    return parts.join('  •  ');
  }

  Widget _body() {
    return Stack(
      children: [
        Scrollbar(
          controller: controller.scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Obx(() => SelectableText(
                  controller.content.value,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: AppColor.fontColorBlack,
                  ),
                )),
          ),
        ),
        // Bottom "read progress" pill.
        Positioned(
          right: 20,
          bottom: 16,
          child: Obx(() {
            final done = controller.reachedBottom.value;
            return AnimatedOpacity(
              opacity: done ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: done,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.cAppPrimaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_double_arrow_down,
                          size: 16, color: AppColor.buttonTextWhite),
                      const SizedBox(width: 6),
                      Text('Scroll to the end',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.buttonTextWhite,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final unlocked = controller.reachedBottom.value;
            return Opacity(
              opacity: unlocked ? 1.0 : 0.5,
              child: InkWell(
                onTap: unlocked
                    ? () => controller.agreed.value = !controller.agreed.value
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.agreed.value,
                          activeColor: AppColor.cAppPrimaryColor,
                          onChanged: unlocked
                              ? (v) => controller.agreed.value = v ?? false
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I have read, understood and agree to the Terms & '
                          'Conditions above, and I am authorised to accept them '
                          'on behalf of my organisation.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColor.fontColorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.decline,
                child: Text('Decline & Sign out',
                    style: TextStyle(color: AppColor.fontColorGrey)),
              ),
              const SizedBox(width: 12),
              Obx(() => ElevatedButton(
                    onPressed: controller.canAgree ? controller.accept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cPrimaryButtonColor,
                      disabledBackgroundColor:
                          AppColor.cPrimaryButtonColor.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.buttonTextWhite,
                            ),
                          )
                        : Text('Agree & Continue',
                            style: TextStyle(
                              color: AppColor.buttonTextWhite,
                              fontWeight: FontWeight.w600,
                            )),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 42, color: AppColor.calenderRed),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.fontColorBlack)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor),
            child: Text('Retry',
                style: TextStyle(color: AppColor.buttonTextWhite)),
          ),
        ],
      ),
    );
  }
}
