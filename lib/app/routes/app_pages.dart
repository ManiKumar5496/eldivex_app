import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
import '../modules/accounts/bindings/accounts_binding.dart';
import '../modules/accounts/views/accounts_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/banners/bindings/banners_binding.dart';
import '../modules/banners/views/banners_view.dart';
import '../modules/bookings/bindings/bookings_binding.dart';
import '../modules/bookings/views/bookings_view.dart';
import '../modules/bookings/views/create_booking_screen.dart';
import '../modules/client_users/bindings/client_users_binding.dart';
import '../modules/client_users/views/add_client_user_details.dart';
import '../modules/client_users/views/client_users_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/create_user_roles.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dashboard/views/side_menu_widget_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/register_cg/bindings/register_cg_binding.dart';
import '../modules/register_cg/views/register_cg_view.dart';
import '../modules/role/bindings/role_binding.dart';
import '../modules/role/views/role_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/support_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/add_users_view.dart';
import '../modules/users/views/users_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/settings/views/services_management_view.dart';
import '../modules/settings/views/branch_management_view.dart';
import '../modules/settings/views/otp_cupon_generation.dart';
import '../modules/register_cg/bindings/hp_payouts_binding.dart';
import '../modules/register_cg/views/hp_payouts_view.dart';
// ── Financial Module ────────────────────────────────────────────────────────
import '../modules/accounts/bindings/write_off_binding.dart';
import '../modules/accounts/bindings/refund_binding.dart';
import '../modules/accounts/bindings/credit_note_binding.dart';
import '../modules/accounts/bindings/internal_transfer_binding.dart';
import '../modules/accounts/bindings/outstanding_binding.dart';
import '../modules/accounts/views/write_off/write_off_list_view.dart';
import '../modules/accounts/views/write_off/create_write_off_view.dart';
import '../modules/accounts/views/write_off/write_off_detail_view.dart';
import '../modules/accounts/views/refund/refund_list_view.dart';
import '../modules/accounts/views/refund/create_refund_view.dart';
import '../modules/accounts/views/refund/refund_detail_view.dart';
import '../modules/accounts/views/credit_note/credit_note_list_view.dart';
import '../modules/accounts/views/credit_note/create_credit_note_view.dart';
import '../modules/accounts/views/credit_note/credit_note_detail_view.dart';
import '../modules/accounts/views/credit_note/apply_credit_note_view.dart';
import '../modules/accounts/views/internal_transfer/transfer_list_view.dart';
import '../modules/accounts/views/internal_transfer/create_transfer_view.dart';
import '../modules/accounts/views/internal_transfer/transfer_detail_view.dart';
import '../modules/accounts/views/outstanding/outstanding_dashboard_view.dart';
import '../modules/accounts/views/outstanding/client_outstanding_detail.dart';
import '../modules/accounts/views/outstanding/booking_outstanding_detail.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [LoginGuardMiddleware()],
    ),

    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [RoleMiddleware("Home")],
    ),

    GetPage(
      name: Routes.USERS,
      page: () => const UsersView(),
      binding: UsersBinding(),
      middlewares: [RoleMiddleware("Settings")],
    ),

    // ----------------------------
    // BOOKINGS
    // ----------------------------
    GetPage(
      name: Routes.BOOKINGS,
      page: () =>  BookingsView(),
      binding: BookingsBinding(),
      middlewares: [RoleMiddleware("Bookings")],
    ),

    // ----------------------------
    // REGISTER CG
    // ----------------------------
    GetPage(
      name: Routes.REGISTER_CG,
      page: () => const RegisterCgView(),
      binding: RegisterCgBinding(),
      middlewares: [RoleMiddleware("HP Modules")],
    ),

    // ----------------------------
    // ROLE MANAGEMENT
    // ----------------------------
    GetPage(
      name: Routes.ROLE,
      page: () => const RoleView(),
      binding: RoleBinding(),
      middlewares: [RoleMiddleware("role")],
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const SideMenuWidgetView(),
      binding: RoleBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SUPPORT,
      page: () => const SupportView(),
      binding: SupportBinding(),
      middlewares: [RoleMiddleware("Support Ticket")],
    ),
    GetPage(
      name: _Paths.AddUser,
      page: () => const AddUsersView(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: _Paths.AddMasterRoles,
      page: () => const CreateUserRoles(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: _Paths.createBookings,
      page: () => const CreateBookingsView(),
      binding: BookingsBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.BANNERS,
      page: () => const ManageBannersView(),
      binding: BannersBinding(),
      middlewares: [RoleMiddleware("Settings")],
    ),
    GetPage(
      name: _Paths.ACCOUNTS,
      page: () => const AccountsView(),
      binding: AccountsBinding(),
      middlewares: [RoleMiddleware("Billing")],
    ),
    GetPage(
      name: _Paths.CLIENT_USERS,
      page: () => const ClientUsersView(),
      binding: ClientUsersBinding(),
      middlewares: [RoleMiddleware("Bookings")],
    ),
    GetPage(
      name: _Paths.addClientDetails,
      page: () => const AddClientUserDetails(),
      binding: ClientUsersBinding(),
      middlewares: [RoleMiddleware("Bookings")],
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    // ── Phase 2.5 — Services Management ────────────────────────────────────
    GetPage(
      name: _Paths.servicesManagement,
      page: () => const ServicesManagementView(),
      binding: SettingsBinding(),
    ),

    // ── Phase 2.6 — Branch Management ──────────────────────────────────────
    GetPage(
      name: _Paths.branchManagement,
      page: () => const BranchManagementView(),
      binding: SettingsBinding(),
    ),

    // ── Phase 2.5/2.6 — OTP & Coupon (named route from settings hub) ───────
    GetPage(
      name: _Paths.settingsOtpCoupon,
      page: () => const OtpCouponGeneration(),
      binding: SettingsBinding(),
    ),

    // ── Phase 2.7 — HP Payouts ──────────────────────────────────────────────
    GetPage(
      name: _Paths.hpPayouts,
      page: () => const HpPayoutsView(),
      binding: HpPayoutsBinding(),
    ),

    // ── Financial Module — Write-Offs ────────────────────────────────────────
    GetPage(
      name: Routes.WRITE_OFF_LIST,
      page: () => const WriteOffListView(),
      binding: WriteOffBinding(),
    ),
    GetPage(
      name: Routes.CREATE_WRITE_OFF,
      page: () => const CreateWriteOffView(),
      binding: WriteOffBinding(),
    ),
    GetPage(
      name: Routes.WRITE_OFF_DETAIL,
      page: () => const WriteOffDetailView(),
      binding: WriteOffBinding(),
    ),

    // ── Financial Module — Refunds ───────────────────────────────────────────
    GetPage(
      name: Routes.REFUND_LIST,
      page: () => const RefundListView(),
      binding: RefundBinding(),
    ),
    GetPage(
      name: Routes.CREATE_REFUND,
      page: () => const CreateRefundView(),
      binding: RefundBinding(),
    ),
    GetPage(
      name: Routes.REFUND_DETAIL,
      page: () => const RefundDetailView(),
      binding: RefundBinding(),
    ),

    // ── Financial Module — Credit Notes ──────────────────────────────────────
    GetPage(
      name: Routes.CREDIT_NOTE_LIST,
      page: () => const CreditNoteListView(),
      binding: CreditNoteBinding(),
    ),
    GetPage(
      name: Routes.CREATE_CREDIT_NOTE,
      page: () => const CreateCreditNoteView(),
      binding: CreditNoteBinding(),
    ),
    GetPage(
      name: Routes.CREDIT_NOTE_DETAIL,
      page: () => const CreditNoteDetailView(),
      binding: CreditNoteBinding(),
    ),
    GetPage(
      name: Routes.APPLY_CREDIT_NOTE,
      page: () => const ApplyCreditNoteView(),
      binding: CreditNoteBinding(),
    ),

    // ── Financial Module — Internal Transfers ────────────────────────────────
    GetPage(
      name: Routes.TRANSFER_LIST,
      page: () => const TransferListView(),
      binding: InternalTransferBinding(),
    ),
    GetPage(
      name: Routes.CREATE_TRANSFER,
      page: () => const CreateTransferView(),
      binding: InternalTransferBinding(),
    ),
    GetPage(
      name: Routes.TRANSFER_DETAIL,
      page: () => const TransferDetailView(),
      binding: InternalTransferBinding(),
    ),

    // ── Financial Module — Outstanding ───────────────────────────────────────
    GetPage(
      name: Routes.OUTSTANDING_DASHBOARD,
      page: () => const OutstandingDashboardView(),
      binding: OutstandingBinding(),
    ),
    GetPage(
      name: Routes.CLIENT_OUTSTANDING,
      page: () => const ClientOutstandingDetail(),
      binding: OutstandingBinding(),
    ),
    GetPage(
      name: Routes.BOOKING_OUTSTANDING,
      page: () => const BookingOutstandingDetail(),
      binding: OutstandingBinding(),
    ),

  ];
}
