import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

class UsageProgressBar extends StatelessWidget {
  const UsageProgressBar({
    super.key,
    required this.label,
    required this.used,
    required this.limit,
    required this.pct,
  });

  final String label;
  final int used;
  final int limit;
  final int pct;

  @override
  Widget build(BuildContext context) {
    final color = pct >= 90
        ? Colors.red
        : pct >= 75
            ? Colors.orange
            : Colors.green;

    final limitLabel = limit == 0 ? '∞' : '$limit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
            Text('$used / $limitLabel',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: limit == 0 ? 0 : (pct / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
