import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

class ElevatedButtonCommon extends StatefulWidget {
  Color buttonColor;
  Function() onTap;
  String buttonText;
  ElevatedButtonCommon(
      {super.key,
        required this.buttonColor,
        required this.onTap,
        required this.buttonText});

  @override
  State<ElevatedButtonCommon> createState() => _ElevatedButtonCommonState();
}

class _ElevatedButtonCommonState extends State<ElevatedButtonCommon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor,
            // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "poppins_regular",
            )),
        child: Text(
          widget.buttonText,
          style: TextStyle(
            color: AppColor.buttonTextWhite,
            fontWeight: FontWeight.bold,
            fontFamily: "poppins_regular",
          ),
        ),
      ),
    );
  }
}
