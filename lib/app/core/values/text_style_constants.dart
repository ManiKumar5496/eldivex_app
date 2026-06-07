import 'package:flutter/material.dart';

import 'color_constants.dart';

/// Text styles. Any style that carries a color is exposed as a getter so the
/// color re-evaluates after a theme/palette change (the underlying [AppColor]
/// tokens are theme-aware getters). Color-less styles stay `const`.
class AppTextStyles {
  // Regular
  static TextStyle get regular16W400 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.cPrimarySubHeadingColorGrey,
      );
  static TextStyle get regular24W500 => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColor.fontColorBlack,
      );
  static TextStyle get catT16W400 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.cPrimaryHeadingColor,
        //letterSpacing: -0.31
      );

  static TextStyle get regular16Gre => TextStyle(
        fontSize: 16,
        color: AppColor.fontColorGrey,
      );

  static TextStyle get fieldsHeading16 => TextStyle(
        fontSize: 16,
        color: AppColor.unSelectedMenu,
      );
  static TextStyle get regular14black => TextStyle(
        fontSize: 14,
        color: AppColor.fontColorBlack,
      );
  static TextStyle get regular14white => TextStyle(
        fontSize: 14,
        color: AppColor.buttonTextWhite,
      );
  static TextStyle get regular16white => TextStyle(
        fontSize: 16,
        color: AppColor.buttonTextWhite,
      );

  static TextStyle get heading => TextStyle(
        fontSize: 24,
        color: AppColor.cPrimaryHeadingColor,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get regular12Gre => TextStyle(
        fontSize: 12,
        color: AppColor.fontColorGrey,
      );
  static TextStyle get regular14Gre => TextStyle(
        fontSize: 14,
        color: AppColor.fontColorGrey,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get regular16 => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.cPrimaryHeadingColor,
      );

  static TextStyle get regular16blue => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.cPrimaryButtonColor2,
      );

  // Medium
  static TextStyle get medium14 => TextStyle(
        fontSize: 14,
        color: AppColor.fontColorBlack,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get regularBlu20 => TextStyle(
        fontSize: 20,
        color: AppColor.cPrimaryButtonColor,
        fontWeight: FontWeight.w600,
      );

  static const TextStyle medium16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Semi-Bold
  static const TextStyle semiBold16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle semiBold18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Bold
  static const TextStyle bold20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bold24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
}
