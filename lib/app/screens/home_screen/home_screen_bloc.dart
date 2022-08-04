import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/interactors/banks_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/bill_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/transaction_interactor.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

import 'home_screen_events.dart';
import 'home_screen_states.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<UpdateLastOperation>(_onUpdateLastOperation);
    on<UpdateBillsListEvent>(_onUpdateBillsList);
    on<UpdateSortEvent>(_updateSortRequest);
    on<BillRemoveEvent>(_removeBillByIdRequest);
    on<BankBillRemoveEvent>(_removeBankBill);
    on<BankBillUpdateEvent>(_updateBankBill);
    on<UpdateRangeDatesEvent>(_updateRangeDates);
    on<RemoveTransaction>(_removeTransactionByIdRequest);
  }

  late User _user;
  // final FlutterSecureStorage storage = new FlutterSecureStorage();
  CalendarSortTypes _sortType = CalendarSortTypes.currentMonth;

  late DateTime _start;
  late DateTime _end;
  int index = 0;
  // Bill? _selectedBill;

  void _removeTransactionByIdRequest(
    RemoveTransaction event,
    Emitter<HomeScreenState> emit,
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

  void _updateRangeDates(
    UpdateRangeDatesEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      _start = event.start!;
      _end = event.end!;
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _updateBankBill(
    BankBillUpdateEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final bool? isSync = await BanksInteractor().sync(
          token: token,
          body: <String, String>{
            "userId": uid,
          },
          bank: event.bank,
        );
        if (isSync != null && isSync) {
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

  void _removeBankBill(
    BankBillRemoveEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final bool? _isRemoved = await BanksInteractor().removeIntegration(
          token: token,
          body: <String, String>{"userId": uid},
          bank: event.bank,
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

  void _removeBillByIdRequest(
    BillRemoveEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final bool? _isRemoved = await BillInteractor().removeById(
            token: token, body: <String, String>{"billId": event.billId!});
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

  void _updateSortRequest(
    UpdateSortEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sortType = event.sort;
      switch (event.sort) {
        case CalendarSortTypes.currentMonth:
        case CalendarSortTypes.currentWeek:
          index = 0;
          break;
        case CalendarSortTypes.lastMonth:
        case CalendarSortTypes.lastWeek:
          index = 1;
          break;
        case CalendarSortTypes.customMonth:
          if (event.prev != null && event.prev!) {
            index++;
          } else {
            index--;
          }
          if (index == 0) {
            _sortType = CalendarSortTypes.currentMonth;
          } else if (index == 1) {
            _sortType = CalendarSortTypes.lastMonth;
          }
          break;
        case CalendarSortTypes.customWeek:
          if (event.prev != null && event.prev!) {
            index++;
          } else {
            index--;
          }
          if (index == 0) {
            _sortType = CalendarSortTypes.currentWeek;
          } else if (index == 1) {
            _sortType = CalendarSortTypes.lastWeek;
          }
          break;
        case CalendarSortTypes.rangeDates:
          if (event.prev != null && event.prev!) {
            index++;
          } else if (event.next != null && event.next!) {
            index--;
          }
          break;
      }

      if (event.billId != null) {
        emit(UpdateSelectedBill(bill: event.billId!));
        // _selectedBill = event.bill;
      } else if (event.billChange) {
        emit(UpdateSelectedBill(bill: ""));
        // _selectedBill = null;
      }

      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        int _difference = _end.difference(_start).inDays;
        _start = _sortType.getStartDate(
          index,
          startDay: _start,
          difference: _difference,
          isNext: event.next ?? false,
        );
        _end = _sortType.getEndDate(
          index,
          endDay: _end,
          difference: _difference,
          isNext: event.next ?? false,
        );

        if (_start.isAfter(DateTime.now())) return;

        List<Bill> _listBills = <Bill>[];

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

            _listBills = [..._b, ..._listBills];
          }
        });

        final List<Bill>? _responseListBills = await BillInteractor()
            .fullList(token: token, body: <String, String>{});

        if (_responseListBills != null && _responseListBills.isNotEmpty) {
          _listBills.addAll(_responseListBills);
        }

        emit(UpdateBillList(bills: _listBills));

        // all bill transactions
        final TransactionsResponcePageInfo? _allBillTransactions =
            await _abstractAllTransactionsRequest(
          emit,
          token,
          uid,
          _start,
          _end,
        );
        if (_allBillTransactions != null) {
          _listTransactions.addAll(_allBillTransactions.page);
        }
        // bill transactions
        // final TransactionsResponcePageInfo? _billTransactions =
        //     await _billTransactionsRequest(
        //   emit,
        //   token,
        //   uid,
        //   _start,
        //   _end,
        // );
        // if (_billTransactions != null) {
        //   _listTransactions.addAll(_billTransactions.page);
        // }

        emit(UpdateSchemeState(
          start: _start,
          end: _end,
          transaction: _listTransactions,
          sort: _sortType,
          index: index,
        ));
        emit(UpdateTransactionList(transaction: _listTransactions));

        if ((event.prev != null && event.prev!) ||
            (event.next != null && event.next!) ||
            event.billId != null ||
            event.billChange) {
        } else {
          emit(const CloseDialogState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUpdateBillsList(
    UpdateBillsListEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final List<Bill>? _responseListBills = await BillInteractor()
            .fullList(token: token, body: <String, String>{});
        if (_responseListBills != null) {
          emit(UpdateBillList(bills: _responseListBills));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUpdateLastOperation(
    UpdateLastOperation event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final TransactionsResponcePageInfo? _responseTransaction =
            await TransactionInteractor()
                .fullList(token: token, body: <String, String>{"uid": uid});
        if (_responseTransaction != null &&
            _responseTransaction.page.isNotEmpty) {
          emit(UpdateTransactionList(transaction: _responseTransaction.page));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      if (event.user != null && event.user?.user != null) {
        _user = event.user!.user!;
      }
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        _start = _sortType.getStartDate(index);
        _end = _sortType.getEndDate(index);

        // final List<Course>? _coursesList =
        //     await CurrenciesInteractor().course();

        List<Bill> _listBills = <Bill>[];

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

            _listBills = [..._b, ..._listBills];
          }
        });

        final List<Bill>? _responseListBills = await BillInteractor()
            .fullList(token: token, body: <String, String>{});

        if (_responseListBills != null && _responseListBills.isNotEmpty) {
          _listBills.addAll(_responseListBills);
        }

        // Future.forEach(_listBills, (Bill e) {
        //   if (_user.walletType != "RUB" &&
        //       _coursesList != null &&
        //       _coursesList.isNotEmpty) {
        //     final Course _course =
        //         _coursesList.where((e) => e.wallet == "RUB").first;
        //     e.balance!.amount =
        //         int.parse((e.balance!.amount / _course.value!).toString());
        //   }
        // });

        emit(UpdateBillList(bills: _listBills));

        // all bill transactions
        final TransactionsResponcePageInfo? _allBillTransactions =
            await _abstractAllTransactionsRequest(
          emit,
          token,
          uid,
          _start,
          _end,
        );
        if (_allBillTransactions != null) {
          _listTransactions.addAll(_allBillTransactions.page);
        }

        // Future.forEach(_listTransactions, (Transaction e) {
        //   if (_user.walletType != "RUB" &&
        //       _coursesList != null &&
        //       _coursesList.isNotEmpty) {
        //     final Course _course =
        //         _coursesList.where((e) => e.wallet == "RUB").first;
        //     e.sum = e.sum! / _course.value!;
        //   }
        // });

        emit(UpdateSchemeState(
          start: _start,
          end: _end,
          transaction: _listTransactions,
          sort: _sortType,
          index: index,
        ));
        emit(UpdateTransactionList(transaction: _listTransactions));
      }
      emit(const ListLoadingOpacityHideState());
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  Future<TransactionsResponcePageInfo?> _abstractAllTransactionsRequest(
    Emitter<HomeScreenState> emit,
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

  Future<TransactionsResponcePageInfo?> _billTransactionsRequest(
    Emitter<HomeScreenState> emit,
    String token,
    String uid,
    DateTime start,
    DateTime end,
  ) async {
    Map<String, String> body = <String, String>{
      "start": start.toIso8601String() + "+00:00",
      "end": end.toIso8601String() + "+00:00",
      "userId": uid,
    };
    return await TransactionInteractor().transactionsMonth(
      token: token,
      body: body,
    );
  }
}
