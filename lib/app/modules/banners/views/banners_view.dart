import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';
import 'package:eldivex_app/app/modules/banners/views/create_banners.dart';
import 'package:eldivex_app/app/modules/banners/views/view_banners.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';

class ManageBannersView extends GetView<BannersController> {
  const ManageBannersView({super.key});
  @override
  @override
  Widget build(BuildContext context) {
    final data = Get.arguments ?? 0; // Default to 0 if null
    final bannersController = Get.put(BannersController());
    SizeConfig.init(context); // Initialize screen size config

    return DefaultTabController(
      initialIndex: data, // Start with the first tab
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back, color: AppColor.blackColor),
        //     onPressed: () {
        //       userController.clearFilters();
        //       Get.back();
        //     },
        //   ),
        //   title: const Text(
        //     'User Management',
        //     style: TextStyle(
        //       color: AppColor.blackColor,
        //       fontFamily: "poppins_regular",
        //     ),
        //   ),
        //   backgroundColor: AppColor.cAppBackgroundColor, // AppBar color
        //   systemOverlayStyle: SystemUiOverlayStyle.light,
        //
        // ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: AppColor.whiteColor, // TabBar background color
              child: TabBar(
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: "poppins_regular",
                ),
                labelColor: AppColor.blackColor,
                unselectedLabelColor: AppColor.blackColor,
                indicatorColor: AppColor.cPrimaryButtonColor,
                tabs: const [
                  Tab(text: "Create Banner"),
                  Tab(text: "Banner List"),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  CreateBanners(),
                  ViewBanners(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
