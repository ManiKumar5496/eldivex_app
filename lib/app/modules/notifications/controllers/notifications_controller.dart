import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/helper_ui.dart';
import '../models/notification_model.dart';

/// Admin bell feed. Polls the backend every 60s while the dashboard shell is
/// alive and the browser tab is visible; all mutations update local state
/// optimistically (rolled back if the server rejects them) so the panel feels
/// instant even on slow connections.
class NotificationsController extends GetxController {
  final ApiService _api = ApiService();

  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  Timer? _pollTimer;
  JSFunction? _visibilityListener;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(showLoader: true);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        // Hidden tab: skip; the visibility listener catches up on return.
        if (!web.document.hidden) fetchNotifications();
      },
    );
    _visibilityListener = ((web.Event _) {
      if (!web.document.hidden) fetchNotifications();
    }).toJS;
    web.document.addEventListener('visibilitychange', _visibilityListener);
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    if (_visibilityListener != null) {
      web.document.removeEventListener('visibilitychange', _visibilityListener);
    }
    super.onClose();
  }

  Future<void> fetchNotifications({bool showLoader = false}) async {
    // No session (mid-logout) — polling would just churn 401s.
    if (ApiService.activeToken().isEmpty) return;
    if (showLoader) isLoading.value = true;
    try {
      final response = await _api.getRaw(ApiConstants.getNotificationsApi);
      final body = response?.data;
      if (body is Map && body['data'] is List) {
        notifications.value = (body['data'] as List)
            .whereType<Map>()
            .map((m) => AppNotification.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        unreadCount.value =
            int.tryParse(body['unread_count']?.toString() ?? '') ?? 0;
      }
    } catch (e) {
      debugPrint('[notifications] fetch error: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> markRead(AppNotification n) async {
    if (n.read) return;
    n.read = true;
    unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
    notifications.refresh();
    final res = await _api.patchApi(ApiConstants.readNotificationApi(n.id));
    if (!ApiService.isOk(res)) {
      n.read = false;
      unreadCount.value++;
      notifications.refresh();
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    final wasUnread = notifications.where((n) => !n.read).toList();
    final previousCount = unreadCount.value;
    for (final n in notifications) {
      n.read = true;
    }
    unreadCount.value = 0;
    notifications.refresh();
    final res = await _api.patchApi(ApiConstants.readAllNotificationsApi);
    if (!ApiService.isOk(res)) {
      for (final n in wasUnread) {
        n.read = false;
      }
      unreadCount.value = previousCount;
      notifications.refresh();
      HelperUi.showToast(
        message: 'Could not mark notifications as read.',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteOne(AppNotification n) async {
    final index = notifications.indexOf(n);
    if (!n.read) {
      unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
    }
    notifications.remove(n);
    final ok = await _api.delete(ApiConstants.deleteNotificationApi(n.id));
    if (!ok) {
      notifications.insert(
          index.clamp(0, notifications.length).toInt(), n);
      if (!n.read) unreadCount.value++;
      HelperUi.showToast(
        message: 'Could not delete the notification.',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Permanently deletes every notification for the organisation. The UI
  /// must confirm with the user before calling this — there is no undo.
  Future<void> clearAll() async {
    final previous = notifications.toList();
    final previousCount = unreadCount.value;
    notifications.clear();
    unreadCount.value = 0;
    final ok = await _api.delete(ApiConstants.clearNotificationsApi);
    if (ok) {
      HelperUi.showToast(
        message: 'All notifications cleared',
        backgroundColor: Colors.green,
      );
    } else {
      // Deletion failed server-side — restore so the panel doesn't lie.
      notifications.assignAll(previous);
      unreadCount.value = previousCount;
      HelperUi.showToast(
        message: 'Could not clear notifications. Try again.',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Mark read and jump to the module the notification points at.
  void openNotification(AppNotification n) {
    markRead(n);
    final route = (n.data['route'] ?? '').toString();
    switch (route.isNotEmpty ? route : n.type) {
      case 'bookings':
      case 'booking':
      case 'extension_due':
        Get.toNamed(Routes.BOOKINGS);
        break;
      case 'accounts':
      case 'payment_due':
      case 'invoice':
      case 'receipt':
      case 'credit_note':
        Get.toNamed(Routes.ACCOUNTS);
        break;
      case 'support':
        Get.toNamed(Routes.SUPPORT);
        break;
      default:
        break; // subscription / system — no in-app destination yet
    }
  }
}
