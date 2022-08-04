import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet_box/app/core/themes/colors.dart';

class CustomThemes {
  CustomThemes({required this.context});
  BuildContext? context;
  static ThemeData lightTheme(context) => ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context!).textTheme,
        ),
        scaffoldBackgroundColor: CustomColors.lightPrimaryBackground,
        primaryColor: CustomColors.lightPrimaryBackground,
        backgroundColor: CustomColors.lightPrimaryBackground,
        brightness: Brightness.light,
      );

  static ThemeData darkTheme(context) => ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context!).textTheme,
        ),
        scaffoldBackgroundColor: CustomColors.darkPrimaryBackground,
        backgroundColor: CustomColors.darkSecondaryBackground,
        primaryColor: CustomColors.darkSecondaryBackground,
        primaryColorLight: CustomColors.darkSecondaryBackground,
        brightness: Brightness.dark,
      );
}
