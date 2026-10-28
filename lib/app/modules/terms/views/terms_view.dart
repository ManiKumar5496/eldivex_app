import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../../login/views/login_view.dart';
import '../controllers/terms_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// First-login Terms & Conditions gate.
///
/// The reader must scroll to the bottom before the acknowledgement checkbox
/// unlocks, and must tick it before "Agree & Continue" unlocks.
class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 760 + (narrow ? 32 : 48)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 16 : 24, vertical: narrow ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _brandRow(),
                  SizedBox(height: narrow ? 16 : 20),
                  Expanded(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandRow() {
    return Row(
      children: [
        const EldivexMark(size: 32),
        const SizedBox(width: 10),
        Text(
          'Eldivex',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColor.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return AppCard(
      padding: EdgeInsets.zero,
      expandChild: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(narrow),
          Divider(height: 1, color: AppColor.borderSubtle),
          Expanded(child: _body(narrow)),
          Divider(height: 1, color: AppColor.borderSubtle),
          _footer(context, narrow),
        ],
      ),
    );
  }

  Widget _header(bool narrow) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          narrow ? 16 : 28, narrow ? 16 : 22, narrow ? 16 : 28, narrow ? 14 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: LucideIcons.shieldCheck, size: narrow ? 36 : 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.title.value,
                      style: TextStyle(
                        fontSize: narrow ? 17 : 19,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColor.textPrimary,
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      _subtitle(),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textTertiary,
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

  Widget _body(bool narrow) {
    return Stack(
      children: [
        Scrollbar(
          controller: controller.scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            padding: EdgeInsets.fromLTRB(
                narrow ? 16 : 32, narrow ? 18 : 24, narrow ? 16 : 32, 40),
            child: Obx(() => SelectableText(
                  controller.content.value,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: AppColor.textSecondary,
                  ),
                )),
          ),
        ),
        // Bottom "read progress" pill.
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Obx(() {
            final done = controller.reachedBottom.value;
            return AnimatedOpacity(
              opacity: done ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: done,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.cAppPrimaryColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppShadows.overlay,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.chevronsDown,
                            size: 16, color: AppColor.buttonTextWhite),
                        const SizedBox(width: 6),
                        Text('Scroll to the end',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColor.buttonTextWhite,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context, bool narrow) {
    return Container(
      color: AppColor.surfaceMuted,
      padding: EdgeInsets.fromLTRB(
          narrow ? 16 : 28, 16, narrow ? 16 : 28, narrow ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final unlocked = controller.reachedBottom.value;
            return Opacity(
              opacity: unlocked ? 1.0 : 0.5,
              child: InkWell(
                onTap: unlocked
                    ? () => controller.agreed.value = !controller.agreed.value
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: controller.agreed.value,
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
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppColor.textSecondary,
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
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Obx(() => TextButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.decline,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.textSecondary,
                      minimumSize: const Size(48, 44),
                    ),
                    child: const Text('Decline & Sign out'),
                  )),
              Obx(() => SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: controller.canAgree ? controller.accept : null,
                      style: controller.isSubmitting.value
                          ? authPrimaryButtonStyle()
                          : null,
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.buttonTextWhite,
                              ),
                            )
                          : const Text('Agree & Continue'),
                    ),
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
      child: SingleChildScrollView(
        child: AppCard(
          child: AppEmptyState(
            icon: LucideIcons.circleAlert,
            tone: AppTone.danger,
            title: 'Could not load the Terms & Conditions',
            message: message,
            actionLabel: 'Retry',
            actionIcon: LucideIcons.refreshCw,
            onAction: onRetry,
          ),
        ),
      ),
    );
  }
}
