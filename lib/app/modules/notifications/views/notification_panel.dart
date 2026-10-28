import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Bell icon for the dashboard top bar: unread badge + anchored dropdown
/// panel. Self-registers its controller like the other shell widgets.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    // Self-register like the other shell widgets — disposed on logout
    // (Get.offAllNamed), which also cancels the poll timer.
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }
    final controller = Get.find<NotificationsController>();

    return Obx(() {
      final count = controller.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'Notifications',
            icon: Icon(count > 0
                ? LucideIcons.bell
                : LucideIcons.bell),
            iconSize: 20,
            onPressed: () => _openPanel(context, controller),
          ),
          if (count > 0)
            Positioned(
              right: 5,
              top: 5,
              child: IgnorePointer(
                child: Container(
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4.5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.danger,
                    borderRadius: BorderRadius.circular(9),
                    // Ring in the top bar's surface colour so the badge
                    // stays legible over the bell in both themes.
                    border: Border.all(color: AppColor.whiteColor, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 17),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.pureWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  void _openPanel(BuildContext context, NotificationsController controller) {
    controller.fetchNotifications();
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => Stack(
        children: [
          Positioned(
            top: 64,
            right: SizeConfig.isMobile ? 8 : 16,
            left: SizeConfig.isMobile ? 8 : null,
            child: const _NotificationPanel(),
          ),
        ],
      ),
    );
  }
}

/// Inbox-style popover: header with unread count and bulk actions, then the
/// feed grouped by day, unread rows marked with a dot.
class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: SizeConfig.isMobile ? double.infinity : 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColor.divColor),
          boxShadow: AppShadows.overlay,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, controller),
            Divider(height: 1, color: AppColor.borderSubtle),
            Flexible(child: _buildList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, NotificationsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Obx(() {
        final unread = controller.unreadCount.value;
        final hasAny = controller.notifications.isNotEmpty;
        return Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: AppColor.textPrimary,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              AppStatusBadge(
                label: '$unread new',
                tone: AppTone.primary,
                showDot: false,
                dense: true,
              ),
            ],
            const Spacer(),
            if (unread > 0)
              TextButton.icon(
                onPressed: controller.markAllRead,
                style: AppButtonStyles.compact,
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                label: const Text('Mark all read'),
              ),
            if (hasAny)
              IconButton(
                tooltip: 'Clear all',
                onPressed: () => _confirmClearAll(context, controller),
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColor.textTertiary,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildList(NotificationsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.cPrimaryButtonColor,
              ),
            ),
          ),
        );
      }
      if (controller.notifications.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.bell,
          title: "You're all caught up",
          message:
              'New bookings, reminders and payment alerts will appear here.',
          compact: true,
        );
      }

      // Flatten into day groups: a heading row, then that day's items.
      final entries = <Object>[];
      String? lastGroup;
      for (final n in controller.notifications) {
        final group = _groupLabel(n.createdAt);
        if (group != lastGroup) {
          entries.add(group);
          lastGroup = group;
        }
        entries.add(n);
      }

      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 6),
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final e = entries[i];
          if (e is String) return _GroupHeading(label: e, first: i == 0);
          return _NotificationTile(notification: e as AppNotification);
        },
      );
    });
  }

  /// "Today" / "Yesterday" / "This week" / "Earlier".
  static String _groupLabel(DateTime? at) {
    if (at == null) return 'Earlier';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This week';
    return 'Earlier';
  }

  Future<void> _confirmClearAll(
      BuildContext context, NotificationsController controller) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Clear all notifications?',
      message: 'All notifications for your organisation will be permanently '
          'deleted. This cannot be undone.',
      confirmLabel: 'Delete permanently',
      tone: AppTone.danger,
      icon: LucideIcons.trash2,
    );
    if (confirmed) controller.clearAll();
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.label, required this.first});
  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, first ? 12 : 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColor.textTertiary,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  static const _typeIcons = <String, IconData>{
    'booking': LucideIcons.calendarCheck,
    'extension_due': LucideIcons.hourglass,
    'payment_due': LucideIcons.indianRupee,
    'invoice': LucideIcons.receipt,
    'receipt': LucideIcons.banknote,
    'credit_note': LucideIcons.receiptText,
    'support': LucideIcons.headset,
    'subscription': LucideIcons.award,
    'system': LucideIcons.info,
  };

  static const _typeTones = <String, AppTone>{
    'booking': AppTone.primary,
    'extension_due': AppTone.warning,
    'payment_due': AppTone.danger,
    'invoice': AppTone.info,
    'receipt': AppTone.success,
    'credit_note': AppTone.violet,
    'support': AppTone.info,
    'subscription': AppTone.violet,
    'system': AppTone.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final icon = _typeIcons[notification.type] ?? LucideIcons.info;
    final tone = _typeTones[notification.type] ?? AppTone.neutral;
    final unread = !notification.read;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // close the panel before navigating
        controller.openNotification(notification);
      },
      hoverColor: AppColor.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot gutter.
            SizedBox(
              width: 10,
              height: 32,
              child: unread
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColor.cPrimaryButtonColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            AppIconTile(icon: icon, tone: tone, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.35,
                            fontWeight:
                                unread ? FontWeight.w600 : FontWeight.w400,
                            color: unread
                                ? AppColor.textPrimary
                                : AppColor.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 2),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => controller.deleteOne(notification),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              iconSize: 16,
              icon: Icon(LucideIcons.x, color: AppColor.lightGrey),
            ),
          ],
        ),
      ),
    );
  }
}
