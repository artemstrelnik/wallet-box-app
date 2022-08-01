import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class HomeScreenState {
  const HomeScreenState();
}

class ListLoadingState extends HomeScreenState {
  const ListLoadingState();
}

class ListLoadedState extends HomeScreenState {
  const ListLoadedState();
}

class ListErrorState extends HomeScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends HomeScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends HomeScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateTransactionList extends HomeScreenState {
  const UpdateTransactionList({required this.transaction});

  final List<Transaction> transaction;
}

class UpdateBillList extends HomeScreenState {
  const UpdateBillList({required this.bills});

  final List<Bill> bills;
}

class UpdateSchemeState extends HomeScreenState {
  const UpdateSchemeState({
    required this.transaction,
    required this.start,
    required this.end,
    required this.sort,
    required this.index,
  });

  final List<Transaction> transaction;
  final DateTime start;
  final DateTime end;
  final CalendarSortTypes sort;
  final int index;
}

class CloseDialogState extends HomeScreenState {
  const CloseDialogState();
}

class NeedUpdateBillsListState extends HomeScreenState {
  const NeedUpdateBillsListState();
}

class UpdateSelectedBill extends HomeScreenState {
  const UpdateSelectedBill({required this.bill});
  final String bill;
}
