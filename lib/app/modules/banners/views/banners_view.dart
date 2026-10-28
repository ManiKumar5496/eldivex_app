import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/banners/controllers/banners_controller.dart';
import 'package:eldivex_app/app/modules/banners/views/create_banners.dart';
import 'package:eldivex_app/app/modules/banners/views/view_banners.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';

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
    final hPad = SizeConfig.isMobile ? 16.0 : 24.0;

    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
              child: const AppPageHeader(
                title: 'Banners',
                subtitle: 'Create and manage promotional banners.',
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColor.borderSubtle),
                  ),
                ),
                child: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: "Create Banner", height: 44),
                    Tab(text: "Banner List", height: 44),
                  ],
                ),
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
