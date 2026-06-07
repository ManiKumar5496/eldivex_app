import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/date_picker_common.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/users_controller.dart';
import '../../../routes/app_pages.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(UsersController());
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.getAllUsersLoading.value) {
                return const ShimmerLoader.table();
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      SizedBox(height: SizeConfig.isMobile ? 12 : SizeConfig.blockSizeVertical * 2),
                      Obx(() => controller.isFilterVisible.value
                          ? Column(
                        children: [
                          _buildFiltersCard(),
                          SizedBox(height: SizeConfig.isMobile ? 12 : SizeConfig.blockSizeVertical * 2),
                        ],
                      )
                          : const SizedBox.shrink()),
                      _buildUsersTable(),
                      SizedBox(height: SizeConfig.isMobile ? 12 : SizeConfig.blockSizeVertical * 2),
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
      color: AppColor.whiteColor,
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
                Text('Manage Users', style: AppTextStyles.heading),
                SizedBox(height: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.5),
                Text('View and manage all user accounts', style: AppTextStyles.regular14Gre),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearFilters();
              Get.toNamed(Routes.AddUser);
            },
            icon: Icon(Icons.add, size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2, color: AppColor.buttonTextWhite),
            label: Text(
              'Add User',
              style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1, color: AppColor.buttonTextWhite),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              foregroundColor: AppColor.buttonTextWhite,
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

  Widget _buildSearchBar() {
    final isMobile = SizeConfig.isMobile;
    if (isMobile) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.divColor),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name, email...',
                hintStyle: TextStyle(
                  color: AppColor.lightGrey,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.lightGrey,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() => OutlinedButton.icon(
                  onPressed: () {
                    controller.toggleFilters();
                  },
                  icon: Icon(
                    controller.isFilterVisible.value ? Icons.expand_less : Icons.filter_list,
                    size: 16,
                  ),
                  label: const Text(
                    'Filters',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: controller.isFilterVisible.value ? Colors.blue.shade700 : AppColor.fontColorGrey,
                    side: BorderSide(
                      color: controller.isFilterVisible.value ? Colors.blue.shade300 : AppColor.divColor,
                    ),
                    backgroundColor: controller.isFilterVisible.value ? Colors.blue.shade50 : AppColor.whiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text(
                    'Export',
                    style: TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.fontColorGrey,
                    side: BorderSide(color: AppColor.divColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.divColor),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name, email...',
                hintStyle: TextStyle(
                  color: AppColor.lightGrey,
                  fontSize: SizeConfig.blockSizeHorizontal * 1.2,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.lightGrey,
                  size: SizeConfig.blockSizeHorizontal * 1.8,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                  vertical: SizeConfig.blockSizeVertical * 1.2,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
        Obx(() => OutlinedButton.icon(
          onPressed: () {
            controller.toggleFilters();
          },
          icon: Icon(
            controller.isFilterVisible.value ? Icons.expand_less : Icons.filter_list,
            size: SizeConfig.blockSizeHorizontal * 1.5,
          ),
          label: Text(
            'Filters',
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.2),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: controller.isFilterVisible.value ? Colors.blue.shade700 : AppColor.fontColorGrey,
            side: BorderSide(
              color: controller.isFilterVisible.value ? Colors.blue.shade300 : AppColor.divColor,
            ),
            backgroundColor: controller.isFilterVisible.value ? Colors.blue.shade50 : AppColor.whiteColor,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 1.5,
              vertical: SizeConfig.blockSizeVertical * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 1),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.download,
            size: SizeConfig.blockSizeHorizontal * 1.5,
          ),
          label: Text(
            'Export',
            style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 1.2),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.fontColorGrey,
            side: BorderSide(color: AppColor.divColor),
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 1.5,
              vertical: SizeConfig.blockSizeVertical * 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersCard() {
    final isMobile = SizeConfig.isMobile;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search User Filters',
                style: TextStyle(
                  fontSize: isMobile ? 15 : SizeConfig.blockSizeHorizontal * 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColor.fontColorBlack,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.toggleFilters();
                },
                icon: Icon(
                  Icons.close,
                  size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.8,
                  color: AppColor.fontColorGrey,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFilterRow([
            CommonTextField(
              label: 'User ID',
              hint: 'Enter user ID',
              controller: controller.firstNameController,
            ),
            CommonTextField(
              label: 'Name',
              hint: 'Enter name',
              controller: controller.lastNameController,
            ),
            CommonTextField(
              label: 'Phone Number',
              hint: 'Enter phone number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            Obx(
              () => CommonDropdown(
                label: 'Branch',
                hint: 'Select City',
                value: controller.selectedCity.value.isEmpty
                    ? null
                    : controller.selectedCity.value,
                items: controller.dashboardController.getAllBranches
                    .map((e) => e.brName)
                    .toList(),
                onChanged: (value) {
                  controller.selectedCity.value = value!;
                },
              ),
            ),
          ]),
          SizedBox(height: isMobile ? 8 : SizeConfig.blockSizeVertical * 1.2),
          _responsiveFilterRow([
            Obx(() => CommonDropdown(
              label: 'Lead Type',
              hint: 'Select lead type',
              value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
              items: controller.statuses,
              onChanged: (value) {
                if (value != null) {
                  controller.selectedStatus.value = value;
                }
              },
            )),
            Obx(() => CommonDropdown(
              label: 'Enquired For(Product)',
              hint: 'Select product',
              value: controller.selectedState.value.isEmpty ? null : controller.selectedState.value,
              items: controller.states,
              onChanged: (value) {
                if (value != null) {
                  controller.selectedState.value = value;
                }
              },
            )),
            Obx(() => CommonDropdown(
              label: 'Lead created through',
              hint: 'Select user type',
              value: controller.selectedCountry.value.isEmpty ? null : controller.selectedCountry.value,
              items: controller.countries,
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCountry.value = value;
                }
              },
            )),
          ]),
          SizedBox(height: isMobile ? 8 : SizeConfig.blockSizeVertical * 1.2),
          _responsiveFilterRow([
            Obx(() {
              final roles = controller
                  .dashboardController
                  .getMasterRolesData
                  .value;

              return CommonDropdown(
                label: 'User Role',
                hint: 'Select Role',
                value: controller.selectedRole.value.isEmpty
                    ? null
                    : controller.selectedRole.value,
                items: roles.map((e) => e.roleName ?? "").toList(),
                onChanged: (value) {
                  controller.selectedRole.value = value!;
                },
              );
            }),
            Obx(() => CommonDropdown(
              label: 'Lead(Booking) Status',
              hint: 'Select booking status',
              value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
              items: controller.statuses,
              onChanged: (value) {
                if (value != null) {
                  controller.selectedStatus.value = value;
                }
              },
            )),
            CommonDatePicker(
              label: 'User Created from',
              hint: 'dd/mm/yyyy',
              selectedDate: null,
              onDateSelected: (date) {},
            ),
            CommonDatePicker(
              label: 'User Created to',
              hint: 'dd/mm/yyyy',
              selectedDate: null,
              onDateSelected: (date) {},
            ),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.clearFilters();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.fontColorGrey,
                  side: BorderSide(color: AppColor.divColor),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
                    vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2),
                ),
              ),
              SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
              ElevatedButton(
                onPressed: () {
                  controller.getAllEmployeesFromApi();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cPrimaryButtonColor,
                  foregroundColor: AppColor.buttonTextWhite,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2.5,
                    vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _responsiveFilterRow(List<Widget> children) {
    final isMobile = SizeConfig.isMobile;
    if (isMobile) {
      return Column(
        children: children.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: child,
          );
        }).toList(),
      );
    }
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : SizeConfig.blockSizeHorizontal * 0.6,
              right: index == children.length - 1 ? 0 : SizeConfig.blockSizeHorizontal * 0.6,
            ),
            child: child,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizeConfig.isMobile
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 600,
                child: Column(
                  children: [
                    _buildTableHeader(),
                    Obx(() => Column(
                      children: controller.allUsers.value.map((user) {
                        return _buildTableRow(user);
                      }).toList(),
                    )),
                    _buildTableFooter(),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                _buildTableHeader(),
                Obx(() => Column(
                  children: controller.allUsers.value.map((user) {
                    return _buildTableRow(user);
                  }).toList(),
                )),
                _buildTableFooter(),
              ],
            ),
    );
  }

  Widget _buildTableHeader() {
    final isMobile = SizeConfig.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        color: AppColor.fieldColorGrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('User', flex: 3),
          _buildHeaderCell('Email', flex: 3),
          _buildHeaderCell('Role', flex: 2),
          _buildHeaderCell('Join Date', flex: 2),
          _buildHeaderCell('Actions', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    final isMobile = SizeConfig.isMobile;
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
          fontWeight: FontWeight.w600,
          color: AppColor.fontColorGrey,
        ),
      ),
    );
  }

  Widget _buildTableRow(dynamic user) {
    final isMobile = SizeConfig.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.4,
                  backgroundColor: _getAvatarColor(user.userName ?? ''),
                  backgroundImage: (user.userImage != null && user.userImage.isNotEmpty)
                      ? NetworkImage(user.userImage)
                      : null,
                  child: (user.userImage == null || user.userImage.isEmpty)
                      ? Text(
                          _getInitials(user.userName ?? 'U'),
                          style: TextStyle(
                            color: AppColor.buttonTextWhite,
                            fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                Expanded(
                  child: Text(
                    user.userName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                      fontWeight: FontWeight.w500,
                      color: AppColor.fontColorBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              user.userEmail ?? '',
              style: TextStyle(
                fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorGrey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildRoleBadge(user.roleName ?? ''),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdOn ?? ''),
              style: TextStyle(
                fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
                color: AppColor.fontColorGrey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.4,
                    color: AppColor.fontColorGrey,
                  ),
                  onPressed: () {
                    controller.loadUserForEdit(user);
                    Get.toNamed(Routes.AddUser);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 0.8),
                IconButton(
                  icon: Icon(
                    Icons.block,
                    size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.4,
                    color: Colors.orange.shade600,
                  ),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Terminate User'),
                        content: Text(
                          'Are you sure you want to terminate ${user.userName}? This will deactivate their account.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          Obx(() => ElevatedButton(
                            onPressed: controller.isTerminateLoading.value
                                ? null
                                : () {
                                    controller.terminateUser(user.id);
                                    Get.back();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: AppColor.buttonTextWhite,
                            ),
                            child: controller.isTerminateLoading.value
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.buttonTextWhite),
                                    ),
                                  )
                                : const Text('Terminate'),
                          )),
                        ],
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isMobile = SizeConfig.isMobile;
    Color bgColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'admin':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case 'manager':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      default:
        bgColor = AppColor.fieldColorGrey;
        textColor = AppColor.fontColorGrey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1,
        vertical: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        textAlign: TextAlign.center,
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
      child: Obx(() => Text(
        'Showing ${controller.allUsers.value.length} users',
        style: TextStyle(
          fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.1,
          color: AppColor.fontColorGrey,
        ),
      )),
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
            foregroundColor: AppColor.fontColorGrey,
            side: BorderSide(color: AppColor.divColor),
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
            foregroundColor: AppColor.buttonTextWhite,
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

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
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

}