import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';

/// Settings → Appearance. Lets the user switch Light/Dark/System and pick one
/// of five brand palettes. All changes apply app-wide instantly and persist.
class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final ThemeController controller = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              padding: SizeConfig.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: AppTextStyles.heading),
                  SizedBox(height: SizeConfig.spacingXS),
                  Text(
                    'Choose how Eldivex looks. Your selection is saved on this device.',
                    style: AppTextStyles.regular14Gre,
                  ),
                  SizedBox(height: SizeConfig.spacingXL),

                  _SectionCard(
                    title: 'Appearance mode',
                    child: Obx(
                      () => _ThemeModeSelector(
                        selected: controller.themeMode.value,
                        onSelect: controller.setThemeMode,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.spacingLG),

                  _SectionCard(
                    title: 'Brand color',
                    child: Obx(
                      () => _PaletteGrid(
                        selectedIndex: controller.paletteIndex.value,
                        onSelect: controller.setPalette,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.spacingLG),

                  _SectionCard(
                    title: 'Preview',
                    child: const _PreviewCard(),
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

// ── Section wrapper ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.spacingLG),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.regular16.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: SizeConfig.spacingMD),
          child,
        ],
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
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
    ];

    return Wrap(
      spacing: SizeConfig.spacingSM,
      runSpacing: SizeConfig.spacingSM,
      children: options.map((o) {
        final bool isSelected = o.$1 == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
          onTap: () => onSelect(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.12)
                  : AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
              border: Border.all(
                color: isSelected
                    ? AppColor.cPrimaryButtonColor
                    : AppColor.divColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  o.$3,
                  size: 18,
                  color: isSelected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.fontColorGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  o.$2,
                  style: AppTextStyles.regular14black.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColor.cPrimaryButtonColor
                        : AppColor.fontColorBlack,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
    return Wrap(
      spacing: SizeConfig.spacingMD,
      runSpacing: SizeConfig.spacingMD,
      children: List.generate(kPalettes.length, (i) {
        final AppPalette p = kPalettes[i];
        final bool isSelected = i == selectedIndex;
        return InkWell(
          borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 96,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.fieldColorGrey,
              borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
              border: Border.all(
                color: isSelected ? p.primary : AppColor.divColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [p.primary, p.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: AppColor.buttonTextWhite, size: 22),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: AppTextStyles.regular12Gre.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? p.primary : AppColor.fontColorGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
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
            style:
                AppTextStyles.regular16.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Secondary descriptive text goes here.',
            style: AppTextStyles.regular14Gre),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Primary')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Badge',
                  style: TextStyle(
                      color: AppColor.cPrimaryButtonColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Sample input field',
          ),
        ),
      ],
    );
  }
}
