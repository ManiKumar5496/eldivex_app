import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/shimmer_loader.dart';


class ViewBanners extends GetView<BannersController> {
  const ViewBanners({super.key});

  @override
  BannersController get controller => Get.isRegistered<BannersController>()
      ? Get.find<BannersController>()
      : Get.put(BannersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body:  Obx(() {
        if (controller.getAllBannersLoading.value &&
            controller.allBannersData.value.isEmpty) {
          return Center(child: HelperUi().loader());
        }

        if (controller.loadError.value.isNotEmpty &&
            controller.allBannersData.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 40, color: AppColor.fontColorGrey),
                const SizedBox(height: 8),
                Text(controller.loadError.value,
                    style: TextStyle(color: AppColor.fontColorGrey)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: controller.getBannersFromApi,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.allBannersData.value.isEmpty) {
          return const Center(
            child: Text(
              "No Data Found",
              style: TextStyle(
                fontFamily: "poppins_regular",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        final banners = controller.filteredBanners;
        final rows = banners.map<DataRow>((banners) {
          return DataRow(
            cells: [
              DataCell(Text(banners.bannerName ?? '—')),
              DataCell(Text(banners.bannerDescription ?? '—')),
              DataCell(
                InkWell(
                  onTap: () {
                    if (banners.bannerImage != null &&
                        banners.bannerImage!.isNotEmpty) {
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            color: AppColor.whiteColor,
                            padding: const EdgeInsets.all(16),
                            width: 500,
                            height: 400,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                  banners.bannerImage!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text("Failed to load image"),
                                    );
                                  },
                                ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  banners.bannerImage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "View Image",
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                      width: 100,
                      child: Center(
                        child: ToggleSwitch(
                          minWidth: 100.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [Colors.green[800]!],
                            [Colors.red[800]!]
                          ],
                          activeFgColor: AppColor.buttonTextWhite,
                          inactiveBgColor: AppColor.fontColorGrey,
                          inactiveFgColor: AppColor.buttonTextWhite,
                          changeOnTap: banners.bannerId != null &&
                              controller.togglingBannerId.value == null,
                          initialLabelIndex:
                          banners.bannerStatus == 1 ? 0 : 1,
                          totalSwitches: 2,
                          labels: const ['Yes', 'No'],
                          radiusStyle:
                          true, // animate must be set to trut be set to true when using custom curve
                          onToggle: (index) {
                            final id = banners.bannerId;
                            if (id == null || index == null) return;
                            final newStatus = index == 0 ? 1 : 0;
                            if (newStatus == (banners.bannerStatus == 1 ? 1 : 0)) return;
                            controller.updateBannerStatus(newStatus, id);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ],
          );
        }).toList();
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.divColor),
                ),
                child: TextField(
                  onChanged: controller.searchBanners,
                  decoration: InputDecoration(
                    hintText: 'Search banners by name or description...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              Expanded(
          child: controller.getAllBannersLoading.value
              ? const ShimmerLoader.table()
              : DataTable2(
                bottomMargin: 20,
                checkboxHorizontalMargin: 12,
                dividerThickness: 0.5,
                dataRowHeight: 80,
                headingTextStyle: TextStyle(
                  fontFamily: "poppins_regular",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fontColorBlack,
                ),
                dataTextStyle: TextStyle(
                  fontFamily: "poppins_regular",
                  fontSize: 13,
                  color: AppColor.fontColorBlack,
                ),
                showBottomBorder: true,
                isVerticalScrollBarVisible: true,
                headingRowColor:
                WidgetStateProperty.all<Color>(AppColor.fieldColorGrey),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                columnSpacing: 12,
                horizontalMargin: 12,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: AppColor.divColor,
                    width: 0.5,
                  ),
                  verticalInside: BorderSide(
                    color: AppColor.divColor,
                    width: 0.5,
                  ),
                ),
                minWidth: 400,
                columns: [

                  DataColumn(
                    label: const Text('Banner Name'),

                  ),
                  DataColumn(
                    label: Text('Banner Description'),
                    //numeric: true,
                  ),
                  DataColumn(
                    label: const Text('Banner Image'),
                  ),
                  const DataColumn(
                    label: Text('Action'),
                    //numeric: true,
                  ),
                ],
                rows: rows),
              ),
            ],
          ),
        );
      }),
    );
  }
}
