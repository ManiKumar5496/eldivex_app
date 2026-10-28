import 'package:flutter/material.dart';

import '../../core/theme/theme_state.dart';
import '../../core/values/color_constants.dart';
import 'app_tokens.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

bool _isNarrow(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

/// Standard page title block: optional back button and breadcrumbs, title,
/// subtitle and right-aligned actions. Actions wrap under the title on phones.
///
/// ```dart
/// AppPageHeader(
///   title: 'Refunds',
///   subtitle: 'Track and approve client refunds',
///   actions: [ElevatedButton.icon(onPressed: ..., icon: Icon(LucideIcons.plus), label: Text('New refund'))],
/// )
/// ```
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.breadcrumbs = const [],
    this.actions = const [],
    this.onBack,
    this.titleTrailing,
  });

  final String title;
  final String? subtitle;

  /// Shown above the title, e.g. `['Accounts', 'Refunds']`. Use on screens
  /// pushed outside the main shell (detail/create pages); shell pages already
  /// get a breadcrumb in the top bar.
  final List<String> breadcrumbs;
  final List<Widget> actions;

  /// Shows a back button left of the title when set.
  final VoidCallback? onBack;

  /// Inline widget after the title, typically an [AppStatusBadge].
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    final narrow = _isNarrow(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumbs.isNotEmpty) ...[
          _Breadcrumbs(items: breadcrumbs),
          const SizedBox(height: 6),
        ],
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: narrow ? 20 : 24,
                fontWeight: FontWeight.w600,
                letterSpacing: narrow ? -0.3 : -0.4,
                color: AppColor.textPrimary,
                height: 1.2,
              ),
            ),
            if (titleTrailing != null) titleTrailing!,
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14, color: AppColor.textTertiary),
          ),
        ],
      ],
    );

    final leading = onBack == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _BackButton(onTap: onBack!),
          );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) leading,
              Expanded(child: titleBlock),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) leading,
        Expanded(child: titleBlock),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          ),
        ],
      ],
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final last = i == items.length - 1;
      children.add(Text(
        items[i],
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: last ? FontWeight.w600 : FontWeight.w400,
          color: last ? AppColor.textSecondary : AppColor.textTertiary,
        ),
      ));
      if (!last) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(LucideIcons.chevronRight,
              size: 14, color: AppColor.lightGrey),
        ));
      }
    }
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children);
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: AppColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColor.divColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(LucideIcons.arrowLeft,
                size: 18, color: AppColor.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// The standard surface: white card, 1px border, 12px radius, optional
/// header (icon, title, subtitle, actions) separated by a hairline.
///
/// For a table that should fill the remaining page height, put the card in
/// an `Expanded` and pass `expandChild: true` with `padding: EdgeInsets.zero`.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconTone = AppTone.primary,
    this.actions = const [],
    this.padding,
    this.footer,
    this.onTap,
    this.expandChild = false,
    this.headerDivider = true,
    this.color,
    this.gradient,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final AppTone iconTone;

  /// Painted over [color] — used for the tonal wash on stat cards.
  final Gradient? gradient;

  /// Right side of the header row (buttons, filters, a "View all" link).
  final List<Widget> actions;

  /// Body padding. Defaults to 20 (16 on phones). Use `EdgeInsets.zero`
  /// for edge-to-edge tables and lists.
  final EdgeInsetsGeometry? padding;
  final Widget? footer;
  final VoidCallback? onTap;
  final bool expandChild;
  final bool headerDivider;
  final Color? color;

  bool get _hasHeader => title != null || actions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final narrow = _isNarrow(context);
    final pad = padding ?? EdgeInsets.all(narrow ? 16 : 20);
    final hPad = narrow ? 16.0 : 20.0;

    Widget body = Padding(padding: pad, child: child);
    if (expandChild) body = Expanded(child: body);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (_hasHeader) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad - 4, 16),
            child: _CardHeader(
              title: title,
              subtitle: subtitle,
              icon: icon,
              iconTone: iconTone,
              actions: actions,
            ),
          ),
          if (headerDivider) Divider(height: 1, color: AppColor.borderSubtle),
        ],
        body,
        if (footer != null) ...[
          Divider(height: 1, color: AppColor.borderSubtle),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
            child: footer!,
          ),
        ],
      ],
    );

    final radius = BorderRadius.circular(AppRadius.lg);
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColor.whiteColor,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: AppColor.divColor),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, borderRadius: radius, child: content),
            ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    this.title,
    this.subtitle,
    this.icon,
    required this.iconTone,
    required this.actions,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final AppTone iconTone;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: AppColor.textPrimary,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
        ],
      ],
    );

    final lead = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          AppIconTile(icon: icon!, tone: iconTone, size: 34),
          const SizedBox(width: 12),
        ],
        Flexible(child: titleCol),
      ],
    );

    if (actions.isEmpty) {
      return Padding(padding: const EdgeInsets.only(right: 4), child: lead);
    }

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      spacing: 12,
      children: [
        lead,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: actions,
        ),
      ],
    );
  }
}

/// Rounded-square tinted icon, used in card headers, stat cards and lists.
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    this.tone = AppTone.primary,
    this.size = 36,
  });

  final IconData icon;
  final AppTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.5, color: tone.color),
    );
  }
}

/// KPI tile: label, big number, optional icon, trend and footnote.
/// Needs a bounded width — place it in [AppResponsiveGrid] or an `Expanded`.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone = AppTone.primary,
    this.caption,
    this.delta,
    this.deltaPositive,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final AppTone tone;

  /// Small muted line under the value, e.g. "12 this week".
  final String? caption;

  /// Trend chip text, e.g. "+12.4%". Colour follows [deltaPositive].
  final String? delta;
  final bool? deltaPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final deltaTone = deltaPositive == null
        ? AppTone.neutral
        : (deltaPositive! ? AppTone.success : AppTone.danger);

    // Soft wash of the card's tone from the top-right corner, so a KPI row
    // reads as colour-coded rather than a strip of identical white boxes.
    final surface = AppColor.whiteColor;
    final wash = Color.alphaBlend(
        tone.color.withValues(alpha: ThemeState.isDark ? 0.14 : 0.07), surface);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [wash, surface],
        stops: const [0.0, 0.65],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                AppIconTile(icon: icon!, tone: tone, size: 38),
              ],
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: AppColor.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (delta != null || caption != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (delta != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: deltaTone.soft,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deltaPositive != null)
                          Icon(
                            deltaPositive!
                                ? LucideIcons.arrowUp
                                : LucideIcons.arrowDown,
                            size: 12,
                            color: deltaTone.color,
                          ),
                        Text(
                          delta!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deltaTone.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (caption != null)
                  Expanded(
                    child: Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5, color: AppColor.textTertiary),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Lays children out in equal-width columns that reflow with the available
/// width (1 column on phones, up to [maxColumns] on wide screens).
/// Works inside scroll views — it never needs a bounded height.
class AppResponsiveGrid extends StatelessWidget {
  const AppResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 220,
    this.maxColumns = 4,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      var cols = ((width + spacing) / (minItemWidth + spacing)).floor();
      cols = cols.clamp(1, maxColumns).clamp(1, children.length);
      final itemWidth = (width - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final c in children) SizedBox(width: itemWidth, child: c),
        ],
      );
    });
  }
}

/// Status pill: soft tinted background, coloured dot and label.
///
/// `AppStatusBadge.status('PENDING_APPROVAL')` picks the tone and humanises
/// the label automatically; use the default constructor for custom labels.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppTone.neutral,
    this.showDot = true,
    this.icon,
    this.dense = false,
  });

  AppStatusBadge.status(
    String status, {
    super.key,
    this.showDot = true,
    this.icon,
    this.dense = false,
  })  : label = humanizeLabel(status),
        tone = toneForStatus(status);

  final String label;
  final AppTone tone;
  final bool showDot;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = tone.color;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 7 : 9, vertical: dense ? 2 : 3),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 13, color: c),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          // No Flexible: badges sit in Wraps and table cells where the width
          // is unbounded.
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: dense ? 11.5 : 12,
              fontWeight: FontWeight.w600,
              color: c,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
