import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../hp_portal/views/hp_widgets.dart';
import '../controllers/client_controller.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          _patientCard(),
          const SizedBox(height: 12),
          _serviceCard(),
          const SizedBox(height: 12),
          if (_loading)
            HpUi.card(child: const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())))
          else ...[
            _caregiverCard(),
            const SizedBox(height: 12),
            _attendanceCard(),
          ],
        ],
      ),
    );
  }

  Widget _patientCard() => HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HpUi.sectionTitle('Patient'),
            HpUi.kv('Name', '${b['patient_name'] ?? '—'}'),
            HpUi.kv('Age', '${b['patient_age'] ?? '—'}'),
            HpUi.kv('Relation', '${b['patient_relation'] ?? '—'}'),
            HpUi.kv('Phone', '${b['patient_phone'] ?? '—'}'),
          ],
        ),
      );

  Widget _serviceCard() => HpUi.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HpUi.sectionTitle('Service'),
            HpUi.kv('Service', '${b['service_name'] ?? '—'}'),
            HpUi.kv('Status', '${b['status_label'] ?? '—'}'),
            HpUi.kv('Rate', '${b['base_rate'] ?? '—'} / ${b['base_unit'] ?? ''}'),
            HpUi.kv('Period', '${b['service_start_date'] ?? '—'} → ${b['service_end_date'] ?? '—'}'),
            HpUi.kv('Address',
                '${b['address_line1'] ?? ''} ${b['locality'] ?? ''} ${b['city'] ?? ''}'.trim()),
          ],
        ),
      );

  Widget _caregiverCard() {
    if (_hp.isEmpty) {
      return HpUi.card(child: HpUi.empty('No caregiver assigned yet.', icon: Icons.person_search));
    }
    final hp = _hp.first;
    final otp = hp['otp'];
    final verified = (hp['otp_verified'] ?? 0) == 1;
    return HpUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HpUi.sectionTitle('Assigned caregiver'),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.15),
                backgroundImage:
                    hp['hp_reg_photo_url'] != null ? NetworkImage(hp['hp_reg_photo_url']) : null,
                child: hp['hp_reg_photo_url'] == null
                    ? Icon(Icons.person, color: AppColor.cAppPrimaryColor)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${hp['hp_reg_first_name'] ?? ''} ${hp['hp_reg_last_name'] ?? ''}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: AppColor.cPrimaryHeadingColor)),
                    Text('${hp['hp_reg_experience'] ?? ''} yrs • ${hp['hp_reg_languages'] ?? ''}',
                        style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.call, color: AppColor.lightGreen),
                onPressed: () {},
              ),
            ],
          ),
          HpUi.kv('Phone', '${hp['hp_reg_phone_number'] ?? '—'}'),
          HpUi.kv('Education', '${hp['hp_reg_education'] ?? '—'}'),
          const SizedBox(height: 8),
          // Service-start OTP — shown to the client to hand to the caregiver on
          // day one. Hidden once verified.
          if (otp != null && '$otp'.isNotEmpty)
            _otpBox('$otp', verified),
        ],
      ),
    );
  }

  Widget _otpBox(String otp, bool verified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (verified ? AppColor.lightGreen : Colors.orange).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: (verified ? AppColor.lightGreen : Colors.orange).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(verified ? Icons.verified : Icons.vpn_key,
              color: verified ? AppColor.lightGreen : Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(verified ? 'Service start verified' : 'Service-start OTP',
                    style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
                Text(verified ? otp : otp,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 3,
                        color: AppColor.cPrimaryHeadingColor)),
              ],
            ),
          ),
          if (!verified)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
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
    return HpUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HpUi.sectionTitle('Caregiver attendance'),
          if (_attendance.isEmpty)
            Text('No attendance recorded yet.', style: TextStyle(color: AppColor.fontColorGrey))
          else
            ..._attendance.take(31).map((a) {
              final color = HpUi.attendanceColor(a['status']?.toString());
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: color),
                    const SizedBox(width: 10),
                    Expanded(child: Text('${a['att_date'] ?? a['from_date'] ?? ''}')),
                    Text('${a['check_in'] ?? ''}${a['check_out'] != null ? ' → ${a['check_out']}' : ''}',
                        style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12)),
                    const SizedBox(width: 10),
                    HpUi.statusChip((a['status'] ?? '—').toString().toUpperCase(), color),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
