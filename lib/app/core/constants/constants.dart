import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const logoLight = 'lib/app/assets/images/logo_light.png';
const logoDark = 'lib/app/assets/images/logo_dark.png';
const ic = 'lib/app/assets/images/icon.png';
const menuOne = 'lib/app/assets/images/menu_one.svg';
const menuTwo = 'lib/app/assets/images/menu_two.svg';
const menuThree = 'lib/app/assets/images/menu_three.svg';
const menuFour = 'lib/app/assets/images/menu_four.svg';
const card = 'lib/app/assets/images/card.svg';

const String baseUrl = "https://api.wallet-box.ru/";
const String baseUrlDomain = "https://wallet-box-app.ru/";

class AssetsPath {
  static const String _icons = 'lib/app/assets/icons/';
  static const String _images = 'lib/app/assets/images/';

  //общий фон
  static const String delete = _icons + 'delete.svg';
  static const String plusBill = _icons + 'plusBill.svg';
  static const String search = _icons + 'search.svg';

  static const String apple = _icons + 'apple.svg';
  static const String google = _icons + 'google.svg';

  static const String barcode = _icons + 'barcode.svg';
  static const String qr = _icons + 'qr.svg';
  static const String map = _icons + 'map.svg';
  static const String target = _icons + 'target.svg';

  static const String slide_1 = _images + 'slide-1.svg';
  static const String slide_1_png = _images + 'slide-1.png';

  static const String tinkoffPng = _images + 'tinkoff.png';
  static const String tinkoff = _icons + 'tinkoff.svg';
  static const String arrowRigth = _icons + 'arrowRigth.svg';
  static const String security = _icons + 'security.svg';
  static const String calendar = _icons + 'calendar.svg';
  static const String sber = _images + 'sber.png';
  static const String vtb = _images + 'vtb.png';
  static const String tochka = _images + 'tochka.jpeg';

  static const String security_shield = _icons + 'security_shield.svg';
}

abstract class ConstContext {
  ConstContext({required this.context});
  BuildContext? context;
  static bool lightMode(context) =>
      MediaQuery.of(context).platformBrightness == Brightness.light;
  // static FocusNode focusNode = FocusNode();
}

void onPressed() {}
