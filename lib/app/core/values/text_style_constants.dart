import 'package:flutter/material.dart';

import 'color_constants.dart';

class AppTextStyles {
  // Regular
  static final TextStyle regular16W400 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColor.cPrimarySubHeadingColorGrey,
  );
  static final TextStyle regular24W500 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColor.fontColorBlack,
  );
  static final TextStyle catT16W400 = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColor.cPrimaryHeadingColor,
      //letterSpacing: -0.31
  );

  static  TextStyle regular16Gre = TextStyle(
    fontSize: 16,
    color:AppColor.fontColorGrey,
  );

  static  TextStyle fieldsHeading16 = TextStyle(
    fontSize: 16,
    color:AppColor.unSelectedMenu,
  );
  static  TextStyle regular14black = TextStyle(
    fontSize: 14,
    color:AppColor.fontColorBlack,
  );
  static  TextStyle regular14white = TextStyle(
    fontSize: 14,
    color:AppColor.whiteColor,
  );static  TextStyle regular16white = TextStyle(
    fontSize: 16,
    color:AppColor.whiteColor,
  );
  
  static  TextStyle heading = TextStyle(
    fontSize: 24,
    color:AppColor.cPrimaryHeadingColor,
    fontWeight: FontWeight.w600
  );


  static  TextStyle regular12Gre = TextStyle(
    fontSize: 12,
    color:AppColor.fontColorGrey,
  );
  static  TextStyle regular14Gre = TextStyle(
    fontSize: 14,
    color:AppColor.fontColorGrey,
    fontWeight: FontWeight.w400,
  );

  static  TextStyle regular16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColor.cPrimaryHeadingColor
  );

  static  TextStyle regular16blue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColor.cPrimaryButtonColor2
  );

  // Medium
  static final TextStyle medium14 = TextStyle(
    fontSize: 14,
    color: AppColor.fontColorBlack,
    fontWeight: FontWeight.w400,

  );

  static final TextStyle regularBlu20 = TextStyle(
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
