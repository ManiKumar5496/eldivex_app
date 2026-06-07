import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_palette.dart';
import 'theme_state.dart';

/// Single source of truth for the app's appearance (theme mode + brand
/// palette). Registered `permanent` in main.dart. Persists choices to
/// [GetStorage] and keeps [ThemeState] in sync so the theme-aware [AppColor]
/// getters reflect the current selection on every rebuild.
class ThemeController extends GetxController with WidgetsBindingObserver {
  static const _kThemeModeKey = 'app_theme_mode';
  static const _kPaletteKey = 'app_palette';

  final GetStorage _box = GetStorage();

  /// 0 = system, 1 = light, 2 = dark (stored as int for simple persistence).
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  /// Index into [kPalettes].
  final RxInt paletteIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final storedMode = _box.read(_kThemeModeKey);
    if (storedMode is int && storedMode >= 0 && storedMode <= 2) {
      themeMode.value = ThemeMode.values[storedMode];
    }

    final storedPalette = _box.read(_kPaletteKey);
    if (storedPalette is int &&
        storedPalette >= 0 &&
        storedPalette < kPalettes.length) {
      paletteIndex.value = storedPalette;
    }

    _syncState();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Re-resolve [ThemeState] from the current selection.
  void _syncState() {
    ThemeState.palette = kPalettes[paletteIndex.value];
    ThemeState.isDark = _resolveIsDark();
  }

  bool _resolveIsDark() {
    switch (themeMode.value) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  AppPalette get palette => kPalettes[paletteIndex.value];
  bool get isDark => ThemeState.isDark;

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _box.write(_kThemeModeKey, mode.index);
    _syncState();
    _rebuildApp();
  }

  void setPalette(int index) {
    if (index < 0 || index >= kPalettes.length) return;
    paletteIndex.value = index;
    _box.write(_kPaletteKey, index);
    _syncState();
    _rebuildApp();
  }

  /// Force every widget to rebuild so the static, theme-aware [AppColor]
  /// getters re-resolve app-wide (screens that read AppColor directly don't
  /// listen to the Theme InheritedWidget, so a plain theme change won't
  /// repaint them on its own).
  void _rebuildApp() {
    Get.forceAppUpdate();
  }

  /// React to OS light/dark changes while in system mode.
  @override
  void didChangePlatformBrightness() {
    if (themeMode.value == ThemeMode.system) {
      final wasDark = ThemeState.isDark;
      _syncState();
      if (wasDark != ThemeState.isDark) {
        // Nudge the reactive MaterialApp to rebuild with the new brightness.
        themeMode.refresh();
      }
    }
  }
}
