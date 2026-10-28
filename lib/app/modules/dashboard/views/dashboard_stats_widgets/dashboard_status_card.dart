import 'package:flutter/material.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';

/// Dashboard KPI tile. A thin adapter over [AppStatCard] so every metric on
/// the page shares the kit's stat-card anatomy (label, value, icon tile,
/// trend chip, caption). Needs a bounded width — place it in an
/// [AppResponsiveGrid].
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;

  /// Trend chip text (e.g. "+12.5%"). When null the chip is hidden.
  final String? percentage;

  /// Optional secondary line under the value (e.g. outstanding amount).
  final String? subtitle;

  final IconData icon;

  /// Icon tile tone.
  final AppTone tone;
  final bool isPositive;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    this.percentage,
    this.subtitle,
    required this.icon,
    this.tone = AppTone.primary,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppStatCard(
      label: title,
      value: value,
      icon: icon,
      tone: tone,
      delta: percentage,
      deltaPositive: percentage == null ? null : isPositive,
      caption: subtitle ?? (percentage != null ? 'vs prev. period' : null),
      onTap: onTap,
    );
  }
}
