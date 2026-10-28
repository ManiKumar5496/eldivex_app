import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/utils/session_utils.dart';
import '../../../widgets/helper_ui.dart';
import '../../hp_portal/views/hp_portal_link_card.dart' show PortalLinkCardBody;
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Builds the org-scoped client portal link. Uses Flutter web hash routing, so
/// it points at `<origin>/#/client?org_id=<ref>`. A client who opens it only
/// enters their phone + OTP — the org is already encoded.
/// Uses the public org code (e.g. SUN-482913) when the org has one; legacy
/// orgs without a code fall back to their numeric id.
String buildClientPortalLink({String? orgRef}) {
  final box = GetStorage();
  final code = (box.read('org_code') ?? '').toString();
  final ref = orgRef ??
      (code.isNotEmpty ? code : adminOrgId().toString());
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
    return PortalLinkCardBody(
      icon: LucideIcons.users,
      title: 'Client login link',
      subtitle: 'Share with your clients. They log in with their phone + OTP.',
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
