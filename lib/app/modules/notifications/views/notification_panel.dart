import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/notifications_controller.dart';
import '../models/notification_model.dart';

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
            icon: const Icon(Icons.notifications_none_outlined),
            iconSize: SizeConfig.iconMD,
            onPressed: () => _openPanel(context, controller),
          ),
          if (count > 0)
            Positioned(
              right: 6,
              top: 4,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.calenderRed,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.whiteColor, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.buttonTextWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
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
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          border: Border.all(color: AppColor.divColor.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, controller),
            Divider(height: 1, color: AppColor.divColor.withValues(alpha: 0.5)),
            Flexible(child: _buildList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, NotificationsController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SizeConfig.spacingMD,
        SizeConfig.spacingSM,
        SizeConfig.spacingSM,
        SizeConfig.spacingSM,
      ),
      child: Obx(() {
        final unread = controller.unreadCount.value;
        final hasAny = controller.notifications.isNotEmpty;
        return Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: SizeConfig.fontH3,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorBlack,
              ),
            ),
            if (unread > 0) ...[
              SizedBox(width: SizeConfig.spacingXS),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread new',
                  style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    fontWeight: FontWeight.w600,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (unread > 0)
              TextButton(
                onPressed: controller.markAllRead,
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.cPrimaryButtonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'Mark all read',
                  style: TextStyle(fontSize: SizeConfig.fontCaption),
                ),
              ),
            if (hasAny)
              TextButton(
                onPressed: () => _confirmClearAll(context, controller),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.calenderRed,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'Clear all',
                  style: TextStyle(fontSize: SizeConfig.fontCaption),
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
          padding: EdgeInsets.all(SizeConfig.spacingXL),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColor.cPrimaryButtonColor,
            ),
          ),
        );
      }
      if (controller.notifications.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.spacingSection,
            horizontal: SizeConfig.spacingLG,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: AppColor.lightGrey,
              ),
              SizedBox(height: SizeConfig.spacingSM),
              Text(
                "You're all caught up",
                style: TextStyle(
                  fontSize: SizeConfig.fontBody,
                  fontWeight: FontWeight.w600,
                  color: AppColor.fontColorBlack,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'New bookings, reminders and payment alerts will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.fontCaption,
                  color: AppColor.fontColorGrey,
                ),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: controller.notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 64,
          color: AppColor.divColor.withValues(alpha: 0.35),
        ),
        itemBuilder: (_, i) =>
            _NotificationTile(notification: controller.notifications[i]),
      );
    });
  }

  void _confirmClearAll(
      BuildContext context, NotificationsController controller) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        ),
        title: Text(
          'Clear all notifications?',
          style: TextStyle(
            fontSize: SizeConfig.fontH3,
            fontWeight: FontWeight.w600,
            color: AppColor.fontColorBlack,
          ),
        ),
        content: Text(
          'All notifications for your organisation will be permanently '
          'deleted. This cannot be undone.',
          style: TextStyle(
            fontSize: SizeConfig.fontBody,
            color: AppColor.fontColorGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColor.fontColorGrey,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              controller.clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.calenderRed,
              foregroundColor: AppColor.buttonTextWhite,
              elevation: 0,
            ),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  static const _typeIcons = <String, IconData>{
    'booking': Icons.event_available_outlined,
    'extension_due': Icons.hourglass_bottom_outlined,
    'payment_due': Icons.currency_rupee,
    'invoice': Icons.receipt_outlined,
    'receipt': Icons.payments_outlined,
    'credit_note': Icons.receipt_long_outlined,
    'support': Icons.support_agent_outlined,
    'subscription': Icons.workspace_premium_outlined,
    'system': Icons.info_outline,
  };

  static final _typeColors = <String, Color>{
    'booking': const Color(0xFF3B82F6),
    'extension_due': const Color(0xFFF59E0B),
    'payment_due': const Color(0xFFEF4444),
    'invoice': const Color(0xFF6366F1),
    'receipt': const Color(0xFF10B981),
    'credit_note': const Color(0xFF8B5CF6),
    'support': const Color(0xFF0EA5E9),
    'subscription': const Color(0xFF8B5CF6),
    'system': const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final icon = _typeIcons[notification.type] ?? Icons.info_outline;
    final color = _typeColors[notification.type] ?? const Color(0xFF6B7280);

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // close the panel before navigating
        controller.openNotification(notification);
      },
      child: Container(
        color: notification.read
            ? Colors.transparent
            : AppColor.cPrimaryButtonColor.withValues(alpha: 0.04),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingMD,
          vertical: SizeConfig.spacingSM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            SizedBox(width: SizeConfig.spacingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: SizeConfig.fontBodySmall,
                      fontWeight:
                          notification.read ? FontWeight.w500 : FontWeight.w700,
                      color: AppColor.fontColorBlack,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.fontColorGrey,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: SizeConfig.fontCaption,
                      color: AppColor.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: SizeConfig.spacingXS),
            Column(
              children: [
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColor.cPrimaryButtonColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 18),
                InkWell(
                  onTap: () => controller.deleteOne(notification),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.close,
                      size: 15,
                      color: AppColor.lightGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
