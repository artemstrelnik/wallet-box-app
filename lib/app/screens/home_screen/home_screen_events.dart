import 'package:wallet_box/app/data/enum.dart';

import '../../data/net/models/permission_role_provider.dart';

abstract class HomeScreenEvent {
  const HomeScreenEvent();
}

class PageOpenedEvent extends HomeScreenEvent {
  const PageOpenedEvent({this.user, required this.isExpense});

  final bool isExpense;
  final UserNotifierProvider? user;
}

class UpdateLastOperation extends HomeScreenEvent {
  const UpdateLastOperation();
}

class UpdateBillsListEvent extends HomeScreenEvent {
  const UpdateBillsListEvent();
}

class UpdateSortEvent extends HomeScreenEvent {
  const UpdateSortEvent({
    required this.sort,
    this.prev,
    this.next,
    //this.bill,
    this.billChange = false,
    this.billId,
    required this.isExpense,
  });

  final bool? next;
  final bool? prev;
  final CalendarSortTypes sort;

  //final Bill? bill;
  final String? billId;
  final bool billChange;
  final bool isExpense;
}

class BillRemoveEvent extends HomeScreenEvent {
  const BillRemoveEvent({required this.billId});

  final String? billId;
}

class BankBillRemoveEvent extends HomeScreenEvent {
  const BankBillRemoveEvent({required this.bank});

  final BankTypes? bank;
}

class BankBillUpdateEvent extends HomeScreenEvent {
  const BankBillUpdateEvent({required this.bank});

  final BankTypes? bank;
}

class UpdateRangeDatesEvent extends HomeScreenEvent {
  const UpdateRangeDatesEvent({required this.start, required this.end});

  final DateTime? start;
  final DateTime? end;
}

class RemoveTransaction extends HomeScreenEvent {
  const RemoveTransaction({required this.transaction});

  final String? transaction;
}

class UpdateSchemeTypeEvent extends HomeScreenEvent {
  final bool isExpense;

  const UpdateSchemeTypeEvent({required this.isExpense});
}

class UpdateSpendEarnEvent extends HomeScreenEvent {
  int? plannedSpend;
  int? plannedEarn;

  UpdateSpendEarnEvent({this.plannedSpend, this.plannedEarn});
}

class UpdateBillHiddenEvent extends HomeScreenEvent {
  const UpdateBillHiddenEvent({
    required this.id,
    required this.isHidden,
  });

  final String id;
  final bool isHidden;
}
