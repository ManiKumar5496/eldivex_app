import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/register_cg/controllers/register_cg_controller.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
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
    final pad = SizeConfig.pagePadding;

    return DefaultTabController(
      initialIndex: data, // Start with the first tab
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: Padding(
          // Bottom padding is applied by each tab so lists can run to the edge.
          padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Attendance',
                subtitle:
                    'Mark daily attendance and review attendance history for health professionals',
              ),
              SizedBox(height: 16),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: "Working HP Mark Attendance List"),
                  Tab(text: "Attendance List"),
                ],
              ),
              Expanded(
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
      ),
    );
  }
}
