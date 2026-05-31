import 'package:flutter/material.dart';

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
        'active'    => (Colors.green,  Icons.check_circle_outline),
        'trial'     => (Colors.orange, Icons.hourglass_top_outlined),
        'suspended' => (Colors.red,    Icons.pause_circle_outline),
        'expired'   => (Colors.grey,   Icons.timer_off_outlined),
        'cancelled' => (Colors.red,    Icons.cancel_outlined),
        _           => (Colors.grey,   Icons.help_outline),
      };
}
