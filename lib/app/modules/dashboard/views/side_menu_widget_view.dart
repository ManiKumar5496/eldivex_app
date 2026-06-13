import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/modules/accounts/views/credit_notes_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/insurance_claims_view.dart';
import 'package:eldivex_app/app/modules/accounts/views/invoice_list.dart';
import 'package:eldivex_app/app/modules/accounts/views/manage_reciepts.dart';
import 'package:eldivex_app/app/modules/accounts/views/revenue_recognition_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/bookings_extension_view.dart';
import 'package:eldivex_app/app/modules/bookings/views/bookings_view.dart';
import 'package:eldivex_app/app/modules/client_users/views/create_client_user.dart';
import 'package:eldivex_app/app/modules/register_cg/views/register_cg_view.dart';
import 'package:eldivex_app/app/modules/support/views/support_view.dart';
import '../../../core/values/text_style_constants.dart';
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
import '../../accounts/views/credit_note/credit_note_list_view.dart';
import '../../accounts/views/internal_transfer/transfer_list_view.dart';
import '../../accounts/views/outstanding/outstanding_dashboard_view.dart';

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

  bool hasAccess(String menuName) {
    return rolesController.accessList.contains(menuName);
  }

  @override
  void initState() {
    super.initState();
    _savedIndex = _storage.read<int>('selected_page_index') ?? 0;
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
        title: 'Home',
        icon: Icons.home_outlined,
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
      final creditNotesList   = pageIndex + 8;
      final internalTransfers = pageIndex + 9;
      final outstanding       = pageIndex + 10;

      menuItems.add(
        MenuItemData(
          title: 'Accounts',
          icon: Icons.account_balance,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Reciepts',            pageIndex: reciepts),
            MenuItemData(title: 'User Statement',      pageIndex: userStateMent),
            MenuItemData(title: 'Invoice List',        pageIndex: invoiceList),
            MenuItemData(title: 'Credit Notes',        pageIndex: creditNotes),
            MenuItemData(title: 'Insurance Claims',    pageIndex: insuranceClaims),
            MenuItemData(title: 'Finance Dashboard',   pageIndex: finDashboard),
            MenuItemData(title: 'Write-offs',          pageIndex: writeOffs),
            MenuItemData(title: 'Refunds',             pageIndex: refunds),
            MenuItemData(title: 'Credit Note Mgmt',    pageIndex: creditNotesList),
            MenuItemData(title: 'Internal Transfers',  pageIndex: internalTransfers),
            MenuItemData(title: 'Outstanding',         pageIndex: outstanding),
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
      pages.add(const CreditNoteListView());
      pages.add(const TransferListView());
      pages.add(const OutstandingDashboardView());
      pageIndex += 11;
    }

    if (hasAccess('Users')) {
      final createClientUser = pageIndex;
      final manageClientUsers = pageIndex + 1;

      menuItems.add(
        MenuItemData(
          title: 'User',
          icon: Icons.people_outline,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Create Users', pageIndex: createClientUser),
            MenuItemData(title: 'Manage Users', pageIndex: manageClientUsers),
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
          icon: Icons.calendar_today_outlined,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Manage Bookings', pageIndex: manageBookingsIndex),
            MenuItemData(title: 'Extension List', pageIndex: createBookingsIndex),
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
          title: 'HP Management',
          icon: Icons.app_registration,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Register HP',       pageIndex: registerCgIndex),
            MenuItemData(title: 'Manage HP',          pageIndex: manageCgIndex),
            MenuItemData(title: 'Manage Attendance',  pageIndex: manageAttendanceIndex),
            MenuItemData(title: 'CG Payments',        pageIndex: cgPaymentIndex),
            MenuItemData(title: 'Manage Hostels',     pageIndex: manageHostelsIndex),
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
          icon: Icons.support,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Create Ticket', pageIndex: createSupportTicketIndex),
            MenuItemData(title: 'Manage Support', pageIndex: manageSupportTicketsIndex),
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
        icon:    Icons.bar_chart_outlined,
        pageIndex: reportsIndex,
      ));
      pages.add(const ReportsView());
      pageIndex++;
    }

    if (hasAccess('Settings')) {
      final manageEmpRolesIndex      = pageIndex;
      final addEmployees             = pageIndex + 1;
      final bannersIndex             = pageIndex + 2;
      final otpCuponIndex            = pageIndex + 3;
      final auditLogIndex            = pageIndex + 4;
      final branchManagementIndex    = pageIndex + 5;
      final servicesManagementIndex  = pageIndex + 6;

      menuItems.add(
        MenuItemData(
          title: 'Settings',
          icon: Icons.settings,
          hasSubmenu: true,
          children: [
            MenuItemData(title: 'Manage Emp Roles',     pageIndex: manageEmpRolesIndex),
            MenuItemData(title: 'Manage Employees',      pageIndex: addEmployees),
            MenuItemData(title: 'Manage Banners',        pageIndex: bannersIndex),
            MenuItemData(title: 'OTP & Cupon',           pageIndex: otpCuponIndex),
            MenuItemData(title: 'Audit Log',             pageIndex: auditLogIndex),
            MenuItemData(title: 'Branch Management',     pageIndex: branchManagementIndex),
            MenuItemData(title: 'Services Management',   pageIndex: servicesManagementIndex),
          ],
        ),
      );

      pages.add(ManageMasterRoles());
      pages.add(UsersView());
      pages.add(ManageBannersView());
      pages.add(OtpCouponGeneration());
      pages.add(const AuditLogView());
      pages.add(const BranchManagementView());
      pages.add(const ServicesManagementView());
      pageIndex += 7;
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
    final screenWidth = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return isExpanded.value ? screenWidth * 0.75 : 0;
      case DeviceType.tablet:
        return isExpanded.value ? 240 : 70;
      case DeviceType.desktop:
        return isExpanded.value ? screenWidth * 0.18 : screenWidth * 0.07;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading State
      if (rolesController.isRolesLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Authenticated but the role has no modules assigned.
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "No Access Assigned",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your account has no modules assigned. Contact your administrator.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Back to Login"),
                  onPressed: () {
                    rolesController.clearAuth();
                    Get.offAllNamed(Routes.LOGIN);
                  },
                ),
              ],
            ),
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

      return Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                // Desktop/Tablet Sidebar
                if (!isMobile)
                  Obx(
                        () => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _getSidebarWidth(context, deviceType),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        border: Border(
                          right: BorderSide(color: AppColor.divColor, width: 1),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSidebarHeader(deviceType),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: deviceType == DeviceType.tablet ? 12 : 16,
                                vertical: 8,
                              ),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                return _buildMenuItem(menuItems[index], deviceType);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Mobile App Bar
                      if (isMobile) _buildMobileAppBar(),

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
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {}, // Prevent closing when tapping drawer
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _getSidebarWidth(context, deviceType),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSidebarHeader(deviceType),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: menuItems.length,
                                  itemBuilder: (context, index) {
                                    return _buildMenuItem(menuItems[index], deviceType);
                                  },
                                ),
                              ),
                            ],
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

  Widget _buildMobileAppBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(
          bottom: BorderSide(color: AppColor.divColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                isMobileMenuOpen.value = true;
                isExpanded.value = true;
              },
              color: AppColor.cPrimaryButtonColor,
            ),
            const SizedBox(width: 8),
            Text(
              'AdminPanel',
              style: AppTextStyles.regularBlu20.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColor.divColor.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isExpanded.value) ...[
            Expanded(
              child: Text(
                'AdminPanel',
                style: AppTextStyles.regularBlu20.copyWith(
                  fontSize: deviceType == DeviceType.tablet ? 18 : 20,
                ),
              ),
            ),
            IconButton(
              icon: Icon(isMobile ? Icons.close : Icons.chevron_left),
              onPressed: () {
                if (isMobile) {
                  isMobileMenuOpen.value = false;
                } else {
                  isExpanded.value = !isExpanded.value;
                }
              },
              color: AppColor.unSelectedMenu,
            ),
          ] else ...[
            Center(
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  isExpanded.value = !isExpanded.value;
                },
                color: AppColor.unSelectedMenu,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item, DeviceType deviceType) {
    if (item.hasSubmenu) {
      return _buildExpandableMenuItem(item, deviceType);
    } else {
      return _buildSimpleMenuItem(item, deviceType);
    }
  }

  Widget _buildSimpleMenuItem(MenuItemData item, DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;

    return Obx(() {
      final isSelected = selectedIndex.value == item.pageIndex;

      return Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 2 : 4),
        child: InkWell(
          onTap: () {
            if (item.pageIndex != null) {
              _navigateToPage(item.pageIndex!);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 16,
              vertical: isTablet ? 12 : 14,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.cPrimaryButtonColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: isTablet ? 20 : 22,
                  color: isSelected ? AppColor.buttonTextWhite : AppColor.unSelectedMenu,
                ),
                if (isExpanded.value) ...[
                  SizedBox(width: isTablet ? 12 : 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColor.buttonTextWhite : AppColor.unSelectedMenu,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpandableMenuItem(MenuItemData item, DeviceType deviceType) {
    final RxBool isExpandedMenu = false.obs;
    final isTablet = deviceType == DeviceType.tablet;

    return Obx(() {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 2 : 4),
            child: InkWell(
              onTap: () {
                isExpandedMenu.value = !isExpandedMenu.value;
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 16,
                  vertical: isTablet ? 12 : 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: isTablet ? 20 : 22,
                      color: AppColor.unSelectedMenu,
                    ),
                    if (isExpanded.value) ...[
                      SizedBox(width: isTablet ? 12 : 16),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 15,
                            fontWeight: FontWeight.w500,
                            color: AppColor.unSelectedMenu,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isExpandedMenu.value
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: isTablet ? 18 : 20,
                        color: AppColor.unSelectedMenu,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isExpandedMenu.value && isExpanded.value)
            ...item.children.map((child) => _buildSubmenuItem(child, deviceType)),
        ],
      );
    });
  }

  Widget _buildSubmenuItem(MenuItemData item, DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;

    return Obx(() {
      final isSelected = selectedIndex.value == item.pageIndex;

      return Padding(
        padding: EdgeInsets.only(
          left: isTablet ? 12 : 16,
          bottom: isTablet ? 2 : 4,
        ),
        child: InkWell(
          onTap: () {
            if (item.pageIndex != null) {
              _navigateToPage(item.pageIndex!);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 16,
              vertical: isTablet ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(width: isTablet ? 20 : 22),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColor.cPrimaryButtonColor
                          : AppColor.unSelectedMenu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
  final List<MenuItemData> children;

  MenuItemData({
    required this.title,
    this.icon,
    this.pageIndex,
    this.hasSubmenu = false,
    this.isSubmenuItem = false,
    this.children = const [],
  });
}