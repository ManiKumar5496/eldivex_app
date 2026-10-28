import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/shimmer_loader.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';


class ViewBanners extends GetView<BannersController> {
  const ViewBanners({super.key});

  @override
  BannersController get controller => Get.isRegistered<BannersController>()
      ? Get.find<BannersController>()
      : Get.put(BannersController());

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final hPad = narrow ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body:  Obx(() {
        if (controller.getAllBannersLoading.value &&
            controller.allBannersData.value.isEmpty) {
          return Center(child: HelperUi().loader());
        }

        if (controller.loadError.value.isNotEmpty &&
            controller.allBannersData.value.isEmpty) {
          return AppEmptyState(
            icon: LucideIcons.circleAlert,
            tone: AppTone.danger,
            title: "Couldn't load banners",
            message: controller.loadError.value,
            actionLabel: 'Retry',
            actionIcon: LucideIcons.refreshCw,
            onAction: controller.getBannersFromApi,
          );
        }

        if (controller.allBannersData.value.isEmpty) {
          return const AppEmptyState(
            icon: LucideIcons.image,
            title: "No Data Found",
            message: 'Banners you create will appear here.',
          );
        }
        final banners = controller.filteredBanners;
        final rows = banners.map<DataRow>((banners) {
          return DataRow(
            cells: [
              DataCell(Text(
                banners.bannerName ?? '—',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              )),
              DataCell(Text(
                banners.bannerDescription ?? '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, color: AppColor.textSecondary),
              )),
              DataCell(
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  onTap: () {
                    if (banners.bannerImage != null &&
                        banners.bannerImage!.isNotEmpty) {
                      Get.dialog(
                        AppDialog(
                          title: 'Banner image',
                          subtitle: banners.bannerName,
                          icon: LucideIcons.image,
                          maxWidth: 560,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 340,
                                decoration: BoxDecoration(
                                  color: AppColor.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border:
                                      Border.all(color: AppColor.borderSubtle),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  banners.bannerImage!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const AppEmptyState(
                                      icon: LucideIcons.imageOff,
                                      title: "Failed to load image",
                                      compact: true,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              SelectableText(
                                banners.bannerImage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.textTertiary,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.image,
                            size: 16, color: AppColor.cAppPrimaryColor),
                        const SizedBox(width: 6),
                        Text(
                          "View Image",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColor.cAppPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  height: 28,
                  width: 104,
                  child: ToggleSwitch(
                    minWidth: 52.0,
                    minHeight: 28.0,
                    cornerRadius: 8.0,
                    fontSize: 12.5,
                    dividerColor: Colors.transparent,
                    activeBgColors: [
                      [AppColor.success],
                      [AppColor.danger]
                    ],
                    activeFgColor: AppColor.pureWhite,
                    inactiveBgColor: AppColor.neutralSoft,
                    inactiveFgColor: AppColor.textSecondary,
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
              ),
            ],
          );
        }).toList();
        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppCard(
                  expandChild: true,
                  padding: EdgeInsets.zero,
                  title: 'All banners',
                  subtitle:
                      '${banners.length} ${banners.length == 1 ? 'banner' : 'banners'}',
                  actions: [
                    AppSearchField(
                      onChanged: controller.searchBanners,
                      hint: 'Search banners by name or description...',
                      width: narrow ? null : 340,
                    ),
                  ],
                  child: controller.getAllBannersLoading.value
                      ? const ShimmerLoader.table()
                      : DataTable2(
                          isVerticalScrollBarVisible: true,
                          dataRowHeight: 60,
                          columnSpacing: 16,
                          horizontalMargin: 20,
                          minWidth: 720,
                          empty: const AppEmptyState(
                            icon: LucideIcons.searchX,
                            title: 'No matching banners',
                            message: 'Try a different name or description.',
                            compact: true,
                          ),
                          columns: const [
                            DataColumn2(
                              label: Text('Banner Name'),
                              size: ColumnSize.M,
                            ),
                            DataColumn2(
                              label: Text('Banner Description'),
                              size: ColumnSize.L,
                            ),
                            DataColumn2(
                              label: Text('Banner Image'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              label: Text('Active'),
                              fixedWidth: 140,
                            ),
                          ],
                          rows: rows),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
