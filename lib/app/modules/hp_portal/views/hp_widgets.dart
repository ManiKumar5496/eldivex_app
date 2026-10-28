import 'package:flutter/material.dart';
import '../../../core/values/color_constants.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Small shared building blocks for the caregiver and client portals so the
/// tabs stay terse. Built on the Eldivex UI kit; the portals are mobile-first,
/// and on wide screens their content sits in a centred [maxContentWidth]
/// column.
class HpUi {
  HpUi._();

  /// Width of the portal content column on tablets / desktop.
  static const double maxContentWidth = 560;

  static String money(dynamic v) {
    final n = double.tryParse('$v') ?? 0;
    return '₹${n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2)}';
  }

  /// Horizontal gutter that centres portal content in a [maxContentWidth]
  /// column on wide screens (16px on phones).
  static double gutter(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w > maxContentWidth + 32 ? (w - maxContentWidth) / 2 : 16;
  }

  /// Scroll-view padding for portal pages. Use a larger [bottom] on pages
  /// with a floating action button.
  static EdgeInsets pagePadding(BuildContext context,
      {double top = 16, double bottom = 24}) {
    final g = gutter(context);
    return EdgeInsets.fromLTRB(g, top, g, bottom);
  }

  static Widget card(
      {required Widget child, EdgeInsets? padding, VoidCallback? onTap}) {
    return AppCard(
      padding: padding ?? const EdgeInsets.all(16),
      onTap: onTap,
      child: child,
    );
  }

  /// Title block at the top of a portal tab.
  static Widget tabHeader(String title, {String? subtitle, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: AppColor.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13.5, color: AppColor.textTertiary)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static Widget sectionTitle(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: AppColor.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// Avatar + "Welcome back," + name row at the top of the portal dashboards.
  static Widget greeting(String overline, String name) {
    return Row(
      children: [
        AppAvatar(name: name, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overline,
                  style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Attendance status → tone (present / half day / leave / absent).
  static AppTone attendanceTone(String? status) {
    switch (status) {
      case 'present':
        return AppTone.success;
      case 'half_day':
        return AppTone.warning;
      case 'leave':
        return AppTone.violet;
      case 'absent':
        return AppTone.danger;
      default:
        return AppTone.neutral;
    }
  }

  /// Badge for an attendance status such as `half_day` → "Half Day".
  static Widget attendanceBadge(String? status, {bool dense = false}) {
    return AppStatusBadge(
      label: humanizeLabel(status ?? '—'),
      tone: attendanceTone(status),
      dense: dense,
    );
  }

  /// Label / value row for detail cards.
  static Widget kv(String k, String v) {
    return AppInfoRow(
      label: k,
      value: v.isEmpty || v == 'NA' ? '—' : v,
      horizontal: true,
      labelWidth: 112,
    );
  }

  /// Detail-page section: a card with a header and [kv] rows.
  static Widget section({
    required String title,
    IconData? icon,
    required List<Widget> children,
  }) {
    return _Section(title: title, icon: icon, children: children);
  }

  static Widget loader() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Full-width primary action that keeps its brand fill (with a white
  /// spinner) while [loading].
  static Widget primaryButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final spinner = SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
          strokeWidth: 2, color: AppColor.buttonTextWhite),
    );
    final style = ElevatedButton.styleFrom(
      disabledBackgroundColor:
          AppColor.cPrimaryButtonColor.withValues(alpha: 0.7),
      disabledForegroundColor: AppColor.buttonTextWhite,
    );
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: icon == null || loading
          ? ElevatedButton(
              onPressed: loading ? null : onTap,
              style: style,
              child: loading ? spinner : Text(label),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              style: style,
              icon: Icon(icon, size: 18),
              label: Text(label),
            ),
    );
  }

  /// Segmented filter control (iOS-style). [onSelect] fires on every tap,
  /// including the already-selected segment.
  static Widget segmented({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return _Segmented(options: options, selected: selected, onSelect: onSelect);
  }

  /// Label above a form field, with the standard vertical rhythm.
  static Widget field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  /// Bottom-sheet frame: drag handle, title row and scrollable content.
  static Widget sheet({
    required String title,
    String? subtitle,
    IconData? icon,
    required double bottomInset,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (icon != null) ...[
                    AppIconTile(icon: icon, size: 36),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: TextStyle(
                                  fontSize: 13, color: AppColor.textTertiary)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  /// Grouped settings-style list (icon tile, label, chevron) in one card.
  static Widget menuGroup(List<(IconData, String, VoidCallback)> items) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(height: 1, indent: 64, color: AppColor.borderSubtle),
              InkWell(
                onTap: items[i].$3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      AppIconTile(icon: items[i].$1, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          items[i].$2,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                      Icon(LucideIcons.chevronRight,
                          size: 20, color: AppColor.textTertiary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Bottom navigation for the portal shells: hairline top border, soft
  /// brand indicator, and centred in [maxContentWidth] on wide screens.
  static Widget bottomNav({
    required int selectedIndex,
    required ValueChanged<int> onDestinationSelected,
    required List<NavigationDestination> destinations,
  }) {
    TextStyle label(bool selected) => TextStyle(
          fontFamily: 'inter_regular',
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppColor.cAppPrimaryColor : AppColor.textTertiary,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              height: 64,
              indicatorColor: AppColor.primarySoft,
              indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith(
                  (s) => label(s.contains(WidgetState.selected))),
              iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
                    size: 22,
                    color: s.contains(WidgetState.selected)
                        ? AppColor.cAppPrimaryColor
                        : AppColor.textTertiary,
                  )),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.icon, required this.children});

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Match AppCard's header inset so labels line up with the title.
    final h = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 20.0;
    return AppCard(
      title: title,
      icon: icon,
      padding: EdgeInsets.fromLTRB(h, 6, h, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColor.neutralSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onSelect(o),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: o == selected
                          ? AppColor.whiteColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: o == selected
                            ? AppColor.divColor
                            : Colors.transparent,
                      ),
                      boxShadow: o == selected ? AppShadows.card : const [],
                    ),
                    child: Text(
                      o[0].toUpperCase() + o.substring(1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: o == selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: o == selected
                            ? AppColor.textPrimary
                            : AppColor.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
