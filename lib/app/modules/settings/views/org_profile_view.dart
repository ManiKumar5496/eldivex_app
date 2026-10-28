import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/org_profile_controller.dart';

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

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Organisation Profile', style: AppTextStyles.heading),
                  const SizedBox(width: 12),
                  Obx(() => controller.orgCode.value.isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColor.divColor),
                          ),
                          child: Text(
                            controller.orgCode.value,
                            style: AppTextStyles.regular14Gre
                                .copyWith(letterSpacing: 1),
                          ),
                        )),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Your business identity on invoices, payment receipts and every email sent to your clients.',
                style: AppTextStyles.regular14Gre,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Obx(() {
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
                : Icon(Icons.save_outlined,
                    size: 18, color: AppColor.buttonTextWhite),
            label: Text(saving ? 'Saving…' : 'Save Changes',
                style: AppTextStyles.regular14white),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          );
        }),
      ],
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({required this.controller});
  final OrgProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          icon: Icons.palette_outlined,
          title: 'Brand Identity',
          subtitle: 'Shown in the header of every client email.',
          children: [
            _field('Organisation Name *', controller.nameCtrl,
                hint: 'e.g. Sunrise Elder Care'),
            _field('Tagline', controller.taglineCtrl,
                hint: 'e.g. Compassionate care, at home'),
            _field('Logo URL', controller.logoUrlCtrl,
                hint: 'https://…/logo.png (shown above your name)'),
            _BrandColorPicker(controller: controller),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.contact_mail_outlined,
          title: 'Contact & Address',
          subtitle: 'Appears in the email footer so clients can reach you.',
          children: [
            _twoUp(
              _field('Billing Email', controller.emailCtrl,
                  hint: 'billing@yourbusiness.in'),
              _field('Phone', controller.phoneCtrl, hint: '+91 …'),
            ),
            _field('Website', controller.websiteCtrl,
                hint: 'https://yourbusiness.in'),
            _field('Registered Address', controller.addressCtrl,
                hint: 'Street, city, PIN', maxLines: 2),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.receipt_long_outlined,
          title: 'Tax & Billing',
          subtitle:
              'Drives the invoice: tax line, due date and how clients pay you.',
          children: [
            _twoUp(
              _field('GSTIN', controller.gstinCtrl,
                  hint: '22AAAAA0000A1Z5 (shown on invoices)'),
              _field('Payment Terms (days)', controller.termsDaysCtrl,
                  hint: '15',
                  keyboardType: TextInputType.number),
            ),
            _field(
              'Payment Instructions',
              controller.invoiceNotesCtrl,
              hint:
                  'UPI ID: yourbiz@upi\nBank: HDFC 50100XXXXXX, IFSC HDFC0000123\nShown as a "Payment Instructions" box on every invoice.',
              maxLines: 4,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.divColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColor.lightGrey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Emails are sent under your organisation\'s name. Invoice due dates use your payment terms. Save changes to apply them to all future emails.',
                  style: AppTextStyles.regular14Gre,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _twoUp(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  static Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.fieldsHeading16),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.regular14Gre,
              filled: true,
              fillColor: AppColor.whiteColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColor.cPrimaryButtonColor),
              const SizedBox(width: 10),
              Text(title,
                  style: AppTextStyles.heading.copyWith(fontSize: 17)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(subtitle, style: AppTextStyles.regular14Gre),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
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
        Text('Brand Colour', style: AppTextStyles.fieldsHeading16),
        const SizedBox(height: 4),
        Text('Used for the email header and invoice highlights.',
            style: AppTextStyles.regular14Gre),
        const SizedBox(height: 10),
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
                color: _fromHex('#1E3A5F'),
                isSelected: selected.isEmpty,
                onTap: () => controller.brandColor.value = '',
              ),
              for (final hex in OrgProfileController.brandPresets)
                _swatch(
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
    String? label,
  }) {
    final circle = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: label == null
          ? circle
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.regular14Gre),
                const SizedBox(width: 4),
              ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    size: 20, color: AppColor.cPrimaryButtonColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Live Email Preview',
                      style: AppTextStyles.heading.copyWith(fontSize: 17)),
                ),
                Obx(() {
                  final loading = controller.isPreviewLoading.value;
                  return TextButton.icon(
                    onPressed:
                        loading ? null : () => controller.refreshPreview(),
                    icon: loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: const Text('Update Preview'),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
            child: Text(
              'Rendered with sample billing data — updates with your unsaved edits.',
              style: AppTextStyles.regular14Gre,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              final tab = controller.previewTab.value;
              return Row(
                children: [
                  _tabChip('Invoice', 0, tab),
                  const SizedBox(width: 8),
                  _tabChip('Payment Receipt', 1, tab),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          // Subject + sender — what the client sees in their inbox list.
          Obx(() {
            final tab = controller.previewTab.value;
            final subject = tab == 0
                ? controller.invoiceSubject.value
                : controller.receiptSubject.value;
            if (subject.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.cAppBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: $subject',
                      style: AppTextStyles.fieldsHeading16
                          .copyWith(fontSize: 13)),
                  if (controller.senderLine.value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('From: ${controller.senderLine.value}',
                        style: AppTextStyles.regular14Gre
                            .copyWith(fontSize: 12)),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Obx(() {
                final tab = controller.previewTab.value;
                final content = tab == 0
                    ? controller.invoiceHtml.value
                    : controller.receiptHtml.value;
                // Touch previewVersion so a re-render with identical text
                // still rebuilds this Obx.
                controller.previewVersion.value;

                if (controller.isPreviewLoading.value && content.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (content.isEmpty) {
                  return Center(
                    child: Text('Preview unavailable — tap Update Preview.',
                        style: AppTextStyles.regular14Gre),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _EmailFrame(htmlContent: content),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String label, int index, int current) {
    final selected = index == current;
    return InkWell(
      onTap: () => controller.previewTab.value = index,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.cPrimaryButtonColor
              : AppColor.cAppBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: selected
              ? AppTextStyles.regular14white
              : AppTextStyles.regular14Gre,
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
