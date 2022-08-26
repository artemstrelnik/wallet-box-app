import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';

import '../../data/net/models/user_auth_model.dart';

abstract class BudgetScreenState {
  const BudgetScreenState();
}

class ListLoadingState extends BudgetScreenState {
  const ListLoadingState();
}

class ListLoadedState extends BudgetScreenState {
  const ListLoadedState();
}

class ListErrorState extends BudgetScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends BudgetScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends BudgetScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateTransactionListState extends BudgetScreenState {
  UpdateTransactionListState({
    required this.start,
    required this.transaction,
    required this.index,
  });

  final int index;
  final DateTime start;
  final List<Transaction> transaction;
}


class UpdateUserState extends BudgetScreenState {
  final User user;

  const UpdateUserState({required this.user});
}