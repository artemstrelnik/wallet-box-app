import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

enum StyleTextEnum {
  neutralText,
  neutralTextSmall,
  titleCard,
  bodyCard,
  textButton,
  textButtonNoBackground,
  textButtonCancel,
  header,
  appBarTitle,
  white,
  pink,
  indicator,
  dialogCalendarTitle,
  dialogCalendarTitleLigth,
  appleButtonStyle,
  appleButtonStyleReverse,
  bankTitle,
  security,
  afterInput,
  afterInputText,
}

class StyleTextCustom {
  TextStyle setStyleByEnum(
    BuildContext context,
    StyleTextEnum styleCode,
  ) {
    final theme = ThemeModelInheritedNotifier.of(context).theme.brightness;
    switch (styleCode) {
      case StyleTextEnum.dialogCalendarTitleLigth:
        return GoogleFonts.montserrat(
          fontSize: 17,
          height: 22 / 17,
          fontWeight: FontWeight.w400,
          color: CustomColors.neutralText,
        );
      case StyleTextEnum.dialogCalendarTitle:
        return GoogleFonts.montserrat(
          fontSize: 17,
          height: 22 / 17,
          fontWeight: FontWeight.w600,
          color: CustomColors.neutralText,
        );
      case StyleTextEnum.neutralText:
        return GoogleFonts.montserrat(
          fontSize: 14,
          height: 17 / 14,
          fontWeight: FontWeight.w400,
          color: CustomColors.neutralText,
        );
      case StyleTextEnum.neutralTextSmall:
        return GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: CustomColors.neutralText,
        );
      case StyleTextEnum.header:
        return GoogleFonts.montserrat(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.titleCard:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.indicator:
        return GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.bodyCard:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.textButton:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme == Brightness.light
                ? CustomColors.lightPrimaryText
                : CustomColors.lightPrimaryText);
      case StyleTextEnum.textButtonCancel:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.appleButtonStyle:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.lightPrimaryText);
      case StyleTextEnum.appleButtonStyleReverse:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme == Brightness.dark
                ? CustomColors.lightSecondaryText
                : CustomColors.lightPrimaryText);
      case StyleTextEnum.textButtonNoBackground:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme == Brightness.light
                ? CustomColors.neutralText
                : CustomColors.neutralText);
      case StyleTextEnum.appBarTitle:
        return GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.pink:
        return GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CustomColors.pink);
      case StyleTextEnum.white:
        return GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light ? Colors.white : Colors.white);
      case StyleTextEnum.bankTitle:
        return GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.security:
        return GoogleFonts.montserrat(
            fontSize: 11,
            height: 13 / 11,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light
                ? CustomColors.lightSecondaryText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.afterInput:
        return GoogleFonts.montserrat(
            fontSize: 14,
            height: 17 / 14,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light
                ? CustomColors.neutralText
                : CustomColors.darkPrimaryText);
      case StyleTextEnum.afterInputText:
        return GoogleFonts.montserrat(
            fontSize: 11,
            height: 13 / 11,
            fontWeight: FontWeight.normal,
            color: theme == Brightness.light
                ? CustomColors.neutralText
                : CustomColors.darkPrimaryText);

      default:
        return const TextStyle(
          fontSize: 14.0,
          color: Colors.red,
          decoration: TextDecoration.none,
        );
    }
  }
}
