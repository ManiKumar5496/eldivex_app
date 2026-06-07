part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const AUTH = _Paths.AUTH;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const USERS = _Paths.USERS;
  static const BOOKINGS = _Paths.BOOKINGS;
  static const REGISTER_CG = _Paths.REGISTER_CG;
  static const LOGIN = _Paths.LOGIN;
  static const ROLE = _Paths.ROLE;
  static const initial = _Paths.initial;
  static const MAIN = _Paths.MAIN;
  static const SUPPORT = _Paths.SUPPORT;
  static const AddUser = _Paths.AddUser;
  static const AddMasterRoles = _Paths.AddMasterRoles;
  static const createBookings = _Paths.createBookings;
  static const SETTINGS = _Paths.SETTINGS;
  static const BANNERS = _Paths.BANNERS;
  static const ACCOUNTS = _Paths.ACCOUNTS;
  static const CLIENT_USERS = _Paths.CLIENT_USERS;
  static const addClientDetails = _Paths.addClientDetails;
  static const forgotPassword = _Paths.forgotPassword;
  // ── Phase 2.5 / 2.6 / 2.7 ──────────────────────────────────────────────────
  static const servicesManagement = _Paths.servicesManagement;
  static const branchManagement   = _Paths.branchManagement;
  static const hpPayouts          = _Paths.hpPayouts;
  static const settingsOtpCoupon  = _Paths.settingsOtpCoupon;
  static const appearance         = _Paths.appearance;

  // ── Financial Module ─────────────────────────────────────────────────────────
  static const String WRITE_OFF_LIST       = '/accounts/write-off';
  static const String CREATE_WRITE_OFF     = '/accounts/write-off/create';
  static const String WRITE_OFF_DETAIL     = '/accounts/write-off/detail';
  static const String REFUND_LIST          = '/accounts/refund';
  static const String CREATE_REFUND        = '/accounts/refund/create';
  static const String REFUND_DETAIL        = '/accounts/refund/detail';
  static const String CREDIT_NOTE_LIST     = '/accounts/credit-note';
  static const String CREATE_CREDIT_NOTE   = '/accounts/credit-note/create';
  static const String CREDIT_NOTE_DETAIL   = '/accounts/credit-note/detail';
  static const String APPLY_CREDIT_NOTE    = '/accounts/credit-note/apply';
  static const String TRANSFER_LIST        = '/accounts/transfer';
  static const String CREATE_TRANSFER      = '/accounts/transfer/create';
  static const String TRANSFER_DETAIL      = '/accounts/transfer/detail';
  static const String OUTSTANDING_DASHBOARD = '/accounts/outstanding';
  static const String CLIENT_OUTSTANDING   = '/accounts/outstanding/client';
  static const String BOOKING_OUTSTANDING  = '/accounts/outstanding/booking';
}

abstract class _Paths {
  _Paths._();
  static const AUTH = '/auth';
  static const DASHBOARD = '/dashboard';
  static const USERS = '/users';
  static const BOOKINGS = '/bookings';
  static const REGISTER_CG = '/register-cg';
  static const LOGIN = '/login';
  static const ROLE = '/role';
  static const initial = '/initial';
  static const MAIN = '/main';
  static const SUPPORT = '/support';
  static const AddUser = '/AddUser';
  static const AddMasterRoles = '/AddMasterRoles';
  static const createBookings = '/createBookings';
  static const SETTINGS = '/settings';
  static const BANNERS = '/banners';
  static const ACCOUNTS = '/accounts';
  static const CLIENT_USERS = '/client-users';
  static const addClientDetails = '/addClientDetails';
  static const forgotPassword = '/forgot-password';
  // ── Phase 2.5 / 2.6 / 2.7 ──────────────────────────────────────────────────
  static const servicesManagement = '/services-management';
  static const branchManagement   = '/branch-management';
  static const hpPayouts          = '/hp-payouts';
  static const settingsOtpCoupon  = '/settings/otp-coupon';
  static const appearance         = '/settings/appearance';
}
