import 'package:flutter/material.dart';

class AppColors {
  static const loadingScreenColor = Colors.black;
  static const themePink = Colors.pink;
  static const error = Colors.red;

  static const bg = Color.fromRGBO(38, 41, 41, 1);

  static const whiteText = Colors.white;
  static const blackText = Colors.black;

  static const imageBG = Colors.black;

  static const lineThrough = Colors.red;
  static const warning = Colors.amber;
  static const loadingIndicator = Colors.white;
  static const dontKnow = Colors.orange;
  static const dontKnow2 = Colors.green;

  static const double homePageIconSize = 20;
}

class Responsive {
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width <= 700;
  }
}
