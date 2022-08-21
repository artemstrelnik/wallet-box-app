import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/transaction_interactor.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';

import 'categories_open_events.dart';
import 'categories_open_states.dart';

class CategoriesOpenBloc
    extends Bloc<CategoriesOpenEvent, CategoriesOpenState> {
  CategoriesOpenBloc({
    required this.category,
  }) : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onCategoryOpenRequested);
    on<RemoveTransaction>(_removeTransactionByIdRequest);
  }

  final OperationCategory category;
  int index = 0;
  DateTime now = DateTime.now();

  void _removeTransactionByIdRequest(
    RemoveTransaction event,
    Emitter<CategoriesOpenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        bool? _isRemoved = await TransactionInteractor().removeIntegration(
          token: token,
          body: <String, String>{
            "userId": uid,
            "transaction": event.transaction!,
          },
        );
        if (_isRemoved != null && _isRemoved) {
          emit(const NeedUpdateBillsListState());
        }
      }
      emit(const CloseDialogState());
      emit(const ListLoadingOpacityHideState());
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onCategoryOpenRequested(
    PageOpenedEvent event,
    Emitter<CategoriesOpenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (event.prev != null && event.prev!) {
        index++;
        emit(const ListLoadingOpacityState());
      }
      if (event.next != null && event.next!) {
        if (index != 0) index--;
        emit(const ListLoadingOpacityState());
      }

      DateTime _start = DateTime(now.year, now.month - index, 1);
      DateTime _end =
          DateTime(now.year, now.month + 1 - index, now.day - now.day);

      emit(SetBaseCategory(category: category));
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        // bill transactions
        final TransactionsResponcePageInfo? _responseTransaction =
            await _abstractAllTransactionsRequest(
          emit,
          token,
          uid,
          _start,
          _end,
        );
        if (_responseTransaction != null) {
          final sorted = List.of(_responseTransaction.page
              .where((element) => element.category?.id == category.id)
              .toList());
          emit(UpdateTransactionList(
            transaction: sorted,
            index: index,
            start: _start,
          ));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  Future<TransactionsResponcePageInfo?> _abstractAllTransactionsRequest(
    Emitter<CategoriesOpenState> emit,
    String token,
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    Map<String, String> body = <String, String>{
      "startDate": start.toIso8601String() + "Z",
      "endDate": end.toIso8601String() + "Z",
    };
    return await TransactionInteractor().abstractAllTransactions(
      token: token,
      body: body,
    );
  }

  // Future<TransactionsResponcePageInfo?> _billTransactionsRequest(
  //   Emitter<CategoriesOpenState> emit,
  //   String token,
  //   String uid,
  //   DateTime start,
  //   DateTime end,
  //   String categoryId,
  // ) async {
  //   Map<String, String> body = <String, String>{
  //     "count": "9999",
  //     "start": start.toIso8601String() + "+00:00",
  //     "end": end.toIso8601String() + "+00:00",
  //     "userId": uid,
  //     "categoryId": categoryId,
  //   };
  //   return await TransactionInteractor().transactionsMonth(
  //     token: token,
  //     body: body,
  //   );
  // }
}
