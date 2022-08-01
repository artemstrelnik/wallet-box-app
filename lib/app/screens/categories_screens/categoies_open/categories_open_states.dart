import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class CategoriesOpenState {
  const CategoriesOpenState();
}

class ListLoadingState extends CategoriesOpenState {
  const ListLoadingState();
}

class ListLoadedState extends CategoriesOpenState {
  const ListLoadedState();
}

class ListErrorState extends CategoriesOpenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends CategoriesOpenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends CategoriesOpenState {
  const ListLoadingOpacityHideState();
}

class SetBaseCategory extends CategoriesOpenState {
  const SetBaseCategory({required this.category});

  final OperationCategory category;
}

class UpdateTransactionList extends CategoriesOpenState {
  const UpdateTransactionList({
    required this.start,
    required this.transaction,
    required this.index,
  });

  final int index;
  final DateTime start;
  final List<Transaction>? transaction;
}

class CloseDialogState extends CategoriesOpenState {
  const CloseDialogState();
}

class NeedUpdateBillsListState extends CategoriesOpenState {
  const NeedUpdateBillsListState();
}
