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
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Obx(() {
        if (controller.getAllBannersLoading.value) {
          return Center(child: HelperUi().loader());
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
        final banners = controller.allBannersData.value;
        final rows = banners.map<DataRow>((banners) {
          final userId = banners.bannerId.toString();
          return DataRow(
            cells: [
              DataCell(Text("${banners.bannerName}")),
              DataCell(Text("${banners.bannerDescription}")),
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
                            color: AppColor.cAppBackgroundColor,
                            padding: const EdgeInsets.all(16),
                            width: 500,
                            height: 400,
                            child: Column(
                              children: [
                                Image.network(
                                  banners.bannerImage!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text("Failed to load image"),
                                    );
                                  },
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
                          activeFgColor: AppColor.whiteColor,
                          inactiveBgColor: AppColor.fontColorGrey,
                          inactiveFgColor: AppColor.whiteColor,
                          initialLabelIndex:
                          banners.bannerStatus == 1 ? 0 : 1,
                          totalSwitches: 2,
                          labels: const ['Yes', 'No'],
                          radiusStyle:
                          true, // animate must be set to trut be set to true when using custom curve
                          onToggle: (index) {
                            //print('switched to: $index');
                            debugPrint(
                                "banner ID: ${banners.bannerId}, Make it Visible: $index");
                            controller.updateBannerStatus(
                              index == 0 ? 1 : 0,
                              banners.bannerId!,
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
              //DataCell(Text(user.)),
            ],
          );
        }).toList();
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
                () => controller.getAllBannersLoading.value? const ShimmerLoader.table():DataTable2(
                bottomMargin: 20,
                checkboxHorizontalMargin: 12,
                dividerThickness: 0.5,
                dataRowHeight: 80,
                fixedCornerColor: Colors.black,
                headingTextStyle: TextStyle(
                  fontFamily: "poppins_regular",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                showBottomBorder: true,
                isVerticalScrollBarVisible: true,
                headingRowColor:
                WidgetStateProperty.all<Color>(Colors.black12),
                //dataRowColor: MaterialStateProperty.all<Color>(),
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
        );
      }),
    );
  }
}
