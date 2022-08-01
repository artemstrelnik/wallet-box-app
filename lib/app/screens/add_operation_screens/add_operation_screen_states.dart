import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/ticket_responce_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class AddOperationScreenState {
  const AddOperationScreenState();
}

class ListLoadingState extends AddOperationScreenState {
  const ListLoadingState();
}

class ListLoadedState extends AddOperationScreenState {
  const ListLoadedState();
}

class ListErrorState extends AddOperationScreenState {
  const ListErrorState();
}

class CategoriesListErrorState extends AddOperationScreenState {
  const CategoriesListErrorState();
}

class BillsListErrorState extends AddOperationScreenState {
  const BillsListErrorState();
}

class ListLoadingOpacityState extends AddOperationScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AddOperationScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateCategoriesList extends AddOperationScreenState {
  const UpdateCategoriesList({required this.categories});

  final List<OperationCategory> categories;
}

class UpdateSelectedCategoryState extends AddOperationScreenState {
  const UpdateSelectedCategoryState({required this.category});

  final OperationCategory category;
}

class UpdateSelectedBillState extends AddOperationScreenState {
  const UpdateSelectedBillState({required this.bill});

  final Bill bill;
}

class UpdateBillsList extends AddOperationScreenState {
  const UpdateBillsList({required this.bills});

  final List<Bill> bills;
}

class UpdateSelectedAddressState extends AddOperationScreenState {
  const UpdateSelectedAddressState({required this.address});

  final SearchItem address;
}

class GoBackEndUpdate extends AddOperationScreenState {
  const GoBackEndUpdate();
}

class ToMapPageState extends AddOperationScreenState {
  const ToMapPageState({required this.address});

  final SearchItem? address;
}

class GoBillCreate extends AddOperationScreenState {
  const GoBillCreate();
}

class GoCatCreate extends AddOperationScreenState {
  const GoCatCreate();
}

class TicketDataOutputState extends AddOperationScreenState {
  const TicketDataOutputState({required this.data});

  final TicketResponceModel data;
}

class UpdatePrice extends AddOperationScreenState {
  const UpdatePrice({required this.sum});

  final double sum;
}
