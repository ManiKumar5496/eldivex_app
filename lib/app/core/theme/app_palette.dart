import 'package:flutter/material.dart';

import '../values/color_constants.dart';

/// A selectable brand palette. Each palette drives the app-wide primary,
/// secondary and accent colors. Tapping a palette in Settings → Appearance
/// recolors the entire app instantly.
class AppPalette {
  const AppPalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
}

/// The five preset palettes. Index 0 (Blue) is the default brand identity,
/// sourced from the marketing site palette.
final List<AppPalette> kPalettes = [
  AppPalette(
    name: 'Blue',
    primary: HexColor.fromHex('#2563EB'),
    secondary: HexColor.fromHex('#1D4ED8'),
    accent: HexColor.fromHex('#06B6D4'),
  ),
  AppPalette(
    name: 'Teal',
    primary: HexColor.fromHex('#0D9488'),
    secondary: HexColor.fromHex('#0F766E'),
    accent: HexColor.fromHex('#14B8A6'),
  ),
  AppPalette(
    name: 'Violet',
    primary: HexColor.fromHex('#7C3AED'),
    secondary: HexColor.fromHex('#6D28D9'),
    accent: HexColor.fromHex('#A855F7'),
  ),
  AppPalette(
    name: 'Emerald',
    primary: HexColor.fromHex('#059669'),
    secondary: HexColor.fromHex('#047857'),
    accent: HexColor.fromHex('#10B981'),
  ),
  AppPalette(
    name: 'Amber',
    primary: HexColor.fromHex('#D97706'),
    secondary: HexColor.fromHex('#B45309'),
    accent: HexColor.fromHex('#F59E0B'),
  ),
];
