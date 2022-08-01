import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/interactors/banks_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/bill_interactor.dart';
import '../../data/net/models/bills_response.dart';
import 'add_invoice_events.dart';
import 'add_invoice_states.dart';

class AddInvoiceBloc extends Bloc<AddInvoiceEvent, AddInvoiceState> {
  AddInvoiceBloc({
    this.bank,
    this.bankUserId,
    this.phone,
    this.password,
    this.date,
  }) : super(const ListLoadingState()) {
    on<StartBillCreateEvent>(_onBillCreateRequested);
    // on<BankStartConnect>(_onStartBankConnect);

    on<SaveTochkaBankEvent>(_onTochkaBankSubmit);
    on<SaveBankEvent>(_onIntegrationCheck);
    on<BankConnectSubmit>(_onBankConnectSubmit);
    on<DateUpdateEvent>((event, emit) {
      date = event.date;
      emit(UpdateDateState(date: event.date));
    });
    on<BillUpdateEvent>(_onBillUpdate);
  }

  bool reAuth = false;
  BankTypes? bank;
  String? bankUserId;
  String? phone;
  String? password;
  DateTime? date;

  void _onTochkaBankSubmit(
    SaveTochkaBankEvent event,
    Emitter<AddInvoiceState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");

      emit(const ListLoadingOpacityState());
      if (token != null && uid != null) {
        final bool? _isAuth = await BanksInteractor().tochkaBankConnectSubmit(
          token: token,
          body: <String, String>{
            "userId": uid,
            "startDate": date.toString().replaceAll(" ", "T") + "Z",
            "code": event.code!,
          },
          bank: event.bank,
        );
        if (_isAuth != null && _isAuth) {
          final bool? isSync = await BanksInteractor().sync(
            token: token,
            body: <String, String>{
              "userId": uid,
            },
            bank: event.bank,
          );
          if (isSync != null && isSync) {
            emit(const GoToHomeScreen());
          }
        }
      }
      emit(const ListLoadingOpacityHideState());
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onBankConnectSubmit(
    BankConnectSubmit event,
    Emitter<AddInvoiceState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");

      if (token != null && uid != null) {
        final _body = <String, String>{
          "code": event.code,
        };
        if (bank == BankTypes.tinkoff) {
          _body["password"] = password!;
          _body["id"] = bankUserId!;
        } else {
          _body["userId"] = bankUserId!;
        }

        final bool? _isAuth = await BanksInteractor().bankConnectSubmit(
          token: token,
          body: _body,
          bank: bank,
        );
        if (_isAuth != null && _isAuth) {
          final bool? isSync = await BanksInteractor().sync(
            token: token,
            body: <String, String>{
              "userId": uid,
            },
            bank: bank,
          );
          if (isSync != null && isSync) {
            emit(const GoToHomeScreen());
          }
        }

        emit(const ListLoadingOpacityHideState());
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onIntegrationCheck(
    SaveBankEvent event,
    Emitter<AddInvoiceState> emit,
  ) async {
    try {
      String? _bankUserId;

      phone = event.phone;
      password = event.password;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");
      String? uid = prefs.getString("wallet_box_uid");

      emit(const ListLoadingOpacityState());
      if (token != null && uid != null) {
        final bool? _integratioState =
            await BanksInteractor().bankIntegrationCheck(
          token: token,
          body: <String, String>{
            "userId": uid,
          },
          bank: event.bank,
        );
        reAuth = _integratioState ?? false;

        if (event.bank == BankTypes.sber) {
          await BanksInteractor().removeIntegration(
            token: token,
            body: <String, String>{"userId": uid},
            bank: event.bank,
          );
        }

        Map<String, String> _body = {
          "userId": uid,
          "phone": phone!.replaceAll(RegExp(r"\s+\b|\b\s"), ""),
          "reAuth": reAuth.toString(),
          "exportStartDate": date.toString().replaceAll(" ", "T") + "Z",
          "startExportDate": date.toString().replaceAll(" ", "T") + "Z",
        };
        if (event.bank == BankTypes.tinkoff) {
          _body["password"] = password!;
        }

        _bankUserId = await BanksInteractor().bankConnectStart(
          token: token,
          body: _body,
          bank: event.bank,
        );

        if (_bankUserId != null && _bankUserId.isNotEmpty) {
          bankUserId = event.bank == BankTypes.tinkoff ? _bankUserId : uid;
          emit(const ListLoadingOpacityHideState());
          emit(CodeScreen(
            tinkoffUserId: bankUserId!,
            phone: phone!,
            password: password!,
            date: date!,
          ));
        } else {
          emit(const ListErrorState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onBillCreateRequested(
    StartBillCreateEvent event,
    Emitter<AddInvoiceState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final Bill? _createState = await BillInteractor().createNewBill(
          token: token,
          body: <String, String>{
            "userId": uid,
            "name": event.name,
            "balance": event.balance.split(",").first,
            "cents": event.balance.split(",").length == 1
                ? "00"
                : event.balance.split(",").last
          },
        );
        if (_createState != null) {
          emit(BillCreateState(bill: _createState));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onBillUpdate(
    BillUpdateEvent event,
    Emitter<AddInvoiceState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");
      if (token != null && uid != null) {
        final bool? _createState = await BillInteractor().updateBill(
          token: token,
          body: <String, String>{
            "userId": uid,
            "name": event.name,
            "newAmount": event.balance.split(".").first,
            "newCents": event.balance.split(".").length == 1
                ? "00"
                : event.balance.split(".").last,
          },
          billId: event.id,
        );
        if (_createState != null && _createState) {
          emit(const BillCreateState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
