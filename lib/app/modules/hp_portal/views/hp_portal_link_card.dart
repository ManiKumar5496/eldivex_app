import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/utils/session_utils.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Builds the org-scoped caregiver portal link. The app uses Flutter web hash
/// routing, so the link points at `<origin>/#/hp?org_id=<ref>`. A caregiver who
/// opens it only has to enter their phone + OTP — the org is already encoded.
/// Uses the public org code (e.g. SUN-482913) when the org has one; legacy
/// orgs without a code fall back to their numeric id.
String buildHpPortalLink({String? orgRef}) {
  final box = GetStorage();
  final code = (box.read('org_code') ?? '').toString();
  final ref = orgRef ??
      (code.isNotEmpty ? code : adminOrgId().toString());
  final origin = Uri.base.origin; // scheme://host[:port]
  return '$origin/#/hp?org_id=$ref';
}

/// A compact, copyable card showing the caregiver's login link. Drop it into
/// the HP profile / Manage HP screens.
class HpPortalLinkCard extends StatelessWidget {
  final String? orgRef;
  const HpPortalLinkCard({super.key, this.orgRef});

  @override
  Widget build(BuildContext context) {
    final link = buildHpPortalLink(orgRef: orgRef);
    return PortalLinkCardBody(
      icon: LucideIcons.heartPulse,
      title: 'Caregiver login link',
      subtitle:
          'Share this with the caregiver. They log in with their phone + OTP.',
      link: link,
      onCopy: () async {
        await Clipboard.setData(ClipboardData(text: link));
        HelperUi.showToast(
          message: 'Link copied',
          backgroundColor: Get.theme.colorScheme.primary,
        );
      },
    );
  }
}

/// Shared presentation for the caregiver / client portal link cards: icon
/// tile, title, the URL in a muted code-style field and a Copy button. Lays
/// out on one row when there is room, stacked on narrow widths.
class PortalLinkCardBody extends StatelessWidget {
  const PortalLinkCardBody({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.link,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;

        final header = Row(
          children: [
            AppIconTile(icon: icon, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        );

        final urlField = Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColor.divColor),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.link, size: 16, color: AppColor.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: link,
                  child: Text(
                    link,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: AppColor.textSecondary,
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                        FontFeature.slashedZero(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        final copyButton = TextButton.icon(
          onPressed: onCopy,
          style: AppButtonStyles.soft,
          icon: const Icon(LucideIcons.copy, size: 16),
          label: const Text('Copy'),
        );

        final linkRow = Row(
          children: [
            Expanded(child: urlField),
            const SizedBox(width: 8),
            copyButton,
          ],
        );

        if (wide) {
          return Row(
            children: [
              Expanded(flex: 5, child: header),
              const SizedBox(width: 24),
              Expanded(flex: 6, child: linkRow),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: 12),
            linkRow,
          ],
        );
      }),
    );
  }
}
