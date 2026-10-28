import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Settings → Appearance. Lets the user switch Light/Dark/System and pick one
/// of five brand palettes. All changes apply app-wide instantly and persist.
class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final ThemeController controller = Get.find<ThemeController>();
    final pad = SizeConfig.isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Appearance',
                    subtitle:
                        'Choose how Eldivex looks. Your selection is saved on this device.',
                    breadcrumbs: const ['Settings', 'Appearance'],
                    onBack: () => Get.back(),
                  ),
                  const SizedBox(height: 24),

                  AppCard(
                    icon: LucideIcons.sunMoon,
                    title: 'Appearance mode',
                    subtitle:
                        'Follow your operating system, or always use light or dark.',
                    child: Obx(
                      () => _ThemeModeSelector(
                        selected: controller.themeMode.value,
                        onSelect: controller.setThemeMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  AppCard(
                    icon: LucideIcons.palette,
                    title: 'Brand color',
                    subtitle:
                        'Used for buttons, links, highlights and active navigation.',
                    child: Obx(
                      () => _PaletteGrid(
                        selectedIndex: controller.paletteIndex.value,
                        onSelect: controller.setPalette,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const AppCard(
                    icon: LucideIcons.eye,
                    title: 'Preview',
                    subtitle: 'Common controls with your current choices.',
                    child: _PreviewCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Light / Dark / System selector ─────────────────────────────────────────

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.selected, required this.onSelect});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.system, 'System', LucideIcons.sunMoon),
      (ThemeMode.light, 'Light', LucideIcons.sun),
      (ThemeMode.dark, 'Dark', LucideIcons.moon),
    ];

    return AppResponsiveGrid(
      minItemWidth: 180,
      maxColumns: 3,
      spacing: 12,
      children: options.map((o) {
        final bool isSelected = o.$1 == selected;
        return _SelectableCard(
          selected: isSelected,
          onTap: () => onSelect(o.$1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 92, child: _ModePreview(mode: o.$1)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Icon(
                      o.$3,
                      size: 18,
                      color: isSelected
                          ? AppColor.cAppPrimaryColor
                          : AppColor.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        o.$2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                    _RadioDot(selected: isSelected),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Card frame that rings in the primary colour when selected.
class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: radius,
        border: Border.all(
          color: selected ? AppColor.cAppPrimaryColor : AppColor.divColor,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColor.primarySoft,
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : const [],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg - 1),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColor.cAppPrimaryColor : Colors.transparent,
        border: Border.all(
          color: selected ? AppColor.cAppPrimaryColor : AppColor.borderStrong,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(LucideIcons.check, size: 12, color: AppColor.buttonTextWhite)
          : null,
    );
  }
}

// ── Mode preview illustration ──────────────────────────────────────────────

/// Fixed colours for the light/dark *illustrations* only. They mirror the
/// light and dark values of the app's surface/border/text tokens so each card
/// depicts its mode regardless of the mode currently active.
class _MockScheme {
  const _MockScheme({
    required this.canvas,
    required this.surface,
    required this.border,
    required this.ink,
    required this.muted,
  });
  final Color canvas;
  final Color surface;
  final Color border;
  final Color ink;
  final Color muted;

  static const light = _MockScheme(
    canvas: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    ink: Color(0xFF101828),
    muted: Color(0xFFD0D5DD),
  );

  static const dark = _MockScheme(
    canvas: Color(0xFF0B0F17),
    surface: Color(0xFF161C27),
    border: Color(0xFF272F3C),
    ink: Color(0xFFF1F4F9),
    muted: Color(0xFF3A4454),
  );
}

class _ModePreview extends StatelessWidget {
  const _ModePreview({required this.mode});
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return const _MiniApp(scheme: _MockScheme.light);
      case ThemeMode.dark:
        return const _MiniApp(scheme: _MockScheme.dark);
      case ThemeMode.system:
        // Left half light, right half dark.
        return LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          return Stack(
            children: [
              const Positioned.fill(child: _MiniApp(scheme: _MockScheme.light)),
              Positioned(
                left: w / 2,
                top: 0,
                bottom: 0,
                right: 0,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerRight,
                    minWidth: w,
                    maxWidth: w,
                    child: const _MiniApp(scheme: _MockScheme.dark),
                  ),
                ),
              ),
            ],
          );
        });
    }
  }
}

/// A tiny sketch of the app shell: sidebar, a card with a title, two text
/// lines and a primary button.
class _MiniApp extends StatelessWidget {
  const _MiniApp({required this.scheme});
  final _MockScheme scheme;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, Color c, {double h = 5}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(3),
          ),
        );

    return Container(
      color: scheme.canvas,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 34,
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(right: BorderSide(color: scheme.border)),
            ),
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(14, AppColor.cAppPrimaryColor, h: 6),
                const SizedBox(height: 8),
                bar(16, scheme.muted),
                const SizedBox(height: 5),
                bar(12, scheme.muted),
                const SizedBox(height: 5),
                bar(16, scheme.muted),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(44, scheme.ink.withValues(alpha: 0.85), h: 6),
                    const SizedBox(height: 6),
                    bar(64, scheme.muted),
                    const SizedBox(height: 4),
                    bar(50, scheme.muted),
                    const Spacer(),
                    bar(28, AppColor.cAppPrimaryColor, h: 9),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Palette swatches ────────────────────────────────────────────────────────

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppResponsiveGrid(
      minItemWidth: 120,
      maxColumns: 5,
      spacing: 12,
      children: List.generate(kPalettes.length, (i) {
        final AppPalette p = kPalettes[i];
        final bool isSelected = i == selectedIndex;
        return _SelectableCard(
          selected: isSelected,
          onTap: () => onSelect(i),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: p.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      // Secondary + accent chips.
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            _chip(p.secondary),
                            const SizedBox(width: 4),
                            _chip(p.accent),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Center(
                          child: Icon(LucideIcons.circleCheck,
                              color: AppColor.pureWhite, size: 22),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ),
                      if (i == 0)
                        Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColor.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _chip(Color c) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColor.pureWhite.withValues(alpha: 0.85),
            width: 1.5,
          ),
        ),
      );
}

// ── Live preview ────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sample heading',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            )),
        const SizedBox(height: 4),
        Text('Secondary descriptive text goes here.',
            style: TextStyle(fontSize: 14, color: AppColor.textTertiary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Primary')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            const AppStatusBadge(label: 'Badge', tone: AppTone.primary),
          ],
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Sample input field',
            ),
          ),
        ),
      ],
    );
  }
}
