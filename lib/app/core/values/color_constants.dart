import 'package:flutter/material.dart';

class AppColor {
  static Color cAppPrimaryColor = HexColor.fromHex("#106E25");
  static Color cAppBackgroundColor = HexColor.fromHex("#F7F9FC");
  static Color cPrimaryButtonColor = HexColor.fromHex("#2A7BF6");
  static Color cPrimaryButtonColor2 = HexColor.fromHex("#2A7BF6");
  static Color verifyContinue = HexColor.fromHex("#00C896");
  static Color buttonTextWhite = HexColor.fromHex("#FFFFFF");
  static Color bottomBarActiveColor = HexColor.fromHex("#2A7BF6");
  static Color fontColorBlack = HexColor.fromHex("#1A1A1A");
  static Color fontColorGrey = HexColor.fromHex("#6B7280");
  static Color fieldColorGrey = HexColor.fromHex("#F6F8FB");
  static Color lightGreen = HexColor.fromHex("#00C896");
  static Color lightGrey = HexColor.fromHex("#9CA3AF");
  static Color careCColor = HexColor.fromHex("#00A077");
  static Color babyCColor = HexColor.fromHex("#E6672D");
  static Color consultCColor = HexColor.fromHex("#8B5CF6");
  static Color xrayCColor = HexColor.fromHex("#8B5CF6");
  static Color equipCColor = HexColor.fromHex("#E6672D");
  static Color pisioCColor = HexColor.fromHex("#E6672D");
  static Color dioCColor = HexColor.fromHex("#E6672D");
  static Color unSelectedMenu = HexColor.fromHex("#364153");
  static Color divColor = HexColor.fromHex("#E5E7EB");
  static Color cPrimaryHeadingColor = HexColor.fromHex("#101828");
  static Color cPrimarySubHeadingColorGrey = HexColor.fromHex("#4A5565");
  static Color textFieldBorderColor = HexColor.fromHex("#C7C7C7");
  static Color prefixIconColor = HexColor.fromHex("#1C1B1F");
  static Color calenderRed = HexColor.fromHex("#FF6467");

  static const Color blackColor = Color(0xff000000);
  static const Color whiteColor = Color(0xffffffff);
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
