import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/org_profile_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Settings → Organisation Profile.
///
/// One place for an org admin to manage the business identity that renders on
/// every client-facing email (invoices, payment receipts), with a live preview
/// of exactly what clients receive.
class OrgProfileView extends GetView<OrgProfileController> {
  const OrgProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrgProfileController());
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: EdgeInsets.all(narrow ? 16 : 24),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(controller: controller),
                    const SizedBox(height: 24),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 1100;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 11,
                                  child: SingleChildScrollView(
                                    child: _ProfileForm(controller: controller),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 9,
                                  child: _PreviewPanel(controller: controller),
                                ),
                              ],
                            );
                          }
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ProfileForm(controller: controller),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 760,
                                  child: _PreviewPanel(controller: controller),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'Organisation Profile',
      subtitle:
          'Your business identity on invoices, payment receipts and every email sent to your clients.',
      titleTrailing: Obx(() => controller.orgCode.value.isEmpty
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(color: AppColor.borderSubtle),
              ),
              child: Text(
                controller.orgCode.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColor.textSecondary,
                ),
              ),
            )),
      actions: [_SaveButton(controller: controller)],
    );
  }
}

/// The single profile save action. Used in the page header and again at the
/// bottom of the form so it is reachable after scrolling; both call the same
/// [OrgProfileController.saveProfile].
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = controller.isSaving.value;
      return ElevatedButton.icon(
        onPressed: saving ? null : controller.saveProfile,
        icon: saving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColor.buttonTextWhite),
              )
            : const Icon(LucideIcons.save, size: 18),
        label: Text(saving ? 'Saving…' : 'Save Changes'),
      );
    });
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          icon: LucideIcons.palette,
          title: 'Brand Identity',
          subtitle: 'Shown in the header of every client email.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TwoUp(
                left: _field('Organisation Name *', controller.nameCtrl,
                    hint: 'e.g. Sunrise Elder Care'),
                right: _field('Tagline', controller.taglineCtrl,
                    hint: 'e.g. Compassionate care, at home'),
              ),
              _field('Logo URL', controller.logoUrlCtrl,
                  hint: 'https://…/logo.png (shown above your name)'),
              _BrandColorPicker(controller: controller),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          icon: LucideIcons.contact,
          title: 'Contact & Address',
          subtitle: 'Appears in the email footer so clients can reach you.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TwoUp(
                left: _field('Billing Email', controller.emailCtrl,
                    hint: 'billing@yourbusiness.in'),
                right: _field('Phone', controller.phoneCtrl, hint: '+91 …'),
              ),
              _field('Website', controller.websiteCtrl,
                  hint: 'https://yourbusiness.in'),
              _field('Registered Address', controller.addressCtrl,
                  hint: 'Street, city, PIN', maxLines: 2, last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          icon: LucideIcons.receiptText,
          title: 'Tax & Billing',
          subtitle:
              'Drives the invoice: tax line, due date and how clients pay you.',
          footer: _SaveFooter(controller: controller),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TwoUp(
                left: _field('GSTIN', controller.gstinCtrl,
                    hint: '22AAAAA0000A1Z5 (shown on invoices)'),
                right: _field('Payment Terms (days)', controller.termsDaysCtrl,
                    hint: '15', keyboardType: TextInputType.number),
              ),
              _field(
                'Payment Instructions',
                controller.invoiceNotesCtrl,
                hint:
                    'UPI ID: yourbiz@upi\nBank: HDFC 50100XXXXXX, IFSC HDFC0000123\nShown as a "Payment Instructions" box on every invoice.',
                maxLines: 4,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

/// Card footer with the save note and the (shared) save action.
class _SaveFooter extends StatelessWidget {
  const _SaveFooter({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    final note = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(LucideIcons.info,
              size: 16, color: AppColor.textTertiary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Emails are sent under your organisation\'s name. Invoice due dates use your payment terms. Save changes to apply them to all future emails.',
            style: TextStyle(
                fontSize: 12.5, height: 1.45, color: AppColor.textTertiary),
          ),
        ),
      ],
    );
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 480) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            note,
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _SaveButton(controller: controller),
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: note),
          const SizedBox(width: 16),
          _SaveButton(controller: controller),
        ],
      );
    });
  }
}

/// Field label above an input: 13/w600, secondary text colour.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
      ),
    );
  }
}

/// Two fields side by side when the card is wide enough, stacked otherwise.
class _TwoUp extends StatelessWidget {
  const _TwoUp({required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
    });
  }
}

// ── Brand colour picker ───────────────────────────────────────────────────────

class _BrandColorPicker extends StatelessWidget {
  const _BrandColorPicker({required this.controller});
  final OrgProfileController controller;

  static Color _fromHex(String hex) =>
      Color(int.parse('FF${hex.substring(1)}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Brand Colour'),
        const SizedBox(height: 2),
        Text('Used for the email header and invoice highlights.',
            style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary)),
        const SizedBox(height: 12),
        Obx(() {
          final selected = controller.brandColor.value;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // "Default" option — platform navy.
              _swatch(
                label: 'Default',
                tooltip: 'Default (#1E3A5F)',
                color: _fromHex('#1E3A5F'),
                isSelected: selected.isEmpty,
                onTap: () => controller.brandColor.value = '',
              ),
              for (final hex in OrgProfileController.brandPresets)
                _swatch(
                  tooltip: hex.toUpperCase(),
                  color: _fromHex(hex),
                  isSelected: selected.toUpperCase() == hex.toUpperCase(),
                  onTap: () => controller.brandColor.value = hex,
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _swatch({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
    String? label,
  }) {
    // Ring sits outside the swatch with a small gap, Stripe-style.
    final circle = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : AppColor.borderSubtle,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: isSelected
            ? Icon(LucideIcons.check, size: 16, color: AppColor.pureWhite)
            : null,
      ),
    );

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: label == null
            ? circle
            : Container(
                padding: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppColor.borderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: isSelected
                                ? Icon(LucideIcons.check,
                                    size: 15, color: AppColor.pureWhite)
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColor.textPrimary
                            : AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Live email preview ────────────────────────────────────────────────────────

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      icon: LucideIcons.mailCheck,
      title: 'Live Email Preview',
      subtitle:
          'Rendered with sample billing data — updates with your unsaved edits.',
      expandChild: true,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      actions: [
        Obx(() {
          final loading = controller.isPreviewLoading.value;
          return OutlinedButton.icon(
            style: AppButtonStyles.compact,
            onPressed: loading ? null : () => controller.refreshPreview(),
            icon: loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Update Preview'),
          );
        }),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final tab = controller.previewTab.value;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColor.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tabChip('Invoice', 0, tab),
                    const SizedBox(width: 2),
                    _tabChip('Payment Receipt', 1, tab),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          // Email client frame: inbox header (subject + sender) above the
          // rendered message.
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColor.divColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColor.surfaceMuted,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    child: Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColor.borderStrong,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        const SizedBox(width: 6),
                        Icon(LucideIcons.mail,
                            size: 14, color: AppColor.textTertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Obx(() => Text(
                                controller.previewTab.value == 0
                                    ? 'Invoice email'
                                    : 'Payment receipt email',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textTertiary,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColor.borderSubtle),
                  // Subject + sender — what the client sees in their inbox list.
                  Obx(() {
                    final tab = controller.previewTab.value;
                    final subject = tab == 0
                        ? controller.invoiceSubject.value
                        : controller.receiptSubject.value;
                    if (subject.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        border: Border(
                            bottom: BorderSide(color: AppColor.borderSubtle)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: $subject',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          if (controller.senderLine.value.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'From: ${controller.senderLine.value}',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColor.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  Expanded(
                    child: Obx(() {
                      final tab = controller.previewTab.value;
                      final content = tab == 0
                          ? controller.invoiceHtml.value
                          : controller.receiptHtml.value;
                      // Touch previewVersion so a re-render with identical text
                      // still rebuilds this Obx.
                      controller.previewVersion.value;

                      if (controller.isPreviewLoading.value &&
                          content.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (content.isEmpty) {
                        return AppEmptyState(
                          icon: LucideIcons.mail,
                          title: 'Preview unavailable',
                          message: 'Tap Update Preview to render the email with your current details.',
                          compact: true,
                          actionLabel: 'Update Preview',
                          actionIcon: LucideIcons.refreshCw,
                          onAction: () => controller.refreshPreview(),
                        );
                      }
                      return _EmailFrame(htmlContent: content);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String label, int index, int current) {
    final selected = index == current;
    return Material(
      color: selected ? AppColor.whiteColor : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      elevation: 0,
      child: InkWell(
        onTap: () => controller.previewTab.value = index,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected ? AppColor.divColor : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColor.textPrimary : AppColor.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders trusted, backend-generated email HTML inside a sandboxed iframe.
/// One platform view factory is registered for the whole app session (factories
/// cannot be replaced or unregistered); new content is pushed into the live
/// iframe instead of registering a new view type per preview.
class _EmailFrame extends StatelessWidget {
  const _EmailFrame({required this.htmlContent});

  final String htmlContent;

  static const String _viewType = 'org-email-preview';
  static bool _registered = false;
  static html.IFrameElement? _frame;
  static String _content = '';

  static void _ensureRegistered() {
    if (_registered) return;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        // Block scripts/navigation — render-only.
        ..setAttribute('sandbox', '')
        ..srcdoc = _content;
      _frame = iframe;
      return iframe;
    });
    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    _ensureRegistered();
    if (_content != htmlContent) {
      _content = htmlContent;
      // Update the existing iframe in place (no-op until it is created; the
      // factory then picks up _content).
      _frame?.srcdoc = htmlContent;
    }
    return const HtmlElementView(viewType: _viewType);
  }
}
