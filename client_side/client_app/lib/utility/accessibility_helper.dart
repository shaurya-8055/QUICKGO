import 'package:flutter/material.dart';

class AccessibilityHelper {
  static TextStyle accessibleTextStyle(BuildContext context,
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
  }

  static Color accessibleColor(BuildContext context, Color color,
      {double minContrast = 4.5}) {
    // For demo: just return the color. In production, use a contrast checker.
    return color;
  }
}
