import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';
import 'package:eldivex_app/app/modules/banners/views/create_banners.dart';
import 'package:eldivex_app/app/modules/banners/views/view_banners.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';

class ManageBannersView extends GetView<BannersController> {
  const ManageBannersView({super.key});

  // Registered once on first access (shell page has no route binding).
  @override
  BannersController get controller => Get.isRegistered<BannersController>()
      ? Get.find<BannersController>()
      : Get.put(BannersController());

  @override
  Widget build(BuildContext context) {
    // Optional initial tab (0 = Create, 1 = List) passed as a route argument;
    // anything else (e.g. the shell's own arguments) falls back to 0.
    final args = ModalRoute.of(context)?.settings.arguments;
    final initialTab = (args is int && args >= 0 && args < 2) ? args : 0;
    SizeConfig.init(context); // Initialize screen size config

    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
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
                labelColor: AppColor.fontColorBlack,
                unselectedLabelColor: AppColor.fontColorGrey,
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
