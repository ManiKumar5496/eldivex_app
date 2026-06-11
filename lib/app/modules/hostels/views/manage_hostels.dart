import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../controllers/hostels_controller.dart';
import '../models/get_hostels_model.dart';
import 'create_hostel_screen.dart';
import 'hostel_detail_view.dart';

class ManageHostelsView extends StatelessWidget {
  const ManageHostelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<HostelsController>()
        ? Get.find<HostelsController>()
        : Get.put(HostelsController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Manage Hostels',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColor.blackColor)),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cAppPrimaryColor,
                    foregroundColor: AppColor.buttonTextWhite,
                  ),
                  onPressed: () {
                    c.prepareCreate();
                    Get.to(() => const CreateHostelScreen());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Hostel'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => c.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search by name or city…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColor.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = c.filteredHostels;
                if (list.isEmpty) {
                  return Center(
                    child: Text('No hostels yet. Add one to get started.',
                        style: TextStyle(color: AppColor.fontColorGrey)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.fetchHostels,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: 168,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _HostelCard(hostel: list[i], c: c),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostelCard extends StatelessWidget {
  final GetHostelsModel hostel;
  final HostelsController c;
  const _HostelCard({required this.hostel, required this.c});

  @override
  Widget build(BuildContext context) {
    final isMale = hostel.gender.toLowerCase() == 'male';
    final genderColor = isMale ? const Color(0xFF2D7DD2) : const Color(0xFFD81B8C);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        c.openHostel(hostel);
        Get.to(() => const HostelDetailView());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.fontColorGrey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(hostel.hostelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.blackColor)),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      c.prepareEdit(hostel);
                      Get.to(() => const CreateHostelScreen());
                    } else if (v == 'toggle') {
                      c.toggleStatus(hostel);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(hostel.status == 1 ? 'Deactivate' : 'Activate'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: genderColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(hostel.gender,
                      style: TextStyle(
                          color: genderColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on_outlined, size: 14, color: AppColor.fontColorGrey),
                Expanded(
                  child: Text(hostel.location.isEmpty ? '—' : hostel.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColor.fontColorGrey, fontSize: 13)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _stat('₹${hostel.ratePerDay.toStringAsFixed(0)}/day', Icons.payments_outlined),
                const SizedBox(width: 16),
                _stat(hostel.capacity == null ? 'No cap' : '${hostel.capacity} beds',
                    Icons.bed_outlined),
                const Spacer(),
                if (hostel.status != 1)
                  Text('Inactive',
                      style: TextStyle(color: AppColor.calenderRed, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.cAppPrimaryColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AppColor.blackColor, fontSize: 13)),
      ],
    );
  }
}
