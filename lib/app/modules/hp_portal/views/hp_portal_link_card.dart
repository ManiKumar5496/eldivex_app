import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';

/// Builds the org-scoped caregiver portal link. The app uses Flutter web hash
/// routing, so the link points at `<origin>/#/hp?org_id=<id>`. A caregiver who
/// opens it only has to enter their phone + OTP — the org is already encoded.
String buildHpPortalLink({int? orgId}) {
  final id = orgId ?? (GetStorage().read('org_id') ?? 1);
  final origin = Uri.base.origin; // scheme://host[:port]
  return '$origin/#/hp?org_id=$id';
}

/// A compact, copyable card showing the caregiver's login link. Drop it into
/// the HP profile / Manage HP screens.
class HpPortalLinkCard extends StatelessWidget {
  final int? orgId;
  const HpPortalLinkCard({super.key, this.orgId});

  @override
  Widget build(BuildContext context) {
    final link = buildHpPortalLink(orgId: orgId);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.cAppPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.cAppPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: AppColor.cAppPrimaryColor),
              const SizedBox(width: 6),
              Text('Caregiver login link',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColor.cPrimaryHeadingColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Share this with the caregiver. They log in with their phone + OTP.',
              style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.divColor),
                  ),
                  child: Text(link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: AppColor.fontColorBlack)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  HelperUi.showToast(
                    message: 'Link copied',
                    backgroundColor: Get.theme.colorScheme.primary,
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
