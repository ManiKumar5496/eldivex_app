import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AccountStatusBadge extends StatelessWidget {
  const AccountStatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final map = _map(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: map.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? '—' : status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: map.$1),
      ),
    );
  }

  (Color, IconData) _map(String s) => switch (s) {
        'active'    => (Colors.green,  LucideIcons.circleCheck),
        'trial'     => (Colors.orange, LucideIcons.hourglass),
        'suspended' => (Colors.red,    LucideIcons.circlePause),
        'expired'   => (AppColor.fontColorGrey,   LucideIcons.timerOff),
        'cancelled' => (Colors.red,    LucideIcons.circleX),
        _           => (AppColor.fontColorGrey,   LucideIcons.circleHelp),
      };
}
