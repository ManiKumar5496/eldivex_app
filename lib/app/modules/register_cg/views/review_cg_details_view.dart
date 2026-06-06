import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/enums.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/register_cg_controller.dart';
import '../models/get_cg_details_model.dart';

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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          _buildAppBar(deviceType),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(deviceType),
                  SizedBox(height: isMobile ? 16 : (isTablet ? 20 : SizeConfig.blockSizeVertical * 2.5)),
                  _buildMainContent(deviceType),
                ],
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
    final isTablet = deviceType == DeviceType.tablet;

    if (isMobile) {
      return Column(
        children: [
          _buildStatusCard(deviceType),
          const SizedBox(height: 16),
          _buildPersonalInfoSection(deviceType),
          const SizedBox(height: 16),
          _buildContactInfoSection(deviceType),
          const SizedBox(height: 16),
          _buildProfessionalInfoSection(deviceType),
          const SizedBox(height: 16),
          _buildPayInfoSection(deviceType),
          const SizedBox(height: 16),
          _buildLanguagesSection(deviceType),
          const SizedBox(height: 16),
          _buildDocumentsSection(deviceType),
          const SizedBox(height: 16),
          _buildTimelineCard(deviceType),
          const SizedBox(height: 80),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildPersonalInfoSection(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildContactInfoSection(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildProfessionalInfoSection(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildPayInfoSection(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildLanguagesSection(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildDocumentsSection(deviceType),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildStatusCard(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildTimelineCard(deviceType),
              SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildActionButtons(deviceType),
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

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HP Review',
                    style: AppTextStyles.heading.copyWith(fontSize: 16),
                  ),
                  Text(
                    'CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}',
                    style: AppTextStyles.regular14Gre.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_isPdfLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 45),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 12),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
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
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2.5,
        vertical: isTablet ? 16 : SizeConfig.blockSizeVertical * 2,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to List',
          ),
          SizedBox(width: isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Health Professional Registration Review',
                  style: AppTextStyles.heading.copyWith(fontSize: isTablet ? 18 : 20),
                ),
                SizedBox(height: isTablet ? 2 : SizeConfig.blockSizeVertical * 0.3),
                Text(
                  'CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}',
                  style: AppTextStyles.regular14Gre,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (_isPdfLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            OutlinedButton.icon(
              onPressed: _shareAsPdf,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
                  vertical: isTablet ? 12 : SizeConfig.blockSizeVertical * 1.2,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1),
            ElevatedButton.icon(
              onPressed: _downloadAsPdf,
              icon: const Icon(Icons.download, color: Colors.white, size: 18),
              label: Text(isTablet ? 'PDF' : 'Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
                  vertical: isTablet ? 12 : SizeConfig.blockSizeVertical * 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= HEADER CARD =================

  Widget _buildHeaderCard(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2.5)),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Photo from network
              _buildProfileAvatar(isMobile, isTablet),
              SizedBox(width: isMobile ? 12 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}',
                      style: AppTextStyles.bold20.copyWith(
                        fontSize: isMobile ? 18 : (isTablet ? 20 : 24),
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : (isTablet ? 6 : SizeConfig.blockSizeVertical * 0.5)),
                    if (!isMobile)
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : SizeConfig.blockSizeHorizontal * 1.2,
                              vertical: isTablet ? 4 : SizeConfig.blockSizeVertical * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.cPrimaryButtonColor.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.school, size: 16, color: AppColor.cPrimaryButtonColor),
                                SizedBox(width: isTablet ? 4 : SizeConfig.blockSizeHorizontal * 0.5),
                                Text(
                                  cgDetails.hpRegEducation,
                                  style: AppTextStyles.regular14black.copyWith(
                                    color: AppColor.cPrimaryButtonColor,
                                    fontSize: isTablet ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1),
                          Text(
                            'ID: CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}',
                            style: AppTextStyles.regular14Gre.copyWith(fontSize: isTablet ? 12 : 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!isMobile) _buildStatusBadge(cgDetails.hpRegStatus, deviceType),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.cPrimaryButtonColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school, size: 14, color: AppColor.cPrimaryButtonColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cgDetails.hpRegEducation,
                            style: TextStyle(color: AppColor.cPrimaryButtonColor, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(cgDetails.hpRegStatus, deviceType),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(bool isMobile, bool isTablet) {
    final radius = isMobile ? 30.0 : (isTablet ? 35.0 : SizeConfig.blockSizeHorizontal * 4);
    final hasPhoto = cgDetails.hpRegPhoto.isNotEmpty && !cgDetails.hpRegPhoto.contains('/NA');

    return GestureDetector(
      onTap: hasPhoto ? () => _showImageDialog(cgDetails.hpRegPhoto, 'Profile Photo') : null,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColor.cPrimaryButtonColor.withValues(alpha:0.1),
        backgroundImage: hasPhoto ? NetworkImage(cgDetails.hpRegPhoto) : null,
        child: hasPhoto
            ? null
            : Text(
                '${cgDetails.hpRegFirstName.isNotEmpty ? cgDetails.hpRegFirstName[0] : ''}${cgDetails.hpRegLastName.isNotEmpty ? cgDetails.hpRegLastName[0] : ''}',
                style: TextStyle(
                  fontSize: isMobile ? 24 : (isTablet ? 28 : 32),
                  fontWeight: FontWeight.bold,
                  color: AppColor.cPrimaryButtonColor,
                ),
              ),
      ),
    );
  }

  // ================= PERSONAL INFO SECTION =================

  Widget _buildPersonalInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      deviceType: deviceType,
      child: Column(
        children: [
          _buildInfoRow('First Name', cgDetails.hpRegFirstName, deviceType),
          _buildDivider(),
          _buildInfoRow('Last Name', cgDetails.hpRegLastName, deviceType),
          _buildDivider(),
          _buildInfoRow(
            'Date of Birth',
            cgDetails.hpRegDob != null
                ? cgDetails.hpRegDob!.toIso8601String().split('T').first
                : 'Not provided',
            deviceType,
          ),
          _buildDivider(),
          _buildInfoRow('Gender', cgDetails.hpRegGender.isNotEmpty ? cgDetails.hpRegGender : 'Not specified', deviceType),
          _buildDivider(),
          _buildInfoRow(
            'Marital Status',
            cgDetails.hpRegMaritalStatus.isNotEmpty ? cgDetails.hpRegMaritalStatus : 'Not specified',
            deviceType,
          ),
        ],
      ),
    );
  }

  // ================= CONTACT INFO SECTION =================

  Widget _buildContactInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      deviceType: deviceType,
      child: Column(
        children: [
          _buildInfoRow('Email', cgDetails.hpRegEmail, deviceType, isEmail: true),
          _buildDivider(),
          _buildInfoRow('Phone', cgDetails.hpRegPhoneNumber, deviceType, isPhone: true),
          _buildDivider(),
          _buildInfoRow('Address', cgDetails.hpRegAddress.isNotEmpty ? cgDetails.hpRegAddress : 'Not provided', deviceType),
          _buildDivider(),
          _buildInfoRow('City', cgDetails.hpRegCity.isNotEmpty ? cgDetails.hpRegCity : 'Not provided', deviceType),
          _buildDivider(),
          _buildInfoRow('State', cgDetails.hpRegState.isNotEmpty ? cgDetails.hpRegState : 'Not provided', deviceType),
          _buildDivider(),
          _buildInfoRow('Pincode', cgDetails.hpRegPinCode.isNotEmpty ? cgDetails.hpRegPinCode : 'N/A', deviceType),
        ],
      ),
    );
  }

  // ================= PROFESSIONAL INFO SECTION =================

  Widget _buildProfessionalInfoSection(DeviceType deviceType) {
    return _buildSectionCard(
      title: 'Professional Information',
      icon: Icons.work_outline,
      deviceType: deviceType,
      child: Column(
        children: [
          _buildInfoRow('Education', cgDetails.hpRegEducation, deviceType),
          _buildDivider(),
          _buildInfoRow('Experience', '${cgDetails.hpRegExperience} months', deviceType),
          _buildDivider(),
          _buildInfoRow('Identity Proof Type', cgDetails.hpRegIdentityProofType, deviceType),
          _buildDivider(),
          _buildInfoRow('Identity Proof Number', cgDetails.hpRegIdentityProofNumber, deviceType),
          _buildDivider(),
          _buildInfoRow('Registration ID', 'CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}', deviceType),
        ],
      ),
    );
  }

  // ================= PAY INFO SECTION =================

  Widget _buildPayInfoSection(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;

    return _buildSectionCard(
      title: 'Pay Information',
      icon: Icons.currency_rupee,
      deviceType: deviceType,
      child: Column(
        children: [
          if (isMobile) ...[
            _buildPayCard('Live-in Pay', cgDetails.liveinPay ?? 'N/A', '/day', Colors.blue),
            const SizedBox(height: 8),
            _buildPayCard('Live-out Pay', cgDetails.liveoutPay ?? 'N/A', '/day', Colors.green),
            const SizedBox(height: 8),
            _buildPayCard('Monthly Live-in', cgDetails.monthlyLiveinPay ?? 'N/A', '/month', Colors.orange),
            const SizedBox(height: 8),
            _buildPayCard('Monthly Live-out', cgDetails.monthlyLiveoutPay ?? 'N/A', '/month', Colors.purple),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildPayCard('Live-in Pay', cgDetails.liveinPay ?? 'N/A', '/day', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildPayCard('Live-out Pay', cgDetails.liveoutPay ?? 'N/A', '/day', Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPayCard('Monthly Live-in', cgDetails.monthlyLiveinPay ?? 'N/A', '/month', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildPayCard('Monthly Live-out', cgDetails.monthlyLiveoutPay ?? 'N/A', '/month', Colors.purple)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayCard(String label, String amount, String period, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.regular14Gre.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 16, color: color),
              Text(
                amount,
                style: AppTextStyles.bold20.copyWith(fontSize: 18, color: color),
              ),
              Text(
                period,
                style: AppTextStyles.regular14Gre.copyWith(fontSize: 11),
              ),
            ],
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
      icon: Icons.language,
      deviceType: deviceType,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages.map((lang) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.cPrimaryButtonColor.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.cPrimaryButtonColor.withValues(alpha:0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate, size: 14, color: AppColor.cPrimaryButtonColor),
                const SizedBox(width: 6),
                Text(
                  lang,
                  style: TextStyle(
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.w500,
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
      icon: Icons.folder_outlined,
      deviceType: deviceType,
      child: Column(
        children: [
          _buildDocumentItem(
            'Profile Photo',
            cgDetails.hpRegPhoto,
            Icons.person,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'ID Proof Front (${cgDetails.hpRegIdentityProofType})',
            cgDetails.hpRegIdentityProofFrontImage,
            Icons.credit_card,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'ID Proof Back (${cgDetails.hpRegIdentityProofType})',
            cgDetails.hpRegIdentityProofBackImage,
            Icons.credit_card,
            deviceType,
          ),
          _buildDivider(),
          _buildDocumentItem(
            'Education Certificate',
            cgDetails.hpRegEducationCertificate,
            Icons.school,
            deviceType,
          ),
        ],
      ),
    );
  }

  // ================= STATUS CARD =================

  Widget _buildStatusCard(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2)),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: isMobile ? 18 : 20, color: AppColor.cPrimaryButtonColor),
              SizedBox(width: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1)),
              Text(
                'Application Status',
                style: AppTextStyles.regular16blue.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeVertical * 2)),
          Center(child: _buildLargeStatusBadge(cgDetails.hpRegStatus, deviceType)),
          SizedBox(height: isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeVertical * 2)),
          _buildStatusInfo('Effective Date', _formatDate(cgDetails.hpEffectDate), deviceType),
          SizedBox(height: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeVertical * 1)),
          _buildStatusInfo('Application ID', 'CAG-${cgDetails.hpRegId.toString().padLeft(3, '0')}', deviceType),
          SizedBox(height: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeVertical * 1)),
          _buildStatusInfo('Priority', 'Normal', deviceType),
        ],
      ),
    );
  }

  // ================= TIMELINE CARD =================

  Widget _buildTimelineCard(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2)),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: isMobile ? 18 : 20, color: AppColor.cPrimaryButtonColor),
              SizedBox(width: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1)),
              Text(
                'Activity Timeline',
                style: AppTextStyles.regular16blue.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeVertical * 2)),
          _buildTimelineItem('Application Submitted', _formatDate(cgDetails.hpEffectDate), Icons.file_upload, true, deviceType),
          _buildTimelineItem('Under Review', 'In Progress', Icons.rate_review, cgDetails.hpRegStatus == 1, deviceType),
          _buildTimelineItem('Decision Made', cgDetails.hpRegStatus > 1 ? _getHPStatusText(cgDetails.hpRegStatus) : 'Pending', Icons.check_circle, cgDetails.hpRegStatus > 1, deviceType),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================

  Widget _buildActionButtons(DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;
    final controller = Get.find<RegisterCgController>();

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Actions',
            style: AppTextStyles.regular16blue.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 14 : 16,
            ),
          ),
          SizedBox(height: isTablet ? 16 : SizeConfig.blockSizeVertical * 2),
          Obx(() => controller.manageCgStatusLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(controller),
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      label: const Text('Approve Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lightGreen,
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : SizeConfig.blockSizeVertical * 1.5),
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : SizeConfig.blockSizeVertical * 1),
                    OutlinedButton.icon(
                      onPressed: () => _showRejectionDialog(controller),
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                      label: const Text('Reject Application'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : SizeConfig.blockSizeVertical * 1.5),
                      ),
                    ),
                  ],
                )),
        ],
      ),
    );
  }

  // ================= MOBILE BOTTOM BAR =================

  Widget _buildMobileBottomBar() {
    final controller = Get.find<RegisterCgController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => controller.manageCgStatusLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectionDialog(controller),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _showApprovalDialog(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2)),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isMobile ? 18 : 20, color: AppColor.cPrimaryButtonColor),
              SizedBox(width: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeHorizontal * 1)),
              Text(
                title,
                style: AppTextStyles.regular16blue.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : (isTablet ? 12 : SizeConfig.blockSizeVertical * 1.5)),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    DeviceType deviceType, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.regular14Gre.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (isEmail) Icon(Icons.email, size: 14, color: AppColor.cPrimaryButtonColor),
                if (isPhone) Icon(Icons.phone, size: 14, color: AppColor.cPrimaryButtonColor),
                if (isEmail || isPhone) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.regular14black.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : SizeConfig.blockSizeVertical * 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.regular14Gre.copyWith(fontSize: isTablet ? 12 : 14)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isEmail) Icon(Icons.email, size: 16, color: AppColor.cPrimaryButtonColor),
                if (isPhone) Icon(Icons.phone, size: 16, color: AppColor.cPrimaryButtonColor),
                if (isEmail || isPhone) SizedBox(width: isTablet ? 4 : SizeConfig.blockSizeHorizontal * 0.5),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.regular14black.copyWith(fontWeight: FontWeight.w500, fontSize: isTablet ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColor.divColor, height: 1);
  }

  Widget _buildDocumentItem(String title, String imageUrl, IconData icon, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final hasValidImage = imageUrl.isNotEmpty && !imageUrl.endsWith('/NA') && !imageUrl.contains('/NA');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : (isTablet ? 8 : SizeConfig.blockSizeVertical * 1)),
      child: Row(
        children: [
          Container(
            width: isMobile ? 48 : 56,
            height: isMobile ? 48 : 56,
            decoration: BoxDecoration(
              color: hasValidImage ? null : AppColor.cPrimaryButtonColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.divColor),
              image: hasValidImage
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasValidImage
                ? null
                : Icon(icon, color: AppColor.cPrimaryButtonColor, size: isMobile ? 20 : 24),
          ),
          SizedBox(width: isMobile ? 10 : (isTablet ? 12 : SizeConfig.blockSizeHorizontal * 1.5)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.regular14black.copyWith(fontSize: isMobile ? 13 : 14),
                ),
                Text(
                  hasValidImage ? 'Available' : 'Not uploaded',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasValidImage ? AppColor.lightGreen : AppColor.calenderRed,
                  ),
                ),
              ],
            ),
          ),
          if (hasValidImage) ...[
            IconButton(
              onPressed: () => _showImageDialog(imageUrl, title),
              icon: Icon(Icons.visibility, size: isMobile ? 18 : 20, color: AppColor.cPrimaryButtonColor),
              tooltip: 'View',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    late Color bg, fg;
    late String text;
    late IconData icon;

    switch (status) {
      case 2:
        bg = AppColor.lightGreen.withValues(alpha:0.15);
        fg = AppColor.lightGreen;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case 3:
        bg = Colors.red.withValues(alpha:0.15);
        fg = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case 4:
        bg = Colors.grey.withValues(alpha:0.15);
        fg = Colors.grey;
        text = 'Terminated';
        icon = Icons.block;
        break;
      default:
        bg = AppColor.calenderRed.withValues(alpha:0.15);
        fg = AppColor.calenderRed;
        text = isMobile ? 'Pending' : 'Pending Review';
        icon = Icons.access_time;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : (isTablet ? 10 : SizeConfig.blockSizeHorizontal * 1.5),
        vertical: isMobile ? 4 : (isTablet ? 6 : SizeConfig.blockSizeVertical * 0.8),
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 12 : (isTablet ? 14 : 16), color: fg),
          SizedBox(width: isMobile ? 4 : (isTablet ? 4 : SizeConfig.blockSizeHorizontal * 0.6)),
          Text(
            text,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: isMobile ? 11 : (isTablet ? 12 : 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatusBadge(int status, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    late Color bg, fg;
    late String text;
    late IconData icon;

    switch (status) {
      case 2:
        bg = AppColor.lightGreen.withValues(alpha:0.15);
        fg = AppColor.lightGreen;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case 3:
        bg = Colors.red.withValues(alpha:0.15);
        fg = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case 4:
        bg = Colors.grey.withValues(alpha:0.15);
        fg = Colors.grey;
        text = 'Terminated';
        icon = Icons.block;
        break;
      default:
        bg = AppColor.calenderRed.withValues(alpha:0.15);
        fg = AppColor.calenderRed;
        text = 'Pending Review';
        icon = Icons.access_time;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 16 : SizeConfig.blockSizeHorizontal * 2),
        vertical: isMobile ? 12 : (isTablet ? 12 : SizeConfig.blockSizeVertical * 1.5),
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 32 : (isTablet ? 36 : 40), color: fg),
          SizedBox(height: isMobile ? 4 : (isTablet ? 6 : SizeConfig.blockSizeVertical * 0.5)),
          Text(
            text,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : (isTablet ? 15 : 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.regular14Gre.copyWith(fontSize: isMobile ? 12 : (isTablet ? 12 : 14))),
        Text(
          value,
          style: AppTextStyles.regular14black.copyWith(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : (isTablet ? 12 : 14)),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon, bool isActive, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : (isTablet ? 12 : SizeConfig.blockSizeVertical * 1.5)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : (isTablet ? 8 : SizeConfig.blockSizeHorizontal * 0.8)),
            decoration: BoxDecoration(
              color: isActive ? AppColor.cPrimaryButtonColor.withValues(alpha:0.1) : Colors.grey.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: isMobile ? 18 : 20, color: isActive ? AppColor.cPrimaryButtonColor : Colors.grey),
          ),
          SizedBox(width: isMobile ? 10 : (isTablet ? 12 : SizeConfig.blockSizeHorizontal * 1.5)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.regular14black.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
                Text(time, style: AppTextStyles.regular14Gre.copyWith(fontSize: isMobile ? 11 : 14)),
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
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bold20.copyWith(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APPROVAL / REJECTION DIALOGS =================

  void _showApprovalDialog(RegisterCgController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColor.lightGreen),
            const SizedBox(width: 8),
            const Text('Approve Application'),
          ],
        ),
        content: Text(
          'Are you sure you want to approve ${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}\'s application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateCgStatus(cgDetails.hpRegId, 2, navigateToManageHp: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.lightGreen),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(RegisterCgController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Reject Application'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject ${cgDetails.hpRegFirstName} ${cgDetails.hpRegLastName}\'s application?'),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for rejection...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateCgStatus(cgDetails.hpRegId, 3, navigateToManageHp: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
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
