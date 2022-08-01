import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

enum StyleColorEnum {
  primaryBackground,
  primaryBackgroundReverse,
  secondaryBackground,
  secondaryBackgroundReverse,
  primaryText,
  buttonCancel,
  colorIcon,
  cupertinoSwitchThumbColor,
  cupertinoSwitchTrackColor,
  appleButtonColors,
  neitralColor,
  neitralColorReverse,
}

class StyleColorCustom {
  Color setStyleByEnum(
    BuildContext context,
    StyleColorEnum styleCode,
  ) {
    final theme = ThemeModelInheritedNotifier.of(context).theme.brightness;
    switch (styleCode) {
      case StyleColorEnum.primaryBackground:
        return theme == Brightness.light
            ? CustomColors.lightPrimaryBackground
            : CustomColors.darkPrimaryBackground;
      case StyleColorEnum.primaryBackgroundReverse:
        return theme == Brightness.light
            ? CustomColors.darkPrimaryBackground
            : CustomColors.lightPrimaryBackground;
      case StyleColorEnum.secondaryBackground:
        return theme == Brightness.light
            ? CustomColors.lightSecondaryBackground
            : CustomColors.darkSecondaryBackground;
      case StyleColorEnum.secondaryBackgroundReverse:
        return theme != Brightness.light
            ? CustomColors.lightSecondaryBackground
            : CustomColors.darkSecondaryBackground;
      case StyleColorEnum.primaryText:
        return theme == Brightness.light
            ? CustomColors.lightPrimaryText
            : CustomColors.darkPrimaryText;
      case StyleColorEnum.buttonCancel:
        return theme == Brightness.light
            ? CustomColors.lightSecondaryBackground
            : CustomColors.darkSecondaryBackground;
      case StyleColorEnum.colorIcon:
        return theme == Brightness.light
            ? CustomColors.lightSecondaryText
            : CustomColors.darkPrimaryText;
      case StyleColorEnum.cupertinoSwitchThumbColor:
        return theme == Brightness.light
            ? Colors.white
            : CustomColors.darkPrimaryText;
      case StyleColorEnum.cupertinoSwitchTrackColor:
        return theme == Brightness.light
            ? CustomColors.lightPrimaryText
            : CustomColors.darkPrimaryBackground;
      case StyleColorEnum.appleButtonColors:
        return theme == Brightness.light
            ? CustomColors.darkButtonBackground
            : CustomColors.lightButtonBackground;
      case StyleColorEnum.neitralColor:
        return theme == Brightness.light
            ? CustomColors.neutralText
            : CustomColors.darkPrimaryText;
      case StyleColorEnum.neitralColorReverse:
        return theme != Brightness.light
            ? CustomColors.neutralText
            : CustomColors.darkPrimaryText;
      default:
        return const Color(0xFFFF0000);
    }
  }
}
