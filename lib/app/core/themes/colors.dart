import 'package:flutter/material.dart';

class CustomColors {
  //общий фон
  static const Color lightPrimaryBackground = Color(0xFFEFF3F8);
  //фон карточек
  static const Color lightSecondaryBackground = Color(0xFFFDFDFD);

  //цвет текста в основном для кнопок и для фона не активностей
  static const Color lightPrimaryText = Color(0xFFF2F2F2);
  // цвет текста для шапок и lightSecondaryBackground
  static const Color lightSecondaryText = Color(0xFF555555);
  //общий фон
  static const Color darkPrimaryBackground = Color(0xFF181623);
  //фон карточек
  static const Color darkSecondaryBackground = Color(0xFF212131);
  // цвет текста для шапок и lightSecondaryBackground
  static const Color darkPrimaryText = Color(0xFFE0E0E0);

  // цвет текста для двух тем на общем фоне и подтекста
  static const Color neutralText = Color(0xFF9C9AA8);

  static const Color pink = Color(0xFFF0187B);
  static const Color blue = Color(0xFF6A82FB);

  static const Color darkButtonBackground = Color(0xFF333333);
  static const Color lightButtonBackground = Color(0xFFFDFDFD);

  static const List<Color> listGradienAction = [
    Color(0xFF4776E6),
    Color(0xFF8E54E9)
  ];
  static const List<Color> listGradienDivider = [
    Color(0xFFF0187B),
    Color(0xFF6A82FB)
  ];

  // Тень у кнопок пин-кода
  static const Color dialButtonShadow = Color.fromRGBO(0, 0, 0, .05);
  static const Color dotPinCode = Color.fromRGBO(156, 154, 168, 1);

  static const Color googleButton = Color(0xFF599BFE);
}
