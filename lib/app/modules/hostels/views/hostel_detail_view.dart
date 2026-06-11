import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../../register_cg/models/get_cg_details_model.dart';
import '../controllers/hostels_controller.dart';
import '../models/hostel_stay_model.dart';

class HostelDetailView extends StatelessWidget {
  const HostelDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HostelsController>();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(c.selectedHostel.value?.hostelName ?? 'Hostel')),
        backgroundColor: AppColor.whiteColor,
        foregroundColor: AppColor.blackColor,
        elevation: 0,
      ),
      floatingActionButton: Obx(() {
        final h = c.selectedHostel.value;
        if (h == null || h.status != 1) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          backgroundColor: AppColor.cAppPrimaryColor,
          foregroundColor: AppColor.buttonTextWhite,
          onPressed: () => _showAssignDialog(c),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Assign CG'),
        );
      }),
      body: Obx(() {
        final h = c.selectedHostel.value;
        if (h == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _infoCard(c),
            const SizedBox(height: 20),
            Text('Occupants',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.blackColor)),
            const SizedBox(height: 8),
            if (c.loadingStays.value)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (c.stays.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No caregivers assigned yet.',
                    style: TextStyle(color: AppColor.fontColorGrey)),
              )
            else
              ...c.stays.map((s) => _stayTile(c, s)),
          ],
        );
      }),
    );
  }

  Widget _infoCard(HostelsController c) {
    final h = c.selectedHostel.value!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 24, runSpacing: 12, children: [
            _kv('Gender', h.gender),
            _kv('Rate / day', '₹${h.ratePerDay.toStringAsFixed(0)}'),
            _kv('Capacity', h.capacity?.toString() ?? '—'),
            Obx(() => _kv('Occupied', '${c.activeOccupancy}'
                '${h.capacity != null ? ' / ${h.capacity}' : ''}')),
            if (h.location.isNotEmpty) _kv('Location', h.location),
            if ((h.contactPersonName ?? '').isNotEmpty)
              _kv('Contact', '${h.contactPersonName} ${h.contactPhone ?? ''}'),
          ]),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
          const SizedBox(height: 2),
          Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColor.blackColor)),
        ],
      );

  Widget _stayTile(HostelsController c, HostelStayModel s) {
    final closed = s.status != 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.cAppPrimaryColor.withValues(alpha: 0.12),
            child: Icon(Icons.person, color: AppColor.cAppPrimaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.hpName.isEmpty ? 'CG #${s.hpId}' : s.hpName,
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.blackColor)),
                const SizedBox(height: 2),
                Text(
                  'In: ${s.checkInDate}'
                  '${s.isOpen ? '  •  Ongoing' : '  •  Out: ${s.checkOutDate}'}'
                  '  •  ${s.nights} nights  •  ₹${s.charge.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey),
                ),
              ],
            ),
          ),
          if (closed)
            Text('Closed', style: TextStyle(color: AppColor.fontColorGrey, fontSize: 12))
          else
            TextButton(
              onPressed: () => _showCloseDialog(c, s),
              child: Text('Check out', style: TextStyle(color: AppColor.calenderRed)),
            ),
        ],
      ),
    );
  }

  // ── Assign CG dialog ─────────────────────────────────────────────────────────
  void _showAssignDialog(HostelsController c) {
    final h = c.selectedHostel.value!;
    final eligible = c.eligibleCgs(h.gender);
    final Rxn<int> selectedCgId = Rxn<int>();
    final checkInCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.whiteColor,
        title: Text('Assign CG to ${h.hostelName}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Only ${h.gender} caregivers are listed for this hostel.',
                  style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
              const SizedBox(height: 12),
              if (eligible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No ${h.gender} caregivers available.',
                      style: TextStyle(color: AppColor.calenderRed)),
                )
              else
                Obx(() => DropdownButtonFormField<int>(
                      initialValue: selectedCgId.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Caregiver', border: OutlineInputBorder()),
                      items: eligible
                          .map((GetCgDetails cg) => DropdownMenuItem<int>(
                                value: cg.hpRegId,
                                child: Text(
                                    '${cg.hpRegFirstName} ${cg.hpRegLastName}'.trim(),
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => selectedCgId.value = v,
                    )),
              const SizedBox(height: 12),
              TextField(
                controller: checkInCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Check-in date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 18)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    checkInCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cAppPrimaryColor,
                  foregroundColor: AppColor.buttonTextWhite,
                ),
                onPressed: (c.isSubmitting.value || selectedCgId.value == null)
                    ? null
                    : () async {
                        final ok = await c.assignCg(
                          hostelId: h.id,
                          hpId: selectedCgId.value!,
                          checkInDate: checkInCtrl.text,
                        );
                        if (ok) Get.back();
                      },
                child: const Text('Assign'),
              )),
        ],
      ),
    );
  }

  // ── Close stay dialog ─────────────────────────────────────────────────────────
  void _showCloseDialog(HostelsController c, HostelStayModel s) {
    final outCtrl = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColor.whiteColor,
        title: const Text('Check out caregiver'),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: outCtrl,
            readOnly: true,
            decoration: const InputDecoration(
                labelText: 'Check-out date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today, size: 18)),
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime.tryParse(s.checkInDate) ?? DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                outCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cAppPrimaryColor,
              foregroundColor: AppColor.buttonTextWhite,
            ),
            onPressed: () {
              Get.back();
              c.closeStay(s, outCtrl.text);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
