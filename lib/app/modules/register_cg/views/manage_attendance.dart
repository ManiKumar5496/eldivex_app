import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/register_cg/controllers/register_cg_controller.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import 'attendance_list.dart';
import 'mark_attendance.dart';

class ManageAttendance extends GetView<RegisterCgController> {
  const ManageAttendance({super.key});
  @override
  Widget build(BuildContext context) {
    final data = Get.arguments ?? 0; // Default to 0 if null
    Get.put(RegisterCgController());
    SizeConfig.init(context);

    return DefaultTabController(
      initialIndex: data, // Start with the first tab
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
                labelColor: AppColor.blackColor,
                unselectedLabelColor: AppColor.blackColor,
                indicatorColor: AppColor.cPrimaryButtonColor,
                tabs: const [
                  Tab(text: "Working HP Mark Attendance List"),
                  Tab(text: "Attendance List"),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  MarkAttendanceView(),
                  AttendanceListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
