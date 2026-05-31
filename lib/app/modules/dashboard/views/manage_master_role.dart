import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/dashboard/controllers/dashboard_controller.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../models/get_master_roles.dart';

class ManageMasterRoles extends GetView<DashboardController> {
  const ManageMasterRoles({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(DashboardController());
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.getMasterRolesLoading.value) {
                return Center(child: SizedBox(child: HelperUi().loader()));
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
                  child: Column(
                    children: [
                      _buildRolesTable(),
                      SizedBox(height: SizeConfig.isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                      _buildPagination(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
        vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage Roles', style: AppTextStyles.heading),
                SizedBox(height: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.5),
                Text(
                  'View and manage all roles',
                  style: AppTextStyles.regular14Gre,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(Routes.AddMasterRoles);
            },
            icon: Icon(
              Icons.add,
              size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2,
              color: AppColor.whiteColor,
            ),
            label: Text(
              'Add Role',
              style: TextStyle(
                fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1,
                color: AppColor.whiteColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
                vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTable() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: isMobile ? 44 : SizeConfig.blockSizeVertical * 6,
                dataRowMinHeight: isMobile ? 44 : SizeConfig.blockSizeVertical * 6,
                dataRowMaxHeight: isMobile ? 52 : SizeConfig.blockSizeVertical * 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columnSpacing: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 3,
                horizontalMargin: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2,
                columns: [
                  DataColumn(
                    label: Row(
                      children: [
                        Text(
                          'Role ID',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Role Name',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Access List',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                rows: controller.getMasterRolesData.map((role) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.4,
                              backgroundColor: _getAvatarColor(
                                role.roleName ?? '',
                              ),
                              child: Text(
                                _getInitials(role.id.toString()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                            Text(
                              role.id.toString(),
                              style: TextStyle(
                                fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          role.roleName ?? 'N/A',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? 200 : SizeConfig.blockSizeHorizontal * 30,
                          ),
                          child: Text(
                            role.modules ?? 'No access list',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.4,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                // Handle edit action
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(
                              width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.4,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () {
                                // Handle delete action
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildTableFooter() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Obx(
        () => Text(
          'Showing ${controller.getMasterRolesData.length} roles',
          style: TextStyle(
            fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final isMobile = SizeConfig.isMobile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade300),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
              vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Previous',
            style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2),
          ),
        ),
        SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cPrimaryButtonColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
              vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Text(
            'Next',
            style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.teal.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
    ];
    return colors[name.length % colors.length];
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 1:
        return 'Active';
      case 0:
        return 'Inactive';
      case 2:
        return 'Pending';
      case 3:
        return 'Suspended';
      default:
        return 'Inactive';
    }
  }
}
