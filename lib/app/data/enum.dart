import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';

enum OperationType {
  qr,
  hand,
}

enum BankTypes { tinkoff, sber, tochka } //, vtb

extension BankTypesExtension on BankTypes {
  String title() {
    switch (this) {
      case BankTypes.tinkoff:
        return "Тинькофф";
      case BankTypes.sber:
        return "Сбербанк";
      // case BankTypes.vtb:
      //   return "ВТБ";
      case BankTypes.tochka:
        return "Точка";
    }
  }

  Image icon() {
    switch (this) {
      case BankTypes.tinkoff:
        return Image.asset(AssetsPath.tinkoffPng);
      case BankTypes.sber:
        return Image.asset(AssetsPath.sber);
      // case BankTypes.vtb:
      //   return Image.asset(AssetsPath.vtb);
      case BankTypes.tochka:
        return Image.asset(AssetsPath.tochka);
    }
  }

  bool isTap() {
    switch (this) {
      case BankTypes.sber:
      case BankTypes.tinkoff:
      case BankTypes.tochka:
        return true;
      // case BankTypes.vtb:
      //   return false;
    }
  }

  bool isWebView() {
    switch (this) {
      case BankTypes.tochka:
        return true;
      // case BankTypes.vtb:
      case BankTypes.sber:
      case BankTypes.tinkoff:
        return false;
    }
  }
}

enum UserType {
  APPLE,
  GOOGLE,
  SYSTEM,
}

enum LoadingState {
  loading,
  loaded,
  empty,
}

enum ScreenType {
  code,
  password,
}

extension ScreenTypeExtension on ScreenType {
  String helpTitle() {
    switch (this) {
      case ScreenType.code:
        return textString_5;
      case ScreenType.password:
        return "Введите пароль для входа";
    }
  }
}

enum TransactionTypes {
  WITHDRAW,
  DEPOSIT,
  SPEND,
  EARN,
}

extension TransactionTypesExtension on TransactionTypes {
  String title() {
    switch (this) {
      case TransactionTypes.WITHDRAW:
      case TransactionTypes.SPEND:
        return "Расход";
      case TransactionTypes.DEPOSIT:
      case TransactionTypes.EARN:
        return "Доход";
    }
  }

  bool isBank() {
    switch (this) {
      case TransactionTypes.WITHDRAW:
      case TransactionTypes.DEPOSIT:
        return false;
      case TransactionTypes.SPEND:
      case TransactionTypes.EARN:
        return true;
    }
  }

  // String toUri() {
  //   switch (this) {
  //     case TransactionTypes.WITHDRAW:
  //     case TransactionTypes.SPEND:
  //       return "WITHDRAW";
  //     case TransactionTypes.DEPOSIT:
  //     case TransactionTypes.EARN:
  //       return "DEPOSIT";
  //   }
  // }
}

enum CalendarSortTypes {
  rangeDates,
  lastMonth,
  currentMonth,
  lastWeek,
  currentWeek,
  customMonth,
  customWeek,
}

extension CalendarSortTypesExtension on CalendarSortTypes {
  DateTime getStartDate(int index,
      {DateTime? startDay, int? difference, bool? isNext = false}) {
    switch (this) {
      case CalendarSortTypes.currentMonth:
        DateTime now = DateTime.now();
        DateTime start = DateTime(now.year, now.month, 1);
        return start;
      case CalendarSortTypes.lastMonth:
        DateTime now = DateTime.now();
        DateTime start = DateTime(now.year, now.month - 1, 1);
        return start;
      case CalendarSortTypes.currentWeek:
        DateTime d = DateTime.now();
        int weekDay = d.weekday;
        DateTime start = d.subtract(Duration(days: weekDay - 1));
        return start;
      case CalendarSortTypes.lastWeek:
        DateTime d = DateTime.now();
        int weekDay = d.weekday;
        DateTime start = d.subtract(Duration(days: weekDay + 6));
        return start;
      case CalendarSortTypes.customMonth:
        DateTime now = DateTime.now();
        DateTime start = DateTime(now.year, now.month - index, 1);
        return start;
      case CalendarSortTypes.customWeek:
        DateTime d = DateTime.now();
        int weekDay = d.weekday;
        DateTime start = d.subtract(Duration(days: weekDay + (7 * index) - 1));
        return start;
      case CalendarSortTypes.rangeDates:
        // DateTime start = startDay!
        //     .subtract(Duration(days: startDay.day)); // + (difference! * index)
        DateTime start = DateTime(
          startDay!.year,
          startDay.month,
          isNext!
              ? startDay.day + (difference! + 1)
              : startDay.day - (index == 0 ? 0 : difference! + 1),
        );
        return start;
    }
  }

  DateTime getEndDate(int index,
      {DateTime? endDay, int? difference, bool? isNext = false}) {
    switch (this) {
      case CalendarSortTypes.currentMonth:
        DateTime now = DateTime.now();
        DateTime end = DateTime(now.year, now.month + 1, now.day - now.day,
            (now.hour - now.hour) + 23, (now.minute - now.minute) + 59);
        return end;
      case CalendarSortTypes.lastMonth:
        DateTime now = DateTime.now();
        DateTime end = DateTime(now.year, now.month, now.day - now.day,
            (now.hour - now.hour) + 23, (now.minute - now.minute) + 59);
        return end;
      case CalendarSortTypes.currentWeek:
        DateTime now = DateTime.now();
        int weekDay = now.weekday;
        DateTime end = now.subtract(Duration(days: weekDay - 7));
        return end;
      case CalendarSortTypes.lastWeek:
        DateTime now = DateTime.now();
        int weekDay = now.weekday;
        DateTime end = now.subtract(Duration(days: weekDay));
        return end;
      case CalendarSortTypes.customMonth:
        DateTime now = DateTime.now();
        DateTime end = DateTime(
            now.year,
            now.month - (index - 1),
            now.day - now.day,
            (now.hour - now.hour) + 23,
            (now.minute - now.minute) + 59);
        return end;
      case CalendarSortTypes.customWeek:
        DateTime now = DateTime.now();
        int weekDay = now.weekday;
        DateTime end = now.subtract(Duration(days: weekDay + 7 * (index - 1)));
        return end;
      case CalendarSortTypes.rangeDates:
        DateTime end = DateTime(
          endDay!.year,
          endDay.month,
          isNext!
              ? endDay.day + (difference! + 1)
              : endDay.day - (index == 0 ? 0 : difference! + 1),
        );
        return end;
    }
  }

  String? getTitleDate() {
    switch (this) {
      case CalendarSortTypes.currentMonth:
        return "Текущий месяц";
      case CalendarSortTypes.lastMonth:
        return "Прошлый месяц";
      case CalendarSortTypes.currentWeek:
        return "Текущая неделя";
      case CalendarSortTypes.lastWeek:
        return "Прошлая неделя";
      case CalendarSortTypes.customMonth:
      case CalendarSortTypes.customWeek:
      case CalendarSortTypes.customWeek:
        return null;
      case CalendarSortTypes.rangeDates:
        return "Календарь";
    }
  }
}

T enumFromStringOther<T>(Iterable<T> values, String string) {
  return values.firstWhere((e) => describeEnum(e!) == string);
}
