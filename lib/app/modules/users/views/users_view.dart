import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/users_controller.dart';
import '../models/get_users_model.dart';
import '../../../routes/app_pages.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  // The shell normally registers UsersController up-front; fall back to a
  // lazy registration (once, not on every build) when opened directly.
  @override
  UsersController get controller => Get.isRegistered<UsersController>()
      ? Get.find<UsersController>()
      : Get.put(UsersController());

  /// Below this width the table scrolls horizontally instead of squashing.
  static const double _tableMinWidth = 880;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: SizeConfig.isMobile ? 16 : 24),
            Obx(() {
              if (controller.getAllUsersLoading.value) {
                return const AppCard(
                  padding: EdgeInsets.zero,
                  child: ShimmerLoader.table(),
                );
              }
              if (controller.loadError.value.isNotEmpty &&
                  controller.allUsers.value.isEmpty) {
                return _buildErrorState();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStats(),
                  SizedBox(height: SizeConfig.isMobile ? 16 : 20),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchBar(),
                        Obx(() => controller.isFilterVisible.value
                            ? _buildFiltersCard()
                            : const SizedBox.shrink()),
                        Divider(height: 1, color: AppColor.borderSubtle),
                        _buildUsersTable(),
                        Divider(height: 1, color: AppColor.borderSubtle),
                        _buildTableFooter(),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Employees',
      subtitle: 'View and manage all user accounts',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            controller.clearFilters();
            Get.toNamed(Routes.AddUser);
          },
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add User'),
        ),
      ],
    );
  }

  /// Head-count tiles. Called inside the page `Obx` (reads `allUsers`).
  Widget _buildStats() {
    final users = controller.allUsers.value;
    final active = users.where((u) => u.isActive).length;
    return AppResponsiveGrid(
      minItemWidth: SizeConfig.isMobile ? 140 : 200,
      maxColumns: 3,
      spacing: SizeConfig.isMobile ? 12 : 16,
      children: [
        AppStatCard(
          label: 'Total Employees',
          value: '${users.length}',
          icon: LucideIcons.idCard,
          tone: AppTone.primary,
        ),
        AppStatCard(
          label: 'Active',
          value: '$active',
          icon: LucideIcons.circleCheck,
          tone: AppTone.success,
        ),
        AppStatCard(
          label: 'Terminated',
          value: '${users.length - active}',
          icon: LucideIcons.ban,
          tone: AppTone.danger,
        ),
      ],
    );
  }

  Widget _filtersButton({bool expand = false}) {
    return Obx(() {
      final visible = controller.isFilterVisible.value;
      final button = OutlinedButton.icon(
        onPressed: () {
          controller.toggleFilters();
        },
        icon: Icon(
          visible ? LucideIcons.chevronUp : LucideIcons.listFilter,
          size: 18,
        ),
        label: const Text('Filters'),
        style: visible
            ? OutlinedButton.styleFrom(
                foregroundColor: AppColor.cAppPrimaryColor,
                backgroundColor: AppColor.primarySoft,
                side: BorderSide(
                    color: AppColor.cAppPrimaryColor.withValues(alpha: 0.4)),
              )
            : null,
      );
      return expand ? SizedBox(width: double.infinity, child: button) : button;
    });
  }

  Widget _exportButton({bool expand = false}) {
    final button = OutlinedButton.icon(
      onPressed: controller.exportUsersCsv,
      icon: const Icon(LucideIcons.download, size: 18),
      label: const Text('Export'),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildSearchBar() {
    final search = AppSearchField(
      controller: controller.searchController,
      onChanged: controller.searchUsers,
      hint: 'Search users by name, email...',
    );
    if (SizeConfig.isMobile) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            search,
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _filtersButton(expand: true)),
                const SizedBox(width: 8),
                Expanded(child: _exportButton(expand: true)),
              ],
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: search,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _filtersButton(),
          const SizedBox(width: 8),
          _exportButton(),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(top: BorderSide(color: AppColor.borderSubtle)),
      ),
      padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Search User Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hide filters',
                onPressed: () {
                  controller.toggleFilters();
                },
                icon: Icon(
                  LucideIcons.x,
                  size: 18,
                  color: AppColor.textTertiary,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _responsiveFilterRow([
            CommonTextField(
              label: 'Name',
              hint: 'Enter name',
              controller: controller.filterNameController,
              onChanged: (_) => controller.applyUserFilters(),
            ),
            CommonTextField(
              label: 'Phone Number',
              hint: 'e.g. 9876543210',
              controller: controller.filterPhoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => controller.applyUserFilters(),
            ),
            Obx(() {
              final branches = controller.dashboardController.getAllBranches
                  .map((e) => e.brName)
                  .where((n) => n.isNotEmpty)
                  .toSet()
                  .toList();
              final current = controller.filterBranch.value;
              return CommonDropdown(
                label: 'Branch',
                hint: 'Select branch',
                value: branches.contains(current) ? current : null,
                items: branches,
                onChanged: (value) {
                  controller.filterBranch.value = value ?? '';
                  controller.applyUserFilters();
                },
              );
            }),
            Obx(() {
              final roles = controller.dashboardController.getMasterRolesData
                  .map((e) => e.roleName)
                  .where((n) => n.isNotEmpty)
                  .toSet()
                  .toList();
              final current = controller.filterRole.value;
              return CommonDropdown(
                label: 'User Role',
                hint: 'Select role',
                value: roles.contains(current) ? current : null,
                items: roles,
                onChanged: (value) {
                  controller.filterRole.value = value ?? '';
                  controller.applyUserFilters();
                },
              );
            }),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.clearUserListFilters();
                },
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  controller.applyUserFilters();
                },
                child: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4 filters per row on wide screens, 2 on tablets, 1 on phones.
  Widget _responsiveFilterRow(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 16.0;
      final w = constraints.maxWidth;
      final cols = w >= 960 ? 4 : (w >= 520 ? 2 : 1);
      final itemWidth = ((w - gap * (cols - 1)) / cols).floorToDouble();
      return Wrap(
        spacing: gap,
        runSpacing: 12,
        children: [
          for (final child in children) SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }

  Widget _buildUsersTable() {
    return LayoutBuilder(builder: (context, constraints) {
      final table = Column(
        children: [
          _buildTableHeader(),
          Obx(() => _buildTableBody()),
        ],
      );
      if (constraints.maxWidth >= _tableMinWidth) return table;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _tableMinWidth, child: table),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('User', flex: 3),
          _buildHeaderCell('Email', flex: 3),
          _buildHeaderCell('Role', flex: 2),
          _buildHeaderCell('Status', flex: 2),
          _buildHeaderCell('Join Date', flex: 2),
          _buildHeaderCell('Actions', flex: 1, alignEnd: true),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColor.textTertiary,
        ),
      ),
    );
  }

  Widget _buildTableBody() {
    // Touch currentPage so the Obx rebuilds on page changes.
    controller.currentPage.value;
    final rows = controller.pagedUsers;
    if (rows.isEmpty) {
      final none = controller.allUsers.value.isEmpty;
      return AppEmptyState(
        compact: true,
        icon: none ? LucideIcons.idCard : LucideIcons.searchX,
        title: none
            ? 'No employees found'
            : 'No employees match the current filters',
      );
    }
    return Column(children: rows.map(_buildTableRow).toList());
  }

  Widget _buildErrorState() {
    return AppCard(
      child: AppEmptyState(
        icon: LucideIcons.circleAlert,
        tone: AppTone.danger,
        title: 'Could not load employees',
        message: controller.loadError.value,
        actionLabel: 'Retry',
        actionIcon: LucideIcons.refreshCw,
        onAction: controller.getAllEmployeesFromApi,
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppStatusBadge(
        label: active ? 'Active' : 'Terminated',
        tone: active ? AppTone.success : AppTone.danger,
      ),
    );
  }

  Widget _buildTableRow(GetEmployeeDetails user) {
    final cellStyle = TextStyle(fontSize: 13.5, color: AppColor.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                AppAvatar(
                  name: user.userName.isEmpty ? 'U' : user.userName,
                  imageUrl: user.userImage,
                  size: 34,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.userName.isEmpty ? 'Unknown' : user.userName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
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
              user.userEmail,
              style: cellStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              // Long role names shrink instead of overflowing the column.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _buildRoleBadge(user.roleName),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(user.isActive),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdOn),
              style: cellStyle.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit user',
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 18,
                    color: AppColor.textSecondary,
                  ),
                  onPressed: () {
                    controller.loadUserForEdit(user);
                    Get.toNamed(Routes.AddUser);
                  },
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: user.isActive ? 'Terminate user' : 'Already terminated',
                  icon: Icon(
                    LucideIcons.ban,
                    size: 18,
                    color: user.isActive
                        ? AppColor.warning
                        : AppColor.borderStrong,
                  ),
                  onPressed: !user.isActive
                      ? null
                      : () {
                    Get.dialog(
                      AppDialog(
                        title: 'Terminate User',
                        icon: LucideIcons.ban,
                        tone: AppTone.danger,
                        maxWidth: 440,
                        // Same guard as Cancel: no closing mid-request.
                        onClose: () {
                          if (!controller.isTerminateLoading.value) Get.back();
                        },
                        actions: [
                          Obx(() => OutlinedButton(
                                onPressed: controller.isTerminateLoading.value
                                    ? null
                                    : () => Get.back(),
                                child: const Text('Cancel'),
                              )),
                          Obx(() => ElevatedButton(
                            onPressed: controller.isTerminateLoading.value
                                ? null
                                : () async {
                                    final ok = await controller.terminateUser(user.id);
                                    if (ok && (Get.isDialogOpen ?? false)) Get.back();
                                  },
                            style: AppButtonStyles.danger,
                            child: controller.isTerminateLoading.value
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.textTertiary),
                                    ),
                                  )
                                : const Text('Terminate'),
                          )),
                        ],
                        child: Text(
                          'Are you sure you want to terminate ${user.userName}? This will deactivate their account.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ),
                      barrierDismissible: false,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final AppTone tone;
    switch (role.toLowerCase()) {
      case 'admin':
        tone = AppTone.violet;
        break;
      case 'manager':
        tone = AppTone.info;
        break;
      default:
        tone = AppTone.neutral;
    }
    return AppStatusBadge(
      label: role.isEmpty ? '—' : role,
      tone: tone,
      showDot: false,
    );
  }

  /// Result count on the left, pager on the right.
  Widget _buildTableFooter() {
    final caption = TextStyle(fontSize: 13, color: AppColor.textTertiary);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.isMobile ? 12 : 16,
        vertical: 10,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Obx(() => Text(
                'Showing ${controller.filteredUsers.length} of ${controller.allUsers.value.length} users',
                style: caption,
              )),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      final page = controller.currentPage.value;
      final total = controller.totalPages;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Page $page of $total',
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: page > 1 ? controller.previousPage : null,
            style: AppButtonStyles.compact,
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
            label: const Text('Previous'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: page < total ? controller.nextPage : null,
            style: AppButtonStyles.compact,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Next'),
                SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, size: 18),
              ],
            ),
          ),
        ],
      );
    });
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

}
