import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';

/// Builds the org-scoped client portal link. Uses Flutter web hash routing, so
/// it points at `<origin>/#/client?org_id=<ref>`. A client who opens it only
/// enters their phone + OTP — the org is already encoded.
/// Uses the public org code (e.g. SUN-482913) when the org has one; legacy
/// orgs without a code fall back to their numeric id.
String buildClientPortalLink({String? orgRef}) {
  final box = GetStorage();
  final code = (box.read('org_code') ?? '').toString();
  final ref = orgRef ??
      (code.isNotEmpty ? code : (box.read('org_id') ?? 1).toString());
  final origin = Uri.base.origin;
  return '$origin/#/client?org_id=$ref';
}

/// Compact, copyable card showing the client login link. Drop it into the
/// Client Users screen.
class ClientPortalLinkCard extends StatelessWidget {
  final String? orgRef;
  const ClientPortalLinkCard({super.key, this.orgRef});

  @override
  Widget build(BuildContext context) {
    final link = buildClientPortalLink(orgRef: orgRef);
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
              Text('Client login link',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Share with your clients. They log in with their phone + OTP.',
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
