import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/modules/client_users/views/create_client_user.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/helper_ui.dart';
import '../controllers/client_users_controller.dart';
import '../models/client_user_model.dart';
import '../../client_portal/views/client_portal_link_card.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ManageClientUsers extends GetView<ClientUsersController> {
  const ManageClientUsers({super.key, this.onBack});

  /// Set when the page is opened as a stand-alone route (see
  /// [ClientUsersView]); shows a back button in the page header.
  final VoidCallback? onBack;

  // Registered once on first access (shell page has no route binding).
  @override
  ClientUsersController get controller =>
      Get.isRegistered<ClientUsersController>()
          ? Get.find<ClientUsersController>()
          : Get.put(ClientUsersController());

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SizeConfig.isMobile ? _buildMobileBody() : _buildWideBody(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LAYOUTS
  // ═══════════════════════════════════════════════════════════════

  /// Tablet / desktop: the table card fills the remaining height. On short
  /// viewports the page scrolls instead and the table gets a fixed height.
  Widget _buildWideBody() {
    return LayoutBuilder(builder: (context, constraints) {
      final top = <Widget>[
        _buildHeader(),
        const SizedBox(height: 20),
        const ClientPortalLinkCard(),
        const SizedBox(height: 16),
        _buildStatsCards(),
        const SizedBox(height: 16),
      ];
      final tableCard = AppCard(
        padding: EdgeInsets.zero,
        expandChild: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(),
            _buildFilterPanelSlot(),
            Divider(height: 1, color: AppColor.borderSubtle),
            Expanded(child: _buildContent()),
          ],
        ),
      );

      if (constraints.maxHeight >= 760) {
        return Padding(
          padding: SizeConfig.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...top, Expanded(child: tableCard)],
          ),
        );
      }
      return SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [...top, SizedBox(height: 600, child: tableCard)],
        ),
      );
    });
  }

  /// Phones: one scroll view; client cards are a lazy sliver list.
  Widget _buildMobileBody() {
    final pad = SizeConfig.pagePadding;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: pad.copyWith(bottom: 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 16),
              const ClientPortalLinkCard(),
              const SizedBox(height: 16),
              _buildStatsCards(),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildToolbar(),
                    _buildFilterPanelSlot(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverPadding(
          padding: pad.copyWith(top: 0),
          sliver: _buildMobileCardList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Client Users',
      subtitle: 'Manage all client users and their bookings',
      onBack: onBack,
      breadcrumbs:
          onBack != null ? const ['Dashboard', 'Client Users'] : const [],
      actions: [
        ElevatedButton.icon(
          onPressed: _openCreateClient,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Client'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOOLBAR (search, filters, refresh)
  // ═══════════════════════════════════════════════════════════════

  void _openCreateClient() {
    Get.to(() => const CreateClientUser(showBackButton: true));
  }

  Widget _filtersButton() {
    return Obx(() {
      final active = controller.filterLeadType.value.isNotEmpty ||
          controller.filterLeadSource.value.isNotEmpty;
      return OutlinedButton.icon(
        onPressed: controller.toggleFilters,
        icon: Icon(
          controller.showFilters.value
              ? LucideIcons.chevronUp
              : LucideIcons.listFilter,
          size: 18,
        ),
        label: Text(active ? 'Filters •' : 'Filters'),
      );
    });
  }

  Widget _buildToolbar() {
    final search = AppSearchField(
      controller: controller.searchController,
      onChanged: controller.onSearchChanged,
      hint: 'Search by name, phone, email or ID...',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.fetchClientUsers,
            icon: Icon(LucideIcons.refreshCw,
                size: 20, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanelSlot() {
    return Obx(() => controller.showFilters.value
        ? _buildFilterPanel()
        : const SizedBox.shrink());
  }

  Widget _buildFilterPanel() {
    final children = <Widget>[
      Obx(() => CommonDropdown(
            label: 'Lead Type',
            hint: 'All lead types',
            value: controller.filterLeadType.value.isEmpty
                ? null
                : controller.filterLeadType.value,
            items: controller.leadTypeList,
            onChanged: (v) {
              controller.filterLeadType.value = v ?? '';
              controller.applyClientFilters();
            },
          )),
      Obx(() => CommonDropdown(
            label: 'Lead Source',
            hint: 'All sources',
            value: controller.filterLeadSource.value.isEmpty
                ? null
                : controller.filterLeadSource.value,
            items: controller.leadSourceList,
            onChanged: (v) {
              controller.filterLeadSource.value = v ?? '';
              controller.applyClientFilters();
            },
          )),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColor.surfaceMuted,
        border: Border(top: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (SizeConfig.isMobile)
            ...children.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 16),
                Expanded(child: children[1]),
              ],
            ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: controller.clearFilters,
            icon: const Icon(LucideIcons.x, size: 18),
            label: const Text('Clear filters'),
          ),
        ],
      ),
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

      return AppResponsiveGrid(
        minItemWidth: SizeConfig.isMobile ? 140 : 200,
        maxColumns: 3,
        spacing: SizeConfig.isMobile ? 12 : 16,
        children: [
          AppStatCard(
            label: 'Total Clients',
            value: '$total',
            icon: LucideIcons.users,
            tone: AppTone.primary,
          ),
          AppStatCard(
            label: 'New Users',
            value: '$newUsers',
            icon: LucideIcons.userPlus,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Active',
            value: '$active',
            icon: LucideIcons.circleCheck,
            tone: AppTone.success,
          ),
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTENT (TABLE OR CARDS)
  // ═══════════════════════════════════════════════════════════════

  /// Loading / error / empty / no-results view, or null when there are rows
  /// to show. Must be called inside an `Obx` (reads observables).
  Widget? _buildStateView() {
    if (controller.isLoadingClientUsers.value) {
      return Center(child: HelperUi().loader());
    }

    if (controller.loadError.value.isNotEmpty &&
        controller.clientUsers.isEmpty) {
      return AppEmptyState(
        icon: LucideIcons.circleAlert,
        tone: AppTone.danger,
        title: 'Could not load clients',
        message: controller.loadError.value,
        actionLabel: 'Retry',
        actionIcon: LucideIcons.refreshCw,
        onAction: controller.fetchClientUsers,
      );
    }

    if (controller.clientUsers.isNotEmpty &&
        controller.filteredClients.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.searchX,
        title: 'No results',
        message: 'No clients match your search or filters',
      );
    }

    if (controller.clientUsers.isEmpty) {
      return const AppEmptyState(
        icon: LucideIcons.users,
        title: 'No clients found',
        message: 'Add your first client to get started',
      );
    }
    return null;
  }

  Widget _buildContent() {
    return Obx(() {
      final state = _buildStateView();
      if (state != null) {
        // The shimmer loader fills the card as before.
        if (controller.isLoadingClientUsers.value) return state;
        // Centred in the card, scrollable when the card is short.
        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: state),
            ),
          ),
        );
      }
      return _buildDataTableWithPagination();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE CARD LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileCardList() {
    return Obx(() {
      final state = _buildStateView();
      if (state != null) {
        return SliverToBoxAdapter(
          child: AppCard(padding: EdgeInsets.zero, child: state),
        );
      }
      final clients = controller.filteredClients;
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUserCard(clients[index]),
          ),
          childCount: clients.length,
        ),
      );
    });
  }

  Widget _buildUserCard(ClientUserModel user) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AppAvatar(
                name: user.displayName,
                imageUrl: user.userImage,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${user.id}',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColor.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(user.isActive),
            ],
          ),
          const SizedBox(height: 14),
          _mobileInfoLine(LucideIcons.phone, user.displayPhone),
          const SizedBox(height: 6),
          _mobileInfoLine(LucideIcons.mail, user.displayEmail),
          const SizedBox(height: 6),
          _mobileInfoLine(LucideIcons.mapPin, user.displayLocation),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.viewClient(user.id ?? 0),
                  child: const Text('View Bookings'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.editClient(user),
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileInfoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DATA TABLE WITH PAGINATION (DESKTOP/TABLET)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDataTableWithPagination() {
    return Obx(() {
      final allUsers = controller.filteredClients;
      final rowsPerPage = controller.rowsPerPage.value;
      final totalPages = controller.totalPages;
      final currentPage =
          controller.currentPage.value.clamp(0, totalPages - 1);
      final pageUsers = controller.pagedClients;
      final startIndex = currentPage * rowsPerPage;
      final endIndex = startIndex + pageUsers.length;

      return Column(
        children: [
          // ── Table ──────────────────────────────────────────────
          Expanded(
            child: DataTable2(
              columnSpacing: 16,
              horizontalMargin: 16,
              minWidth: 760,
              dataRowHeight: 64,
              headingRowHeight: 44,
              columns: const [
                DataColumn2(
                    label: Text('ID'), size: ColumnSize.S, fixedWidth: 70),
                DataColumn2(label: Text('Client Info'), size: ColumnSize.L),
                DataColumn2(label: Text('Location'), size: ColumnSize.M),
                DataColumn2(label: Text('Status'), size: ColumnSize.S),
                DataColumn2(
                    label: Text('Actions'),
                    size: ColumnSize.S,
                    fixedWidth: 104),
              ],
              rows: pageUsers.map((user) {
                return DataRow(cells: [
                  // ── ID ──────────────────────────────────────
                  DataCell(Text(
                    '${user.id}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )),

                  // ── Client Info (name + phone + email) ──────
                  DataCell(_buildClientInfoCell(user)),

                  // ── Location ────────────────────────────────
                  DataCell(Text(
                    user.displayLocation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13.5, color: AppColor.textSecondary),
                  )),

                  // ── Status ──────────────────────────────────
                  DataCell(_statusBadge(user.isActive)),

                  // ── Actions ─────────────────────────────────
                  DataCell(_buildCompactActions(user)),
                ]);
              }).toList(),
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

  /// Avatar + name, with phone and email underneath.
  Widget _buildClientInfoCell(ClientUserModel user) {
    return Row(
      children: [
        AppAvatar(name: user.displayName, imageUrl: user.userImage, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${user.displayPhone}  ·  ${user.displayEmail}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// View bookings / edit as compact icon actions.
  Widget _buildCompactActions(ClientUserModel user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View bookings',
          onPressed: () => controller.viewClient(user.id ?? 0),
          icon: Icon(LucideIcons.eye,
              size: 18, color: AppColor.textSecondary),
        ),
        IconButton(
          tooltip: 'Edit client',
          onPressed: () => controller.editClient(user),
          icon: Icon(LucideIcons.pencil,
              size: 18, color: AppColor.textSecondary),
        ),
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
    final caption = TextStyle(fontSize: 13, color: AppColor.textTertiary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.borderSubtle)),
      ),
      child: Row(
        children: [
          // ── Rows per page ──────────────────────────────────────
          Text('Rows per page', style: caption),
          const SizedBox(width: 8),
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
                controller.goToPage(0);
              }
            },
          ),

          const SizedBox(width: 16),

          // ── Range label ────────────────────────────────────────
          Text(
            totalItems == 0
                ? '0 of 0'
                : '${startIndex + 1}–$endIndex of $totalItems',
            style: caption,
          ),

          const Spacer(),

          // ── Page buttons ───────────────────────────────────────
          _pageButton(
            icon: LucideIcons.chevronFirst,
            tooltip: 'First page',
            enabled: currentPage > 0,
            onTap: () => controller.goToPage(0),
          ),
          _pageButton(
            icon: LucideIcons.chevronLeft,
            tooltip: 'Previous page',
            enabled: currentPage > 0,
            onTap: () => controller.goToPage(currentPage - 1),
          ),

          // Page number chips
          ...List.generate(totalPages, (i) => i)
              .where((i) =>
                  i == 0 ||
                  i == totalPages - 1 ||
                  (i - currentPage).abs() <= 1)
              .map((i) => _PageChip(
                    pageNumber: i,
                    isSelected: i == currentPage,
                    onTap: () => controller.goToPage(i),
                  )),

          _pageButton(
            icon: LucideIcons.chevronRight,
            tooltip: 'Next page',
            enabled: currentPage < totalPages - 1,
            onTap: () => controller.goToPage(currentPage + 1),
          ),
          _pageButton(
            icon: LucideIcons.chevronLast,
            tooltip: 'Last page',
            enabled: currentPage < totalPages - 1,
            onTap: () => controller.goToPage(totalPages - 1),
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      icon: Icon(icon,
          size: 18,
          color: enabled ? AppColor.textSecondary : AppColor.borderStrong),
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _statusBadge(bool isActive) {
    return AppStatusBadge(
      label: isActive ? 'Active' : 'Inactive',
      tone: isActive ? AppTone.success : AppTone.danger,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? AppColor.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              '${pageNumber + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColor.cAppPrimaryColor
                    : AppColor.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
