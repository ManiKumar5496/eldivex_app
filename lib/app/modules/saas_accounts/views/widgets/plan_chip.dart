import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

class SaasPlanChip extends StatelessWidget {
  const SaasPlanChip(this.plan, {super.key});
  final String plan;

  @override
  Widget build(BuildContext context) {
    final color = switch (plan) {
      'Enterprise' => Colors.purple,
      'Growth'     => Colors.blue,
      _            => AppColor.fontColorGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        plan.isEmpty ? '—' : plan,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
