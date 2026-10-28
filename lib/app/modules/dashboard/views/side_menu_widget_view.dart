import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eldivex_app/app/core/theme/theme_controller.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/modules/accounts/views/credit_notes_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/insurance_claims_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/invoice_list.dart';
import 'package:eldivex_app/app/modules/accounts/views/manage_reciepts.dart';
import 'package:eldivex_app/app/modules/accounts/views/revenue_recognition_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/bookings_extension_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/bookings_view.dart';
import 'package:eldivex_app/app/modules/client_users/views/create_client_user.dart';
import 'package:eldivex_app/app/modules/notifications/views/notification_panel.dart';
import 'package:eldivex_app/app/modules/register_cg/views/register_cg_view.dart';
import 'package:eldivex_app/app/modules/support/views/support_view.dart';
import 'package:eldivex_app/app/widgets/helper_ui.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../accounts/views/client_statement.dart';
import '../../banners/views/banners_view.dart';
import '../../client_users/views/manage_client_users.dart';
import '../../register_cg/views/cg_payment_view.dart';
import '../../register_cg/views/manage_attendance.dart';
import '../../register_cg/views/manage_cg_view.dart';
import '../../hostels/views/manage_hostels.dart';
import '../../hostels/views/hostel_settlement_view.dart';
import '../../../routes/app_pages.dart';
import '../../role/controllers/role_controller.dart';
import '../../support/views/create_support_ticket.dart';
import '../../users/controllers/users_controller.dart';
import '../../users/views/users_view.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_view.dart';
import 'manage_master_role.dart';
import '../../settings/views/otp_cupon_generation.dart';
import '../../settings/views/branch_management_view.dart';
import '../../settings/views/services_management_view.dart';
import '../../settings/views/service_categories_view.dart';
import '../../settings/views/org_profile_view.dart';
import '../../settings/views/plan_view.dart';
import '../../audit_log/controllers/audit_log_controller.dart';
import '../../audit_log/views/audit_log_view.dart';
import '../../reports/controllers/reports_controller.dart';
import '../../reports/views/reports_view.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../accounts/controllers/write_off_controller.dart';
import '../../accounts/controllers/refund_controller.dart';
import '../../accounts/controllers/credit_note_controller.dart';
import '../../accounts/controllers/internal_transfer_controller.dart';
import '../../accounts/controllers/outstanding_controller.dart';
import '../../accounts/views/write_off/write_off_list_view.dart';
import '../../accounts/views/refund/refund_list_view.dart';
import '../../accounts/views/internal_transfer/transfer_list_view.dart';
import '../../accounts/views/outstanding/outstanding_dashboard_view.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Sidebar sections, in display order. Menu order is independent of page
/// order: each item carries its own page index.
const List<String> _kMenuSections = ['Overview', 'Operations', 'Finance', 'Admin'];

class SideMenuWidgetView extends StatefulWidget {
  const SideMenuWidgetView({super.key});

  @override
  State<SideMenuWidgetView> createState() => _SideMenuWidgetViewState();
}

class _SideMenuWidgetViewState extends State<SideMenuWidgetView> {
  final _storage = GetStorage();
  late final int _savedIndex;
  late final PageController pageController;
  final rolesController = Get.find<RoleController>();
  final RxInt selectedIndex = 0.obs;
  final RxBool isExpanded = true.obs;
  final RxBool isMobileMenuOpen = false.obs;
  /// Expanded state of each collapsible menu group, keyed by title. Held on
  /// the State so a rebuild doesn't collapse the group.
  final Map<String, RxBool> _expandedMenus = {};

  bool hasAccess(String menuName) {
    return rolesController.accessList.contains(menuName);
  }

  @override
  void initState() {
    super.initState();
    _savedIndex = int.tryParse('${_storage.read('selected_page_index') ?? ''}') ?? 0;
    selectedIndex.value = _savedIndex;
    pageController = PageController(initialPage: _savedIndex);

    if (!Get.isRegistered<UsersController>()) {
      Get.put(UsersController(), permanent: true);
    }
    // DashboardView (Home) doesn't register its own controller, and after a
    // Get.offAllNamed (logout / session expiry) the instance created by
    // UsersController's constructor is disposed while the permanent
    // UsersController survives — so it's never re-created. Re-register here on
    // every shell creation or the Home page throws "DashboardController not
    // found".
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    if (!Get.isRegistered<AuditLogController>()) {
      Get.lazyPut<AuditLogController>(() => AuditLogController(), fenix: true);
    }
    if (!Get.isRegistered<ReportsController>()) {
      Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
    }
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    }
    if (!Get.isRegistered<WriteOffController>()) {
      Get.lazyPut<WriteOffController>(() => WriteOffController(), fenix: true);
    }
    if (!Get.isRegistered<RefundController>()) {
      Get.lazyPut<RefundController>(() => RefundController(), fenix: true);
    }
    if (!Get.isRegistered<CreditNoteController>()) {
      Get.lazyPut<CreditNoteController>(() => CreditNoteController(), fenix: true);
    }
    if (!Get.isRegistered<InternalTransferController>()) {
      Get.lazyPut<InternalTransferController>(() => InternalTransferController(), fenix: true);
    }
    if (!Get.isRegistered<OutstandingController>()) {
      Get.lazyPut<OutstandingController>(() => OutstandingController(), fenix: true);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Determine device type based on screen width
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Build menu dynamically based on accessList
  Map<String, dynamic> _buildMenuStructure() {
    final List<MenuItemData> menuItems = [];
    final List<Widget> pages = [];

    int pageIndex = 0;

    if (hasAccess('Home')) {
      menuItems.add(MenuItemData(
        title: 'Dashboard',
        icon: LucideIcons.layoutDashboard,
        section: 'Overview',
        pageIndex: pageIndex,
      ));
      pages.add(const DashboardView());
      pageIndex++;
    }

    if (hasAccess('Billing')) {
      final reciepts          = pageIndex;
      final userStateMent     = pageIndex + 1;
      final invoiceList       = pageIndex + 2;
      final creditNotes       = pageIndex + 3;
      final insuranceClaims   = pageIndex + 4;
      final finDashboard      = pageIndex + 5;
      final writeOffs         = pageIndex + 6;
      final refunds           = pageIndex + 7;
      final internalTransfers = pageIndex + 8;
      final outstanding       = pageIndex + 9;

      menuItems.add(
        MenuItemData(
          title: 'Accounts',
          icon: LucideIcons.wallet,
          section: 'Finance',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Finance Dashboard',   pageIndex: finDashboard),
            MenuItemData(title: 'Receipts',            pageIndex: reciepts),
            MenuItemData(title: 'Invoices',            pageIndex: invoiceList),
            MenuItemData(title: 'User Statement',      pageIndex: userStateMent),
            MenuItemData(title: 'Outstanding',         pageIndex: outstanding),
            MenuItemData(title: 'Credit Notes',        pageIndex: creditNotes),
            MenuItemData(title: 'Refunds',             pageIndex: refunds),
            MenuItemData(title: 'Write-offs',          pageIndex: writeOffs),
            MenuItemData(title: 'Internal Transfers',  pageIndex: internalTransfers),
            MenuItemData(title: 'Insurance Claims',    pageIndex: insuranceClaims),
          ],
        ),
      );

      pages.add(ManageRecieptsView());
      pages.add(ClientStatementView());
      pages.add(InvoiceListView());
      pages.add(const CreditNotesView());
      pages.add(const InsuranceClaimsView());
      pages.add(const RevenueRecognitionView());
      pages.add(const WriteOffListView());
      pages.add(const RefundListView());
      pages.add(const TransferListView());
      pages.add(const OutstandingDashboardView());
      pageIndex += 10;
    }

    if (hasAccess('Users')) {
      final createClientUser = pageIndex;
      final manageClientUsers = pageIndex + 1;

      menuItems.add(
        MenuItemData(
          title: 'Clients',
          icon: LucideIcons.users,
          section: 'Operations',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Manage Clients', pageIndex: manageClientUsers),
            MenuItemData(title: 'Add Client', pageIndex: createClientUser),
          ],
        ),
      );

      pages.add(CreateClientUser());
      pages.add(ManageClientUsers());
      pageIndex += 2;
    }

    if (hasAccess('Bookings')) {
      final manageBookingsIndex = pageIndex;
      final createBookingsIndex = pageIndex + 1;

      menuItems.add(
        MenuItemData(
          title: 'Bookings',
          icon: LucideIcons.calendarDays,
          section: 'Operations',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Manage Bookings', pageIndex: manageBookingsIndex),
            MenuItemData(title: 'Extensions', pageIndex: createBookingsIndex),
          ],
        ),
      );

      pages.add(BookingsView());
      pages.add(BookingsExtensionView());
      pageIndex += 2;
    }

    if (hasAccess('HP Modules')) {
      final registerCgIndex       = pageIndex;
      final manageCgIndex         = pageIndex + 1;
      final manageAttendanceIndex = pageIndex + 2;
      final cgPaymentIndex        = pageIndex + 3;
      final manageHostelsIndex    = pageIndex + 4;
      final hostelSettlementIndex = pageIndex + 5;

      // Persist so RegisterCgController can navigate here after successful save
      _storage.write('manage_hp_page_index', manageCgIndex);

      menuItems.add(
        MenuItemData(
          title: 'Health Professionals',
          icon: LucideIcons.stethoscope,
          section: 'Operations',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Manage HP',          pageIndex: manageCgIndex),
            MenuItemData(title: 'Register HP',        pageIndex: registerCgIndex),
            MenuItemData(title: 'Attendance',         pageIndex: manageAttendanceIndex),
            MenuItemData(title: 'CG Payments',        pageIndex: cgPaymentIndex),
            MenuItemData(title: 'Hostels',            pageIndex: manageHostelsIndex),
            MenuItemData(title: 'Hostel Settlements', pageIndex: hostelSettlementIndex),
          ],
        ),
      );

      pages.add(RegisterCgView());
      pages.add(ManageCgView());
      pages.add(ManageAttendance());
      pages.add(const CgPaymentView());
      pages.add(const ManageHostelsView());
      pages.add(const HostelSettlementView());
      pageIndex += 6;
    }

    if (hasAccess('Support Ticket')) {
      final createSupportTicketIndex = pageIndex;
      final manageSupportTicketsIndex = pageIndex + 1;

      menuItems.add(
        MenuItemData(
          title: 'Support',
          icon: LucideIcons.headset,
          section: 'Admin',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'All Tickets', pageIndex: manageSupportTicketsIndex),
            MenuItemData(title: 'Create Ticket', pageIndex: createSupportTicketIndex),
          ],
        ),
      );

      pages.add(CreateSupportTicket());
      pages.add(SupportView());
      pageIndex += 2;
    }

    // ── Phase 4.3: Reports (top-level, no submenu) ──────────────────────────
    if (hasAccess('Settings')) {
      final reportsIndex = pageIndex;
      menuItems.add(MenuItemData(
        title:   'Reports',
        icon:    LucideIcons.chartLine,
        section: 'Overview',
        pageIndex: reportsIndex,
      ));
      pages.add(const ReportsView());
      pageIndex++;
    }

    if (hasAccess('Settings')) {
      // Plan & Renewal is the org's Super Admin's only; last, so the other
      // pages keep their indices.
      final superAdmin               = rolesController.isSuperAdmin;
      final orgProfileIndex          = pageIndex;
      final manageEmpRolesIndex      = pageIndex + 1;
      final addEmployees             = pageIndex + 2;
      final bannersIndex             = pageIndex + 3;
      final otpCuponIndex            = pageIndex + 4;
      final auditLogIndex            = pageIndex + 5;
      final branchManagementIndex    = pageIndex + 6;
      final servicesManagementIndex  = pageIndex + 7;
      final serviceCategoriesIndex   = pageIndex + 8;
      final planRenewalIndex         = pageIndex + 9;

      menuItems.add(
        MenuItemData(
          title: 'Settings',
          icon: LucideIcons.settings,
          section: 'Admin',
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Organisation Profile',  pageIndex: orgProfileIndex),
            MenuItemData(title: 'Employees',             pageIndex: addEmployees),
            MenuItemData(title: 'Roles & Permissions',   pageIndex: manageEmpRolesIndex),
            MenuItemData(title: 'Branches',              pageIndex: branchManagementIndex),
            MenuItemData(title: 'Service Categories',    pageIndex: serviceCategoriesIndex),
            MenuItemData(title: 'Services',              pageIndex: servicesManagementIndex),
            MenuItemData(title: 'Banners',               pageIndex: bannersIndex),
            MenuItemData(title: 'OTP & Coupons',         pageIndex: otpCuponIndex),
            MenuItemData(title: 'Audit Log',             pageIndex: auditLogIndex),
            if (superAdmin)
              MenuItemData(title: 'Plan & Renewal',      pageIndex: planRenewalIndex),
          ],
        ),
      );

      pages.add(const OrgProfileView());
      pages.add(ManageMasterRoles());
      pages.add(UsersView());
      pages.add(ManageBannersView());
      pages.add(OtpCouponGeneration());
      pages.add(const AuditLogView());
      pages.add(const BranchManagementView());
      pages.add(const ServicesManagementView());
      pages.add(const ServiceCategoriesView());
      if (superAdmin) pages.add(const PlanView(embedded: true));
      pageIndex += superAdmin ? 10 : 9;
    }

    return {
      "menuItems": menuItems,
      "pages": pages,
    };
  }

  void _navigateToPage(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
    _storage.write('selected_page_index', index);

    // Close mobile menu after navigation
    if (_getDeviceType(context) == DeviceType.mobile) {
      isMobileMenuOpen.value = false;
    }
  }

  double _getSidebarWidth(BuildContext context, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        final w = MediaQuery.of(context).size.width;
        return w * 0.82 > 300 ? 300 : w * 0.82;
      case DeviceType.tablet:
        return isExpanded.value ? 240 : 72;
      case DeviceType.desktop:
        return isExpanded.value ? 260 : 72;
    }
  }

  /// (group, page) titles for the top-bar breadcrumb.
  (String?, String) _locate(List<MenuItemData> menuItems, int index) {
    for (final item in menuItems) {
      if (item.pageIndex == index) return (null, item.title);
      for (final child in item.children) {
        if (child.pageIndex == index) return (item.title, child.title);
      }
    }
    return (null, 'Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading State
      if (rolesController.isRolesLoading.value) {
        return const _ShellSplash();
      }

      // No roles access
      if (rolesController.accessList.isEmpty) {
        // No valid session (missing/cleared token) — go to login instead of
        // showing a dead-end screen. Covers deep links where the route
        // middleware didn't run.
        if (!rolesController.isAuthenticated()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Logout already navigated: clearAuth() rebuilds this Obx while
            // the shell is being torn down, and a second offAllNamed(/login)
            // here replaces the fresh login route — its controller gets
            // deleted and the visible form ends up bound to a dead instance.
            if (Get.currentRoute.split('?').first == Routes.LOGIN) return;
            Get.offAllNamed(Routes.LOGIN);
          });
          return const _ShellSplash();
        }
        // Authenticated but the role has no modules assigned.
        return Scaffold(
          backgroundColor: AppColor.cAppBackgroundColor,
          body: AppEmptyState(
            icon: LucideIcons.lock,
            tone: AppTone.warning,
            title: 'No access assigned',
            message:
                'Your account has no modules assigned yet. Contact your administrator to get access.',
            actionLabel: 'Back to login',
            actionIcon: LucideIcons.logOut,
            onAction: () {
              rolesController.clearAuth();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        );
      }

      // Build menu dynamically
      final data = _buildMenuStructure();
      final List<MenuItemData> menuItems = data["menuItems"];
      final List<Widget> pages = data["pages"];
      final deviceType = _getDeviceType(context);
      final isMobile = deviceType == DeviceType.mobile;

      // Clamp saved index if it exceeds available pages
      if (selectedIndex.value >= pages.length) {
        selectedIndex.value = 0;
        _storage.write('selected_page_index', 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(0);
          }
        });
      }

      // Open the group that holds the current page.
      for (final item in menuItems) {
        if (item.children.any((c) => c.pageIndex == selectedIndex.value)) {
          _expandedMenus.putIfAbsent(item.title, () => true.obs);
        }
      }

      return Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: Stack(
          children: [
            Row(
              children: [
                // Desktop/Tablet Sidebar
                if (!isMobile)
                  Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: _getSidebarWidth(context, deviceType),
                      color: AppColor.sidebarBg,
                      child: _buildSidebar(menuItems, deviceType),
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      Obx(() => _buildTopBar(menuItems, deviceType)),

                      // Page Content
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            selectedIndex.value = index;
                          },
                          children: pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Mobile Drawer Overlay
            if (isMobile)
              Obx(() {
                if (!isMobileMenuOpen.value) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () => isMobileMenuOpen.value = false,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {}, // Prevent closing when tapping drawer
                        child: Container(
                          width: _getSidebarWidth(context, deviceType),
                          decoration: BoxDecoration(
                            color: AppColor.sidebarBg,
                            boxShadow: AppShadows.overlay,
                          ),
                          child: SafeArea(
                            child: _buildSidebar(menuItems, deviceType),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // SIDEBAR
  // ═══════════════════════════════════════════════════════════════

  /// Sidebar shows labels everywhere except the collapsed desktop/tablet rail.
  bool _showLabels(DeviceType deviceType) =>
      deviceType == DeviceType.mobile || isExpanded.value;

  Widget _buildSidebar(List<MenuItemData> menuItems, DeviceType deviceType) {
    final showLabels = _showLabels(deviceType);
    final sections = <Widget>[];
    for (final section in _kMenuSections) {
      final items = menuItems.where((m) => m.section == section).toList();
      if (items.isEmpty) continue;
      sections.add(_buildSectionLabel(section, showLabels, first: sections.isEmpty));
      for (final item in items) {
        sections.add(_buildMenuItem(item, deviceType));
      }
    }
    // Anything without a known section still shows, at the end.
    for (final item in menuItems.where((m) => !_kMenuSections.contains(m.section))) {
      sections.add(_buildMenuItem(item, deviceType));
    }

    return Column(
      children: [
        _buildSidebarHeader(deviceType),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: sections,
          ),
        ),
        _buildSidebarFooter(deviceType),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool showLabels, {required bool first}) {
    if (!showLabels) {
      return Padding(
        padding: EdgeInsets.only(top: first ? 4 : 10, bottom: 6),
        child: first
            ? const SizedBox.shrink()
            : Divider(height: 1, indent: 12, endIndent: 12, color: AppColor.sidebarBorder),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(12, first ? 8 : 20, 12, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColor.sidebarFgSubtle,
        ),
      ),
    );
  }

  Widget _brandMark(double size) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset('assets/images/e_mark.png', fit: BoxFit.contain),
    );
  }

  Widget _buildSidebarHeader(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final showLabels = _showLabels(deviceType);
    final orgCode = (_storage.read('org_code') ?? '').toString();

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: showLabels ? 16 : 0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.sidebarBorder)),
      ),
      child: showLabels
          ? Row(
              children: [
                _brandMark(34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eldivex',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColor.sidebarFg,
                        ),
                      ),
                      Text(
                        orgCode.isEmpty ? 'Admin Console' : orgCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: AppColor.sidebarFgMuted),
                      ),
                    ],
                  ),
                ),
                if (isMobile)
                  IconButton(
                    tooltip: 'Close menu',
                    icon: Icon(LucideIcons.x, size: 20, color: AppColor.sidebarFgMuted),
                    onPressed: () => isMobileMenuOpen.value = false,
                  ),
              ],
            )
          : Center(child: _brandMark(36)),
    );
  }

  Widget _buildSidebarFooter(DeviceType deviceType) {
    final showLabels = _showLabels(deviceType);
    final userName = (_storage.read('user_name') ?? 'Admin').toString();
    final userImage = (_storage.read('user_image') ?? '').toString();
    final roleName = rolesController.allAccessRoles.isNotEmpty
        ? rolesController.allAccessRoles.first.roleName
        : '';

    final avatar = AppAvatar(
      name: userName,
      imageUrl: userImage,
      size: 34,
      backgroundColor: AppColor.sidebarActiveBg,
      foregroundColor: AppColor.sidebarFg,
    );

    return Container(
      padding: EdgeInsets.all(showLabels ? 12 : 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.sidebarBorder)),
      ),
      child: _userMenu(
        child: showLabels
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.sidebarHover,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    avatar,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColor.sidebarFg,
                            ),
                          ),
                          if (roleName.isNotEmpty)
                            Text(
                              roleName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppColor.sidebarFgMuted),
                            ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronsUpDown, size: 18, color: AppColor.sidebarFgMuted),
                  ],
                ),
              )
            : Center(child: avatar),
      ),
    );
  }

  /// Account menu shared by the sidebar footer and the top-bar avatar.
  Widget _userMenu({required Widget child}) {
    final themeController = Get.find<ThemeController>();
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, -8),
      position: PopupMenuPosition.over,
      constraints: const BoxConstraints(minWidth: 220),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'appearance',
          child: _menuRow(LucideIcons.palette, 'Appearance'),
        ),
        PopupMenuItem<String>(
          value: 'theme',
          child: _menuRow(
            themeController.isDark ? LucideIcons.sun : LucideIcons.moon,
            themeController.isDark ? 'Light mode' : 'Dark mode',
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<String>(
          value: 'logout',
          child: _menuRow(LucideIcons.logOut, 'Log out', color: AppColor.danger),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'appearance':
            Get.toNamed(Routes.appearance);
            break;
          case 'theme':
            themeController.setThemeMode(
              themeController.isDark ? ThemeMode.light : ThemeMode.dark,
            );
            break;
          case 'logout':
            // Logout must not touch LoginController: creating it here ties it
            // to this route, and its disposal during Get.offAllNamed leaves
            // the login screen bound to a dead instance.
            rolesController.clearAuth();
            Get.offAllNamed(Routes.LOGIN);
            HelperUi.showToast(message: "Logged out successfully");
            break;
        }
      },
      child: child,
    );
  }

  Widget _menuRow(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColor.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color ?? AppColor.textPrimary,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData item, DeviceType deviceType) {
    if (item.hasSubmenu) {
      return _buildExpandableMenuItem(item, deviceType);
    } else {
      return _buildSimpleMenuItem(item, deviceType);
    }
  }

  /// One nav row. Shared look for top-level items and group headers.
  Widget _navRow({
    required IconData? icon,
    required String title,
    required bool selected,
    required bool showLabels,
    bool groupActive = false,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final bool strong = selected || groupActive;
    final Color fg = strong ? AppColor.sidebarFg : AppColor.sidebarFgMuted;
    final row = Material(
      color: selected ? AppColor.sidebarActiveBg : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        hoverColor: AppColor.sidebarHover,
        splashColor: AppColor.sidebarHover,
        highlightColor: Colors.transparent,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: showLabels ? 10 : 0),
          child: Row(
            mainAxisAlignment:
                showLabels ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (showLabels) ...[
                _activeMarker(selected),
                const SizedBox(width: 8),
              ],
              Icon(icon, size: 19, color: fg),
              if (showLabels) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                      color: fg,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: showLabels ? row : Tooltip(message: title, preferBelow: false, child: row),
    );
  }

  /// Accent bar marking the current page. Space is always reserved so labels
  /// stay aligned whether or not the row is active.
  Widget _activeMarker(bool active) {
    return Container(
      width: 3,
      height: 16,
      decoration: BoxDecoration(
        color: active ? AppColor.sidebarAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSimpleMenuItem(MenuItemData item, DeviceType deviceType) {
    return Obx(() {
      final showLabels = _showLabels(deviceType);
      return _navRow(
        icon: item.icon,
        title: item.title,
        selected: selectedIndex.value == item.pageIndex,
        showLabels: showLabels,
        onTap: () {
          if (item.pageIndex != null) _navigateToPage(item.pageIndex!);
        },
      );
    });
  }

  Widget _buildExpandableMenuItem(MenuItemData item, DeviceType deviceType) {
    final RxBool isExpandedMenu =
        _expandedMenus.putIfAbsent(item.title, () => false.obs);

    return Obx(() {
      final showLabels = _showLabels(deviceType);
      final groupActive =
          item.children.any((c) => c.pageIndex == selectedIndex.value);

      // Collapsed rail: the icon opens a flyout with the group's pages.
      if (!showLabels) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: PopupMenuButton<int>(
            tooltip: item.title,
            position: PopupMenuPosition.over,
            offset: const Offset(56, 0),
            constraints: const BoxConstraints(minWidth: 200),
            onSelected: _navigateToPage,
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                enabled: false,
                height: 32,
                child: Text(
                  item.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColor.lightGrey,
                  ),
                ),
              ),
              for (final child in item.children)
                PopupMenuItem<int>(
                  value: child.pageIndex,
                  height: 38,
                  child: Text(
                    child.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: child.pageIndex == selectedIndex.value
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: child.pageIndex == selectedIndex.value
                          ? AppColor.cAppPrimaryColor
                          : AppColor.textPrimary,
                    ),
                  ),
                ),
            ],
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: groupActive ? AppColor.sidebarActiveBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 19,
                  color: groupActive ? AppColor.sidebarFg : AppColor.sidebarFgMuted,
                ),
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navRow(
            icon: item.icon,
            title: item.title,
            selected: false,
            groupActive: groupActive,
            showLabels: true,
            onTap: () => isExpandedMenu.value = !isExpandedMenu.value,
            trailing: AnimatedRotation(
              turns: isExpandedMenu.value ? 0.25 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(LucideIcons.chevronRight, size: 18, color: AppColor.sidebarFgSubtle),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpandedMenu.value
                ? Container(
                    margin: const EdgeInsets.only(left: 30, top: 2, bottom: 6),
                    padding: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: AppColor.sidebarBorder)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: item.children
                          .map((child) => _buildSubmenuItem(child))
                          .toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    });
  }

  Widget _buildSubmenuItem(MenuItemData item) {
    return Obx(() {
      final isSelected = selectedIndex.value == item.pageIndex;

      return Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Material(
          color: isSelected ? AppColor.sidebarActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: () {
              if (item.pageIndex != null) {
                _navigateToPage(item.pageIndex!);
              }
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            hoverColor: AppColor.sidebarHover,
            splashColor: AppColor.sidebarHover,
            highlightColor: Colors.transparent,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _activeMarker(isSelected),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColor.sidebarFg : AppColor.sidebarFgMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopBar(List<MenuItemData> menuItems, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final (group, page) = _locate(menuItems, selectedIndex.value);
    final themeController = Get.find<ThemeController>();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(bottom: BorderSide(color: AppColor.divColor)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: isMobile
                ? 'Open menu'
                : (isExpanded.value ? 'Collapse sidebar' : 'Expand sidebar'),
            icon: Icon(
              isMobile
                  ? LucideIcons.menu
                  : (isExpanded.value ? LucideIcons.panelLeftClose : LucideIcons.menu),
              size: 20,
            ),
            onPressed: () {
              if (isMobile) {
                isMobileMenuOpen.value = true;
              } else {
                isExpanded.value = !isExpanded.value;
              }
            },
          ),
          const SizedBox(width: 6),
          if (!isMobile) ...[
            Container(width: 1, height: 20, color: AppColor.divColor),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Row(
              children: [
                if (group != null && !isMobile) ...[
                  Flexible(
                    child: Text(
                      group,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: AppColor.textTertiary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(LucideIcons.chevronRight,
                        size: 16, color: AppColor.lightGrey),
                  ),
                ],
                Flexible(
                  child: Text(
                    page,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const NotificationBell(),
          Obx(() {
            themeController.themeMode.value;
            final isDark = themeController.isDark;
            return IconButton(
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              icon: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                size: 20,
              ),
              onPressed: () => themeController.setThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            );
          }),
          if (!isMobile)
            IconButton(
              tooltip: 'Appearance',
              icon: const Icon(LucideIcons.palette, size: 20),
              onPressed: () => Get.toNamed(Routes.appearance),
            ),
          const SizedBox(width: 6),
          _userMenu(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AppAvatar(
                name: (_storage.read('user_name') ?? 'Admin').toString(),
                imageUrl: (_storage.read('user_image') ?? '').toString(),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Neutral splash while role access loads.
class _ShellSplash extends StatelessWidget {
  const _ShellSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/e_mark.png', width: 44, height: 44),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(minHeight: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Device Type Enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

// Menu Item Data Model
class MenuItemData {
  final String title;
  final IconData? icon;
  final int? pageIndex;
  final bool hasSubmenu;
  final bool isSubmenuItem;
  final String? section;
  final List<MenuItemData> children;

  MenuItemData({
    required this.title,
    this.icon,
    this.pageIndex,
    this.hasSubmenu = false,
    this.isSubmenuItem = false,
    this.section,
    this.children = const [],
  });
}
