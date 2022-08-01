import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/transaction_interactor.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import '../../data/enum.dart';
import '../../data/net/interactors/banks_interactor.dart';
import '../../data/net/models/bills_response.dart';
import 'budget_screen_events.dart';
import 'budget_screen_states.dart';

class BudgetScreenBloc extends Bloc<BudgetScreenEvent, BudgetScreenState> {
  BudgetScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onOpenScreen);
  }

  late User _user;
  // final FlutterSecureStorage storage = new FlutterSecureStorage();
  DateTime now = DateTime.now();
  int index = 0;

  void _onOpenScreen(
    PageOpenedEvent event,
    Emitter<BudgetScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
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

        List<Transaction> _listTransactions = <Transaction>[];

        await Future.forEach(BankTypes.values, (BankTypes _bank) async {
          if (!_bank.isTap()) return;

          final List<Bill>? _bankListBills = await BanksInteractor().syncCard(
            token: token,
            body: <String, String>{"userId": uid},
            bank: _bank,
          );

          if (_bankListBills != null && _bankListBills.isNotEmpty) {
            final _b = List.of(_bankListBills.map((e) {
              e.bankName = _bank;
              return e;
            }));
          }
        });

        // bill transactions
        final TransactionsResponcePageInfo? _billTransactions =
            await _abstractAllTransactionsRequest(
          emit,
          token,
          uid,
          _start,
          _end,
        );
        if (_billTransactions != null) {
          _listTransactions.addAll(_billTransactions.page);
        }

        emit(UpdateTransactionListState(
          index: index,
          start: _start,
          transaction: _listTransactions,
        ));
      }
      emit(const ListLoadingOpacityHideState());
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  // void _onWeatherRequested(
  //   PageOpenedEvent event,
  //   Emitter<BudgetScreenState> emit,
  // ) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     if (event.prev != null && event.prev!) {
  //       index++;
  //       emit(const ListLoadingOpacityState());
  //     }
  //     if (event.next != null && event.next!) {
  //       if (index != 0) index--;
  //       emit(const ListLoadingOpacityState());
  //     }

  //     String? token = await prefs.getString("wallet_box_token");
  //     String? uid = await prefs.getString("wallet_box_uid");
  //     DateTime _start = DateTime(now.year, now.month - index, 1);
  //     DateTime _end =
  //         DateTime(now.year, now.month + 1 - index, now.day - now.day);
  //     if (token != null && uid != null) {
  //       final TransactionsResponcePageInfo? _billTransactions =
  //           await _billTransactionsRequest(
  //         emit,
  //         token,
  //         uid,
  //         _start,
  //         _end,
  //       );
  //       if (_billTransactions != null) {
  //         emit(UpdateTransactionListState(
  //           index: index,
  //           start: _start,
  //           transaction: _billTransactions.page,
  //         ));
  //       }
  //     }
  //     if ((event.prev != null && event.prev!) ||
  //         (event.next != null && event.next!)) {
  //       emit(const ListLoadingOpacityHideState());
  //     }

  //     // ignore: nullable_type_in_catch_clause
  //   } on dynamic catch (_) {
  //     rethrow;
  //   }
  // }

  Future<TransactionsResponcePageInfo?> _billTransactionsRequest(
    Emitter<BudgetScreenState> emit,
    String token,
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    Map<String, String> body = <String, String>{
      "count": "9999",
      "start": start.toIso8601String() + "+00:00",
      "end": end.toIso8601String() + "+00:00",
      "userId": uid,
    };
    return await TransactionInteractor().transactionsMonth(
      token: token,
      body: body,
    );
  }

  Future<TransactionsResponcePageInfo?> _abstractAllTransactionsRequest(
    Emitter<BudgetScreenState> emit,
    String token,
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    Map<String, String> body = <String, String>{
      "startDate": start.toIso8601String() + "+00:00",
      "endDate": end.toIso8601String() + "+00:00",
    };
    return await TransactionInteractor().abstractAllTransactions(
      token: token,
      body: body,
    );
  }
}
