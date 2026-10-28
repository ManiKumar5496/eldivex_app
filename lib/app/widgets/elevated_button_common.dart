import 'package:flutter/material.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';

/// Filled button with a caller-supplied colour. Shape, padding and type come
/// from the app theme's ElevatedButton style.
class ElevatedButtonCommon extends StatefulWidget {
  final Color buttonColor;
  final Function() onTap;
  final String buttonText;
  const ElevatedButtonCommon(
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
          foregroundColor: AppColor.buttonTextWhite,
        ),
        child: Text(widget.buttonText),
      ),
    );
  }
}
