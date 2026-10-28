import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/enums.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';
import '../models/get_cg_details_model.dart';
import '../../hp_portal/views/hp_portal_link_card.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CgReviewDetailScreen extends StatefulWidget {
  final GetCgDetails cgDetails;

  const CgReviewDetailScreen({super.key, required this.cgDetails});

  @override
  State<CgReviewDetailScreen> createState() => _CgReviewDetailScreenState();
}

class _CgReviewDetailScreenState extends State<CgReviewDetailScreen> {
  bool _isPdfLoading = false;

  GetCgDetails get cgDetails => widget.cgDetails;

  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  String get _fullName =>
      '${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}';

  String get _regId => 'CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}';

  bool get _hasPhoto =>
      cgDetails.hpRegPhoto.isNotEmpty && !cgDetails.hpRegPhoto.contains('/NA');

  double _gap(DeviceType deviceType) =>
      deviceType == DeviceType.mobile ? 16 : 20;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final gap = _gap(deviceType);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAppBar(deviceType),
                      SizedBox(height: gap),
                      _buildHeaderCard(deviceType),
                      SizedBox(height: gap),
                      // Caregiver portal login link — only for login-eligible HPs
                      // (2=Approved, 5=ActiveBooking, 6=OTPBooking).
                      if ([2, 5, 6].contains(cgDetails.hpRegStatus)) ...[
                        const HpPortalLinkCard(),
                        SizedBox(height: gap),
                      ],
                      _buildMainContent(deviceType),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMobile) _buildMobileBottomBar(),
        ],
      ),
    );
  }

  // ================= MAIN CONTENT LAYOUT =================

  Widget _buildMainContent(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final gap = _gap(deviceType);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(deviceType),
          SizedBox(height: gap),
          _buildPersonalInfoSection(deviceType),
          SizedBox(height: gap),
          _buildContactInfoSection(deviceType),
          SizedBox(height: gap),
          _buildProfessionalInfoSection(deviceType),
          SizedBox(height: gap),
          _buildPayInfoSection(deviceType),
          SizedBox(height: gap),
          _buildLanguagesSection(deviceType),
          SizedBox(height: gap),
          _buildDocumentsSection(deviceType),
          SizedBox(height: gap),
          _buildTimelineCard(deviceType),
          const SizedBox(height: 8),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPersonalInfoSection(deviceType),
              SizedBox(height: gap),
              _buildContactInfoSection(deviceType),
              SizedBox(height: gap),
              _buildProfessionalInfoSection(deviceType),
              SizedBox(height: gap),
              _buildPayInfoSection(deviceType),
              SizedBox(height: gap),
              _buildLanguagesSection(deviceType),
              SizedBox(height: gap),
              _buildDocumentsSection(deviceType),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(deviceType),
              SizedBox(height: gap),
              _buildTimelineCard(deviceType),
            ],
          ),
        ),
      ],
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    const breadcrumbs = ['Health Professionals', 'Manage HP', 'Review'];
    const spinner = SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    );

    if (isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppPageHeader(
              title: 'HP Review',
              subtitle: _regId,
              breadcrumbs: breadcrumbs,
              onBack: () => Get.back(),
            ),
          ),
          const SizedBox(width: 8),
          if (_isPdfLoading)
            spinner
          else
            PopupMenuButton<String>(
              tooltip: 'Share or download',
              icon: Icon(LucideIcons.ellipsisVertical,
                  size: 20, color: AppColor.textSecondary),
              offset: const Offset(0, 45),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(LucideIcons.share2, size: 18),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(LucideIcons.download, size: 18),
                      SizedBox(width: 12),
                      Text('Download PDF'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'share') {
                  _shareAsPdf();
                } else if (value == 'download') {
                  _downloadAsPdf();
                }
              },
            ),
        ],
      );
    }

    return AppPageHeader(
      title: 'Health Professional Registration Review',
      subtitle: _regId,
      breadcrumbs: breadcrumbs,
      onBack: () => Get.back(),
      actions: _isPdfLoading
          ? const [spinner]
          : [
              OutlinedButton.icon(
                onPressed: _shareAsPdf,
                icon: const Icon(LucideIcons.share2, size: 18),
                label: const Text('Share'),
              ),
              ElevatedButton.icon(
                onPressed: _downloadAsPdf,
                icon: const Icon(LucideIcons.download, size: 18),
                label: Text(isTablet ? 'PDF' : 'Download PDF'),
              ),
            ],
    );
  }

  // ================= HEADER CARD =================

  Widget _buildHeaderCard(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isDesktop = deviceType == DeviceType.desktop;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _fullName,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: AppColor.textPrimary,
              ),
            ),
            _buildStatusBadge(cgDetails.hpRegStatus, deviceType),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _factChip(LucideIcons.graduationCap, cgDetails.hpRegEducation),
            _factChip(LucideIcons.idCard, 'ID: $_regId'),
          ],
        ),
      ],
    );

    final identity = Row(
      children: [
        _buildProfileAvatar(isMobile, deviceType == DeviceType.tablet),
        SizedBox(width: isMobile ? 14 : 20),
        Expanded(child: info),
      ],
    );

    return AppCard(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: isMobile
          // Phones approve/reject from the bottom bar.
          ? identity
          : isDesktop
              ? Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: 16),
                    _buildActionButtons(deviceType),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildActionButtons(deviceType),
                    ),
                  ],
                ),
    );
  }

  Widget _factChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.textTertiary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(bool isMobile, bool isTablet) {
    final size = isMobile ? 56.0 : (isTablet ? 64.0 : 72.0);
    final hasPhoto = _hasPhoto;

    return MouseRegion(
      cursor: hasPhoto ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: hasPhoto ? () => _showImageDialog(cgDetails.hpRegPhoto, 'Profile Photo') : null,
        child: AppAvatar(
          name: _fullName,
          imageUrl: hasPhoto ? cgDetails.hpRegPhoto : null,
          size: size,
        ),
      ),
    );
  }

  // ================= PERSONAL INFO SECTION =================

  Widget _buildPersonalInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: LucideIcons.user,
      deviceType: deviceType,
      child: _infoGrid([
        _buildInfoRow('First Name', cgDetails.hpRegFirstName, deviceType),
        _buildInfoRow('Last Name', cgDetails.hpRegLastName, deviceType),
        _buildInfoRow(
          'Date of Birth',
          cgDetails.hpRegDob != null
              ? cgDetails.hpRegDob!.toIso8601String().split('T').first
              : 'Not provided',
          deviceType,
        ),
        _buildInfoRow('Gender', cgDetails.hpRegGender.isNotEmpty ? cgDetails.hpRegGender : 'Not specified', deviceType),
        _buildInfoRow(
          'Marital Status',
          cgDetails.hpRegMaritalStatus.isNotEmpty ? cgDetails.hpRegMaritalStatus : 'Not specified',
          deviceType,
        ),
      ]),
    );
  }

  // ================= CONTACT INFO SECTION =================

  Widget _buildContactInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Contact Information',
      icon: LucideIcons.contact,
      deviceType: deviceType,
      child: _infoGrid([
        _buildInfoRow('Email', cgDetails.hpRegEmail, deviceType, isEmail: true),
        _buildInfoRow('Phone', cgDetails.hpRegPhoneNumber, deviceType, isPhone: true),
        _buildInfoRow('Address', cgDetails.hpRegAddress.isNotEmpty ? cgDetails.hpRegAddress : 'Not provided', deviceType),
        _buildInfoRow('City', cgDetails.hpRegCity.isNotEmpty ? cgDetails.hpRegCity : 'Not provided', deviceType),
        _buildInfoRow('State', cgDetails.hpRegState.isNotEmpty ? cgDetails.hpRegState : 'Not provided', deviceType),
        _buildInfoRow('Pincode', cgDetails.hpRegPinCode.isNotEmpty ? cgDetails.hpRegPinCode : 'N/A', deviceType),
      ]),
    );
  }

  // ================= PROFESSIONAL INFO SECTION =================

  Widget _buildProfessionalInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Professional Information',
      icon: LucideIcons.briefcase,
      deviceType: deviceType,
      child: _infoGrid([
        _buildInfoRow('Education', cgDetails.hpRegEducation, deviceType),
        _buildInfoRow('Experience', '${cgDetails.hpRegExperience} months', deviceType),
        _buildInfoRow('Identity Proof Type', cgDetails.hpRegIdentityProofType, deviceType),
        _buildInfoRow('Identity Proof Number', cgDetails.hpRegIdentityProofNumber, deviceType),
        _buildInfoRow('Registration ID', _regId, deviceType),
      ]),
    );
  }

  // ================= PAY INFO SECTION =================

  Widget _buildPayInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Pay Information',
      icon: LucideIcons.indianRupee,
      deviceType: deviceType,
      child: AppResponsiveGrid(
        minItemWidth: 150,
        maxColumns: 4,
        spacing: 12,
        children: [
          _buildPayCard('Live-in Pay', cgDetails.liveinPay ?? 'N/A', '/day'),
          _buildPayCard('Live-out Pay', cgDetails.liveoutPay ?? 'N/A', '/day'),
          _buildPayCard('Monthly Live-in', cgDetails.monthlyLiveinPay ?? 'N/A', '/month'),
          _buildPayCard('Monthly Live-out', cgDetails.monthlyLiveoutPay ?? 'N/A', '/month'),
        ],
      ),
    );
  }

  Widget _buildPayCard(String label, String amount, String period) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '₹',
                  style: TextStyle(fontSize: 15, color: AppColor.textSecondary),
                ),
                TextSpan(
                  text: amount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' $period',
                  style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LANGUAGES SECTION =================

  Widget _buildLanguagesSection(DeviceType deviceType) {
    final controller = Get.find<RegisterCgController>();
    final rawIds = cgDetails.hpRegLanguages.isNotEmpty
        ? cgDetails.hpRegLanguages.split(',').map((e) => e.trim()).toList()
        : <String>[];
    final languages = rawIds.map((id) {
      final match = controller.availableLanguages.firstWhereOrNull(
        (lang) => lang['id'].toString() == id,
      );
      return match != null ? (match['name'] ?? id).toString() : id;
    }).toList();

    return _buildSectionCard(
      title: 'Languages Known',
      icon: LucideIcons.globe,
      deviceType: deviceType,
      child: languages.isEmpty
          ? Text('Not provided',
              style: TextStyle(fontSize: 14, color: AppColor.textTertiary))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languages.map((lang) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: AppColor.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.languages,
                          size: 14, color: AppColor.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        lang,
                        style: TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ================= DOCUMENTS SECTION =================

  Widget _buildDocumentsSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Documents & Images',
      icon: LucideIcons.folder,
      deviceType: deviceType,
      child: Column(
        children: [
          _buildDocumentItem(
            'Profile Photo',
            cgDetails.hpRegPhoto,
            LucideIcons.user,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'ID Proof Front (${cgDetails.hpRegIdentityProofType})',
            cgDetails.hpRegIdentityProofFrontImage,
            LucideIcons.creditCard,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'ID Proof Back (${cgDetails.hpRegIdentityProofType})',
            cgDetails.hpRegIdentityProofBackImage,
            LucideIcons.creditCard,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'Education Certificate',
            cgDetails.hpRegEducationCertificate,
            LucideIcons.graduationCap,
            deviceType,
          ),
        ],
      ),
    );
  }

  // ================= STATUS CARD =================

  Widget _buildStatusCard(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Application Status',
      icon: LucideIcons.info,
      deviceType: deviceType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLargeStatusBadge(cgDetails.hpRegStatus, deviceType),
          const SizedBox(height: 16),
          _buildStatusInfo('Effective Date', _formatDate(cgDetails.hpEffectDate), deviceType),
          const SizedBox(height: 10),
          _buildStatusInfo('Application ID', _regId, deviceType),
          const SizedBox(height: 10),
          _buildStatusInfo('Priority', 'Normal', deviceType),
        ],
      ),
    );
  }

  // ================= TIMELINE CARD =================

  Widget _buildTimelineCard(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Activity Timeline',
      icon: LucideIcons.activity,
      deviceType: deviceType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineItem('Application Submitted', _formatDate(cgDetails.hpEffectDate), LucideIcons.fileUp, true, deviceType),
          _buildTimelineItem('Under Review', 'In Progress', LucideIcons.messageSquareText, cgDetails.hpRegStatus == 1, deviceType),
          _buildTimelineItem('Decision Made', cgDetails.hpRegStatus > 1 ? _getHPStatusText(cgDetails.hpRegStatus) : 'Pending', LucideIcons.circleCheck, cgDetails.hpRegStatus > 1, deviceType, isLast: true),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================

  /// Approve / reject, shown in the header card on tablet and desktop.
  Widget _buildActionButtons(DeviceType deviceType) {
    final controller = Get.find<RegisterCgController>();

    return Obx(() => controller.manageCgStatusLoading.value
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showRejectionDialog(controller),
                style: AppButtonStyles.dangerOutlined,
                icon: const Icon(LucideIcons.circleX, size: 18),
                label: const Text('Reject Application'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showApprovalDialog(controller),
                icon: const Icon(LucideIcons.circleCheck, size: 18),
                label: const Text('Approve Application'),
              ),
            ],
          ));
  }

  // ================= MOBILE BOTTOM BAR =================

  Widget _buildMobileBottomBar() {
    final controller = Get.find<RegisterCgController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() => controller.manageCgStatusLoading.value
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectionDialog(controller),
                      style: AppButtonStyles.dangerOutlined,
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _showApprovalDialog(controller),
                      child: const Text('Approve Application'),
                    ),
                  ),
                ],
              )),
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    required DeviceType deviceType,
  }) {
    return AppCard(
      title: title,
      icon: icon,
      padding: EdgeInsets.all(deviceType == DeviceType.mobile ? 16 : 20),
      child: child,
    );
  }

  /// Label/value pairs in two columns when the card is wide enough.
  Widget _infoGrid(List<Widget> rows) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final twoColumns = maxW >= 480;
      final itemW = twoColumns ? ((maxW - 24) / 2).floorToDouble() : maxW;
      return Wrap(
        spacing: 24,
        runSpacing: 18,
        children: [
          for (final r in rows) SizedBox(width: itemW, child: r),
        ],
      );
    });
  }

  Widget _buildInfoRow(
    String label,
    String value,
    DeviceType deviceType, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return AppInfoRow(
      label: label,
      value: value,
      icon: isEmail
          ? LucideIcons.mail
          : isPhone
              ? LucideIcons.phone
              : null,
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColor.borderSubtle, height: 1);
  }

  Widget _buildDocumentItem(String title, String imageUrl, IconData icon, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final hasValidImage = imageUrl.isNotEmpty && !imageUrl.endsWith('/NA') && !imageUrl.contains('/NA');
    final thumb = isMobile ? 44.0 : 48.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          hasValidImage
              ? Container(
                  width: thumb,
                  height: thumb,
                  decoration: BoxDecoration(
                    color: AppColor.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColor.borderSubtle),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : AppIconTile(icon: icon, tone: AppTone.neutral, size: thumb),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 13.5 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                AppStatusBadge(
                  label: hasValidImage ? 'Available' : 'Not uploaded',
                  tone: hasValidImage ? AppTone.success : AppTone.danger,
                  dense: true,
                ),
              ],
            ),
          ),
          if (hasValidImage) ...[
            IconButton(
              onPressed: () => _showImageDialog(imageUrl, title),
              icon: Icon(LucideIcons.eye, size: 18, color: AppColor.textSecondary),
              tooltip: 'View',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;

    late String text;
    late IconData icon;

    switch (status) {
      case 2:
        text = 'Approved';
        icon = LucideIcons.circleCheck;
        break;
      case 3:
        text = 'Rejected';
        icon = LucideIcons.circleX;
        break;
      case 4:
        text = 'Terminated';
        icon = LucideIcons.ban;
        break;
      default:
        text = isMobile ? 'Pending' : 'Pending Review';
        icon = LucideIcons.clock;
    }

    return AppStatusBadge(label: text, tone: toneForStatus(text), icon: icon);
  }

  Widget _buildLargeStatusBadge(int status, DeviceType deviceType) {
    late String text;
    late IconData icon;

    switch (status) {
      case 2:
        text = 'Approved';
        icon = LucideIcons.circleCheck;
        break;
      case 3:
        text = 'Rejected';
        icon = LucideIcons.circleX;
        break;
      case 4:
        text = 'Terminated';
        icon = LucideIcons.ban;
        break;
      default:
        text = 'Pending Review';
        icon = LucideIcons.clock;
    }

    final tone = toneForStatus(text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: tone.color),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: tone.color,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, DeviceType deviceType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon, bool isActive, DeviceType deviceType, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          AppIconTile(
            icon: icon,
            tone: isActive ? AppTone.primary : AppTone.neutral,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                    color: isActive ? AppColor.textPrimary : AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPER METHODS =================

  /// Returns the HP approval status label (1=Pending, 2=Approved, 3=Rejected, 4=Terminated).
  String _getHPStatusText(int status) {
    switch (status) {
      case 2:
        return 'Approved';
      case 3:
        return 'Rejected';
      case 4:
        return 'Terminated';
      case 1:
        return 'Pending';
      default:
        return 'Inactive';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // ================= IMAGE VIEWER DIALOG =================

  void _showImageDialog(String imageUrl, String title) {
    Get.dialog(
      AppDialog(
        title: title,
        icon: LucideIcons.image,
        maxWidth: 640,
        onClose: () => Get.back(),
        bodyPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 460,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.imageOff, size: 56, color: AppColor.textTertiary),
                      const SizedBox(height: 8),
                      Text('Failed to load image', style: TextStyle(color: AppColor.textTertiary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= APPROVAL / REJECTION DIALOGS =================

  void _showApprovalDialog(RegisterCgController controller) {
    Get.dialog(
      AppDialog(
        title: 'Approve Application',
        icon: LucideIcons.circleCheck,
        tone: AppTone.success,
        maxWidth: 460,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateCgStatus(cgDetails.hpRegId, 2, navigateToManageHp: true);
            },
            child: const Text('Approve'),
          ),
        ],
        child: Text(
          'Are you sure you want to approve ${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}\'s application?',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary),
        ),
      ),
    );
  }

  void _showRejectionDialog(RegisterCgController controller) {
    Get.dialog(
      AppDialog(
        title: 'Reject Application',
        icon: LucideIcons.circleX,
        tone: AppTone.danger,
        maxWidth: 460,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateCgStatus(cgDetails.hpRegId, 3, navigateToManageHp: true);
            },
            style: AppButtonStyles.danger,
            child: const Text('Reject'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Are you sure you want to reject ${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}\'s application?',
              style: TextStyle(fontSize: 14, height: 1.5, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for rejection...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PDF GENERATION =================

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    // Load font for Unicode support
    final fontData = await rootBundle.load('assets/fonts/inter/Inter-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final theme = pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf, boldItalic: ttf);

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/e_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        header: (context) => _buildPdfHeader(logoImage),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          // Title
          pw.Center(
            child: pw.Text(
              'Health Professional Registration Details',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              'Application ID: CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: pw.BoxDecoration(
                color: _getPdfStatusColor(cgDetails.hpRegStatus),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Text(
                'Status: ${_getHPStatusText(cgDetails.hpRegStatus)}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 12),

          // Personal Information
          _buildPdfSection('Personal Information', [
            _buildPdfRow('First Name', cgDetails.hpRegFirstName),
            _buildPdfRow('Last Name', cgDetails.hpRegLastName),
            _buildPdfRow('Date of Birth', cgDetails.hpRegDob != null ? cgDetails.hpRegDob!.toIso8601String().split('T').first : 'Not provided'),
            _buildPdfRow('Gender', cgDetails.hpRegGender.isNotEmpty ? cgDetails.hpRegGender : 'Not specified'),
            _buildPdfRow('Marital Status', cgDetails.hpRegMaritalStatus.isNotEmpty ? cgDetails.hpRegMaritalStatus : 'Not specified'),
          ]),

          // Contact Information
          _buildPdfSection('Contact Information', [
            _buildPdfRow('Email', cgDetails.hpRegEmail),
            _buildPdfRow('Phone', cgDetails.hpRegPhoneNumber),
            _buildPdfRow('Address', cgDetails.hpRegAddress.isNotEmpty ? cgDetails.hpRegAddress : 'Not provided'),
            _buildPdfRow('City', cgDetails.hpRegCity.isNotEmpty ? cgDetails.hpRegCity : 'Not provided'),
            _buildPdfRow('State', cgDetails.hpRegState.isNotEmpty ? cgDetails.hpRegState : 'Not provided'),
            _buildPdfRow('Pincode', cgDetails.hpRegPinCode.isNotEmpty ? cgDetails.hpRegPinCode : 'N/A'),
          ]),

          // Professional Information
          _buildPdfSection('Professional Information', [
            _buildPdfRow('Education', cgDetails.hpRegEducation),
            _buildPdfRow('Experience', '${cgDetails.hpRegExperience} months'),
            _buildPdfRow('Identity Proof Type', cgDetails.hpRegIdentityProofType),
            _buildPdfRow('Identity Proof Number', cgDetails.hpRegIdentityProofNumber),
            _buildPdfRow('Languages', cgDetails.hpRegLanguages),
          ]),

          if (cgDetails.hpEffectDate != null) ...[
            pw.SizedBox(height: 8),
            _buildPdfRow('Effective Date', _formatDate(cgDetails.hpEffectDate)),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfHeader(pw.MemoryImage? logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logoImage != null)
                pw.Image(logoImage, width: 40, height: 40),
              if (logoImage != null) pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Eldivex', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text('Health Care Services', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Health Professional Report', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Generated: ${_formatDate(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.blue, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Eldivex Admin - Confidential', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        ),
        pw.SizedBox(height: 6),
        ...rows,
        pw.SizedBox(height: 14),
      ],
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  PdfColor _getPdfStatusColor(int status) {
    switch (status) {
      case 2:
        return PdfColors.green;   // Approved
      case 3:
        return PdfColors.red;     // Rejected
      case 4:
        return PdfColors.grey700; // Terminated
      default:
        return PdfColors.orange;  // Pending (status 1) or unknown
    }
  }

  // ================= PDF DOWNLOAD =================

  void _downloadAsPdf() async {
    setState(() => _isPdfLoading = true);
    try {
      final bytes = await _generatePdfBytes();
      await Printing.layoutPdf(onLayout: (_) => bytes);
      HelperUi.showToast(message: "PDF ready for download");
    } catch (e) {
      HelperUi.showToast(message: "Failed to generate PDF", backgroundColor: Colors.red);
    } finally {
      setState(() => _isPdfLoading = false);
    }
  }

  // ================= PDF SHARE =================

  void _shareAsPdf() async {
    setState(() => _isPdfLoading = true);
    try {
      final bytes = await _generatePdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'CG_${cgDetails.hpRegFirstName}_${cgDetails.hpRegLastName}_${cgDetails.hpRegId}.pdf',
      );
      HelperUi.showToast(message: "PDF shared successfully");
    } catch (e) {
      HelperUi.showToast(message: "Failed to share PDF", backgroundColor: Colors.red);
    } finally {
      setState(() => _isPdfLoading = false);
    }
  }
}
