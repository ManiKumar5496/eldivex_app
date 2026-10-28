import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ClientBookingDetailView extends StatefulWidget {
  const ClientBookingDetailView({super.key});

  @override
  State<ClientBookingDetailView> createState() => _ClientBookingDetailViewState();
}

class _ClientBookingDetailViewState extends State<ClientBookingDetailView> {
  final c = Get.find<ClientController>();
  late final Map<String, dynamic> b;
  late final int bookingId;

  List<Map<String, dynamic>> _hp = [];
  List<Map<String, dynamic>> _attendance = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    b = Map<String, dynamic>.from(Get.arguments ?? {});
    bookingId = b['booking_id'] is int ? b['booking_id'] : int.tryParse('${b['booking_id']}') ?? 0;
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      c.fetchAssignedHp(bookingId),
      c.fetchBookingAttendance(bookingId),
    ]);
    if (!mounted) return;
    setState(() {
      _hp = results[0];
      _attendance = results[1];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: HpUi.pagePadding(context, top: 20),
        children: [
          _patientCard(),
          const SizedBox(height: 16),
          _serviceCard(),
          const SizedBox(height: 16),
          if (_loading)
            HpUi.card(child: HpUi.loader())
          else ...[
            _caregiverCard(),
            const SizedBox(height: 16),
            _attendanceCard(),
          ],
        ],
      ),
    );
  }

  Widget _patientCard() => HpUi.section(
        title: 'Patient',
        icon: LucideIcons.user,
        children: [
          HpUi.kv('Name', '${b['patient_name'] ?? '—'}'),
          HpUi.kv('Age', '${b['patient_age'] ?? '—'}'),
          HpUi.kv('Relation', '${b['patient_relation'] ?? '—'}'),
          HpUi.kv('Phone', '${b['patient_phone'] ?? '—'}'),
        ],
      );

  Widget _serviceCard() {
    final status = '${b['status_label'] ?? ''}';
    return HpUi.section(
      title: 'Service',
      icon: LucideIcons.stethoscope,
      children: [
        HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
        status.isEmpty || status == 'NA'
            ? HpUi.kv('Status', '—')
            : AppInfoRow(
                label: 'Status',
                horizontal: true,
                labelWidth: 112,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: AppStatusBadge.status(status),
                ),
              ),
        HpUi.kv('Rate', '${b['base_rate'] ?? '—'} / ${b['base_unit'] ?? ''}'),
        HpUi.kv('Period', '${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}'),
        HpUi.kv('Address',
            '${b['address_line1'] ?? ''} ${b['locality'] ?? ''} ${b['city'] ?? ''}'.trim()),
      ],
    );
  }

  Widget _caregiverCard() {
    if (_hp.isEmpty) {
      return const AppCard(
        title: 'Assigned caregiver',
        icon: LucideIcons.heartPulse,
        padding: EdgeInsets.zero,
        child: AppEmptyState(
          compact: true,
          icon: LucideIcons.userSearch,
          title: 'No caregiver assigned yet.',
          message: 'We will let you know as soon as one is assigned.',
        ),
      );
    }
    final hp = _hp.first;
    final otp = hp['otp'];
    final verified = (hp['otp_verified'] ?? 0) == 1;
    final name = '${hp['hp_reg_first_name'] ?? ''} ${hp['hp_reg_last_name'] ?? ''}';
    return HpUi.section(
      title: 'Assigned caregiver',
      icon: LucideIcons.heartPulse,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              AppAvatar(
                name: name,
                imageUrl: hp['hp_reg_photo_url']?.toString(),
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${hp['hp_reg_experience'] ?? ''} yrs • ${hp['hp_reg_languages'] ?? ''}',
                        style: TextStyle(color: AppColor.textTertiary, fontSize: 12.5)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Call',
                style: IconButton.styleFrom(
                  backgroundColor: AppColor.successSoft,
                  foregroundColor: AppColor.success,
                ),
                icon: const Icon(LucideIcons.phone, size: 18),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColor.borderSubtle),
        const SizedBox(height: 4),
        HpUi.kv('Phone', '${hp['hp_reg_phone_number'] ?? '—'}'),
        HpUi.kv('Education', '${hp['hp_reg_education'] ?? '—'}'),
        // Service-start OTP — shown to the client to hand to the caregiver on
        // day one. Hidden once verified.
        if (otp != null && '$otp'.isNotEmpty) ...[
          const SizedBox(height: 6),
          _otpBox('$otp', verified),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _otpBox(String otp, bool verified) {
    final tone = verified ? AppTone.success : AppTone.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tone.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AppIconTile(
            icon: verified ? LucideIcons.badgeCheck : LucideIcons.keyRound,
            tone: tone,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(verified ? 'Service start verified' : 'Service-start OTP',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary)),
                const SizedBox(height: 2),
                Text(verified ? otp : otp,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: AppColor.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          if (!verified)
            IconButton(
              tooltip: 'Copy OTP',
              icon: const Icon(LucideIcons.copy, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: otp));
                HelperUi.showToast(message: 'OTP copied', backgroundColor: Get.theme.colorScheme.primary);
              },
            ),
        ],
      ),
    );
  }

  Widget _attendanceCard() {
    return AppCard(
      title: 'Caregiver attendance',
      icon: LucideIcons.clipboardCheck,
      padding: EdgeInsets.zero,
      child: _attendance.isEmpty
          ? const AppEmptyState(
              compact: true,
              icon: LucideIcons.calendarDays,
              title: 'No attendance recorded yet.',
            )
          : Column(
              children: [
                for (final entry in _attendance.take(31).toList().asMap().entries) ...[
                  if (entry.key > 0) Divider(height: 1, color: AppColor.borderSubtle),
                  _attendanceRow(entry.value),
                ],
              ],
            ),
    );
  }

  Widget _attendanceRow(Map<String, dynamic> a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a['att_date'] ?? a['from_date'] ?? ''}',
                    style: TextStyle(fontSize: 14, color: AppColor.textPrimary)),
                if (a['check_in'] != null || a['check_out'] != null) ...[
                  const SizedBox(height: 2),
                  Text('${a['check_in'] ?? ''}${a['check_out'] != null ? ' → ${a['check_out']}' : ''}',
                      style: TextStyle(color: AppColor.textTertiary, fontSize: 12.5)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          HpUi.attendanceBadge(a['status']?.toString(), dense: true),
        ],
      ),
    );
  }
}
