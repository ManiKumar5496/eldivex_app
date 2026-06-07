import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/client_users/views/create_client_user.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/client_users_controller.dart';
import '../models/client_user_model.dart';

class ManageClientUsers extends GetView<ClientUsersController> {
  const ManageClientUsers({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    Get.put(ClientUsersController());

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: SizeConfig.spacingLG),
            _buildSearchBar(),
            SizedBox(height: SizeConfig.spacingLG),
            _buildStatsCards(),
            SizedBox(height: SizeConfig.spacingLG),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    if (SizeConfig.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Client Users',
              style: AppTextStyles.heading.copyWith(fontSize: SizeConfig.fontH1)),
          SizedBox(height: SizeConfig.spacingXS),
          Text('Manage all client users and their bookings',
              style: AppTextStyles.regular14Gre
                  .copyWith(fontSize: SizeConfig.fontCaption)),
          SizedBox(height: SizeConfig.spacingMD),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/create-client-user'),
              icon: Icon(Icons.add, size: SizeConfig.iconSM, color: AppColor.buttonTextWhite),
              label: Text('Add Client',
                  style: TextStyle(fontSize: SizeConfig.fontBodySmall)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                padding: SizeConfig.buttonPadding,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client Users',
                  style: AppTextStyles.heading
                      .copyWith(fontSize: SizeConfig.fontH1)),
              SizedBox(height: SizeConfig.spacingXS),
              Text('Manage all client users and their bookings',
                  style: AppTextStyles.regular14Gre),
            ],
          ),
        ),
        SizedBox(width: SizeConfig.spacingMD),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: SizeConfig.iconSM),
              label: const Text('Filters'),
              style: OutlinedButton.styleFrom(
                padding: SizeConfig.buttonPadding,
              ),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            ElevatedButton.icon(
              onPressed: () => Get.to(CreateClientUser()),
              icon:
              Icon(Icons.add, color: AppColor.buttonTextWhite, size: SizeConfig.iconSM),
              label: Text('Add New Client',style: TextStyle(color: AppColor.buttonTextWhite),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                padding: SizeConfig.buttonPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColor.whiteColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: SizeConfig.spacingMD,
                horizontal: SizeConfig.spacingMD,
              ),
            ),
          ),
        ),
        if (!SizeConfig.isMobile) ...[
          SizedBox(width: SizeConfig.spacingMD),
          ElevatedButton(
            onPressed: () => controller.fetchClientUsers(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cPrimaryButtonColor,
              padding: EdgeInsets.all(SizeConfig.spacingMD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
              ),
            ),
            child: Icon(Icons.search, color: AppColor.buttonTextWhite),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS CARDS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsCards() {
    return Obx(() {
      final total = controller.clientUsers.length;
      final newUsers =
          controller.clientUsers.where((u) => u.isNewUser).length;
      final active =
          controller.clientUsers.where((u) => u.isActive).length;

      if (SizeConfig.isMobile) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Total Clients', total,
                        Icons.people, AppColor.cPrimaryButtonColor)),
                SizedBox(width: SizeConfig.spacingXS),
                Expanded(
                    child: _buildStatCard('New Users', newUsers,
                        Icons.person_add, Colors.orange)),
              ],
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Active', active,
                        Icons.check_circle, AppColor.lightGreen)),
                SizedBox(width: SizeConfig.spacingXS),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        );
      }

      return Row(
        children: [
          _buildStatCard('Total Clients', total, Icons.people,
              AppColor.cPrimaryButtonColor),
          _buildStatCard(
              'New Users', newUsers, Icons.person_add, Colors.orange),
          _buildStatCard(
              'Active', active, Icons.check_circle, AppColor.lightGreen),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String title, int count, IconData icon, Color color) {
    final cardContent = Container(
      margin: EdgeInsets.only(
          right: SizeConfig.isMobile ? 0 : SizeConfig.spacingMD),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: SizeConfig.isMobile ? 16 : SizeConfig.iconMD,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon,
                color: color,
                size: SizeConfig.isMobile
                    ? SizeConfig.iconSM
                    : SizeConfig.iconMD),
          ),
          SizedBox(width: SizeConfig.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.regular14Gre.copyWith(
                        fontSize: SizeConfig.isMobile
                            ? SizeConfig.fontCaption
                            : SizeConfig.fontBody),
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: SizeConfig.spacingXS),
                Text('$count',
                    style: AppTextStyles.bold20.copyWith(
                        fontSize: SizeConfig.isMobile
                            ? SizeConfig.fontH2
                            : SizeConfig.fontH1)),
              ],
            ),
          ),
        ],
      ),
    );

    return SizeConfig.isMobile ? cardContent : Expanded(child: cardContent);
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTENT (TABLE OR CARDS)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoadingClientUsers.value) {
        return Center(child: HelperUi().loader());
      }

      if (controller.clientUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline,
                  size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingMD),
              Text('No clients found',
                  style: TextStyle(
                      fontSize: SizeConfig.fontH2,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: SizeConfig.spacingSM),
              Text('Add your first client to get started',
                  style: TextStyle(
                      fontSize: SizeConfig.fontBody, color: AppColor.fontColorGrey)),
            ],
          ),
        );
      }

      return SizeConfig.isMobile
          ? _buildMobileCardList()
          : _buildDataTableWithPagination();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileCardList() {
    return ListView.builder(
      itemCount: controller.clientUsers.length,
      itemBuilder: (context, index) =>
          _buildUserCard(controller.clientUsers[index]),
    );
  }

  Widget _buildUserCard(ClientUserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: SizeConfig.cardPadding,
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeConfig.radiusMD),
                topRight: Radius.circular(SizeConfig.radiusMD),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      AppColor.cPrimaryButtonColor.withOpacity(0.1),
                      backgroundImage: user.userImage?.isNotEmpty == true
                          ? NetworkImage(user.userImage!)
                          : null,
                      child: user.userImage?.isEmpty != false
                          ? Icon(Icons.person,
                          size: 16, color: AppColor.cPrimaryButtonColor)
                          : null,
                    ),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text('ID: ${user.id}',
                        style: AppTextStyles.regular14black.copyWith(
                            color: AppColor.cPrimaryButtonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.fontBody)),
                  ],
                ),
                _statusBadge(user.isActive),
              ],
            ),
          ),

          // Content
          Padding(
            padding: SizeConfig.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
                    SizedBox(width: SizeConfig.spacingXS),
                    Expanded(
                      child: Text(user.displayName,
                          style: AppTextStyles.regular14black.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: SizeConfig.fontBody)),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingXS),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text(user.displayPhone,
                        style: AppTextStyles.regular14Gre.copyWith(
                            fontSize: SizeConfig.fontBodySmall)),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingXS),
                Row(
                  children: [
                    Icon(Icons.email_outlined,
                        size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
                    SizedBox(width: SizeConfig.spacingXS),
                    Expanded(
                      child: Text(user.displayEmail,
                          style: AppTextStyles.regular14Gre.copyWith(
                              fontSize: SizeConfig.fontBodySmall),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingXS),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
                    SizedBox(width: SizeConfig.spacingXS),
                    Text(user.displayLocation,
                        style: AppTextStyles.regular14Gre.copyWith(
                            fontSize: SizeConfig.fontBodySmall)),
                  ],
                ),
                SizedBox(height: SizeConfig.spacingSM),
                const Divider(height: 1),
                SizedBox(height: SizeConfig.spacingSM),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            controller.viewClient(user.id ?? 0),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.spacingSM),
                          side: BorderSide(
                              color: AppColor.cPrimaryButtonColor),
                        ),
                        child: Text('View Bookings',
                            style: TextStyle(
                                color: AppColor.cPrimaryButtonColor,
                                fontSize: SizeConfig.fontBodySmall)),
                      ),
                    ),
                    SizedBox(width: SizeConfig.spacingXS),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () => controller.editClient(
                    //         user.id ?? 0, user.isNewUser),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColor.cPrimaryButtonColor,
                    //       padding: EdgeInsets.symmetric(
                    //           vertical: SizeConfig.spacingSM),
                    //     ),
                    //     child: Text('Edit',
                    //         style: TextStyle(
                    //             color: AppColor.buttonTextWhite,
                    //             fontSize: SizeConfig.fontBodySmall)),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DATA TABLE WITH PAGINATION (DESKTOP/TABLET)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDataTableWithPagination() {
    return Obx(() {
      final allUsers = controller.clientUsers;
      final rowsPerPage = controller.rowsPerPage.value;
      final currentPage = controller.currentPage.value;
      final totalPages = (allUsers.length / rowsPerPage).ceil();
      final startIndex = currentPage * rowsPerPage;
      final endIndex =
      (startIndex + rowsPerPage).clamp(0, allUsers.length);
      final pageUsers = allUsers.sublist(startIndex, endIndex);

      return Column(
        children: [
          // ── Table (no scroll) ──────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                border: Border.all(color: AppColor.divColor),
              ),
              child: DataTable2(
                columnSpacing: SizeConfig.spacingSM,
                horizontalMargin: SizeConfig.spacingMD,
                dividerThickness: 0.5,
                // Fixed row heights to prevent vertical scroll within table
                dataRowHeight:
                SizeConfig.isTablet ? 72 : SizeConfig.blockSizeVertical * 8,
                headingRowHeight:
                SizeConfig.isTablet ? 50 : SizeConfig.blockSizeVertical * 6,
                headingTextStyle: TextStyle(
                  fontFamily: "poppins_regular",
                  fontSize: SizeConfig.isTablet
                      ? SizeConfig.fontCaption
                      : SizeConfig.fontBody,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                dataTextStyle: TextStyle(
                  fontFamily: "poppins_regular",
                  fontSize: SizeConfig.isTablet
                      ? SizeConfig.fontCaption
                      : SizeConfig.fontBodySmall,
                  color: AppColor.fontColorBlack,
                ),
                headingRowColor: WidgetStateProperty.all<Color>(
                    AppColor.fieldColorGrey),
                border: TableBorder(
                  horizontalInside:
                  BorderSide(color: AppColor.divColor, width: 0.5),
                ),
                // ── No minWidth forces fit-to-screen, no horizontal scroll ──
                columns: const [
                  DataColumn2(
                      label: Text('ID'), size: ColumnSize.S, fixedWidth: 60),
                  DataColumn2(
                      label: Text('Client Info'), size: ColumnSize.L),
                  DataColumn2(
                      label: Text('Location'), size: ColumnSize.M),
                  DataColumn2(
                      label: Text('Status'), size: ColumnSize.S),
                  DataColumn2(
                      label: Text('Actions'), size: ColumnSize.S),
                ],
                rows: pageUsers.map((user) {
                  return DataRow(cells: [
                    // ── ID ──────────────────────────────────────
                    DataCell(Text(
                      '${user.id}',
                      style: AppTextStyles.regular14black.copyWith(
                          color: AppColor.cPrimaryButtonColor,
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.isTablet
                              ? SizeConfig.fontCaption
                              : SizeConfig.fontBody),
                    )),

                    // ── Client Info (name + phone + email) ──────
                    DataCell(_buildClientInfoCell(user)),

                    // ── Location ────────────────────────────────
                    DataCell(Text(
                      user.displayLocation,
                      style: AppTextStyles.regular14black.copyWith(
                          fontSize: SizeConfig.isTablet
                              ? SizeConfig.fontCaption
                              : SizeConfig.fontBody),
                    )),

                    // ── Status ──────────────────────────────────
                    DataCell(_statusBadge(user.isActive)),

                    // ── Actions ─────────────────────────────────
                    DataCell(_buildCompactActions(user)),
                  ]);
                }).toList(),
              ),
            ),
          ),

          // ── Pagination Bar ────────────────────────────────────
          _buildPaginationBar(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: allUsers.length,
            rowsPerPage: rowsPerPage,
            startIndex: startIndex,
            endIndex: endIndex,
          ),
        ],
      );
    });
  }

  /// Combined name + phone + email in one cell
  Widget _buildClientInfoCell(ClientUserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColor.cPrimaryButtonColor.withOpacity(0.1),
          backgroundImage: user.userImage?.isNotEmpty == true
              ? NetworkImage(user.userImage!)
              : null,
          child: user.userImage?.isEmpty != false
              ? Icon(Icons.person,
              size: 16, color: AppColor.cPrimaryButtonColor)
              : null,
        ),
        SizedBox(width: SizeConfig.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName,
                style: AppTextStyles.regular14black.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.isTablet
                        ? SizeConfig.fontCaption
                        : SizeConfig.fontBody),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 11, color: AppColor.fontColorGrey),
                  const SizedBox(width: 3),
                  Text(
                    user.displayPhone,
                    style: AppTextStyles.regular14Gre.copyWith(
                        fontSize: SizeConfig.fontCaption),
                  ),
                ],
              ),
              SizedBox(height: 1),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 11, color: AppColor.fontColorGrey),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      user.displayEmail,
                      style: AppTextStyles.regular14Gre.copyWith(
                          fontSize: SizeConfig.fontCaption),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Stacked View / Edit buttons to save horizontal space
  Widget _buildCompactActions(ClientUserModel user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          child: OutlinedButton(
            onPressed: () => controller.viewClient(user.id ?? 0),
            style: OutlinedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              side: BorderSide(color: AppColor.cPrimaryButtonColor),
              minimumSize: const Size(64, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('View',
                style: TextStyle(
                    color: AppColor.cPrimaryButtonColor,
                    fontSize: SizeConfig.fontCaption)),
          ),
        ),
        const SizedBox(height: 4),
        // SizedBox(
        //   height: 28,
        //   child: ElevatedButton(
        //     onPressed: () =>
        //         controller.editClient(user.id ?? 0, user.isNewUser),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColor.cPrimaryButtonColor,
        //       padding:
        //       const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        //       minimumSize: const Size(64, 28),
        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     ),
        //     child: Text('Edit',
        //         style: TextStyle(
        //             color: AppColor.buttonTextWhite,
        //             fontSize: SizeConfig.fontCaption)),
        //   ),
        //),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PAGINATION BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPaginationBar({
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int rowsPerPage,
    required int startIndex,
    required int endIndex,
  }) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.spacingSM),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Row(
        children: [
          // ── Rows per page ──────────────────────────────────────
          Text('Rows per page:',
              style: AppTextStyles.regular14Gre
                  .copyWith(fontSize: SizeConfig.fontCaption)),
          SizedBox(width: SizeConfig.spacingXS),
          AppDropdown<int>(
            hint: '',
            value: rowsPerPage,
            isDense: true,
            isExpanded: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            items: [10, 20, 50]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                controller.rowsPerPage.value = v;
                controller.currentPage.value = 0;
              }
            },
          ),

          SizedBox(width: SizeConfig.spacingMD),

          // ── Range label ────────────────────────────────────────
          Text(
            '${startIndex + 1}–$endIndex of $totalItems',
            style: AppTextStyles.regular14Gre
                .copyWith(fontSize: SizeConfig.fontCaption),
          ),

          const Spacer(),

          // ── Page buttons ───────────────────────────────────────
          _pageButton(
            icon: Icons.first_page,
            enabled: currentPage > 0,
            onTap: () => controller.currentPage.value = 0,
          ),
          _pageButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onTap: () => controller.currentPage.value = currentPage - 1,
          ),

          // Page number chips
          ...List.generate(totalPages, (i) => i)
              .where((i) =>
          i == 0 ||
              i == totalPages - 1 ||
              (i - currentPage).abs() <= 1)
              .fold<List<Widget>>([], (acc, i) {
            if (acc.isNotEmpty) {
              final prevPage = int.tryParse(
                  (acc.last as _PageChip?)?.pageNumber?.toString() ??
                      '') ??
                  -99;
              // insert ellipsis if gap
            }
            acc.add(_PageChip(
              pageNumber: i,
              isSelected: i == currentPage,
              onTap: () => controller.currentPage.value = i,
            ));
            return acc;
          }),

          _pageButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages - 1,
            onTap: () => controller.currentPage.value = currentPage + 1,
          ),
          _pageButton(
            icon: Icons.last_page,
            enabled: currentPage < totalPages - 1,
            onTap: () =>
            controller.currentPage.value = totalPages - 1,
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon,
          size: SizeConfig.iconSM,
          color: enabled ? AppColor.fontColorBlack : AppColor.divColor),
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingSM,
        vertical: SizeConfig.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColor.lightGreen.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: SizeConfig.iconSM,
            color: isActive ? AppColor.lightGreen : Colors.red,
          ),
          SizedBox(width: SizeConfig.spacingXS),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColor.lightGreen : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.fontCaption,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HELPER WIDGET — Page number chip
// ═══════════════════════════════════════════════════════════════

class _PageChip extends StatelessWidget {
  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageChip({
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.cPrimaryButtonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColor.cPrimaryButtonColor
                : AppColor.divColor,
          ),
        ),
        child: Text(
          '${pageNumber + 1}',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'poppins_regular',
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColor.buttonTextWhite : AppColor.fontColorBlack,
          ),
        ),
      ),
    );
  }
}