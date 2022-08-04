import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/bill_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/categories_by_uid_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/ticket_interactor.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/ticket_responce_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'add_operation_screen_events.dart';
import 'add_operation_screen_states.dart';
import 'package:intl/intl.dart';

class AddOperationScreenBloc
    extends Bloc<AddOperationScreenEvent, AddOperationScreenState> {
  AddOperationScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onCategoryOpenRequested);
    on<UpdateSelectedCategory>(_onCategoryUpdate);
    on<UpdateSelectedBill>(_onBillUpdate);
    on<UpdateDateTimeEvent>(_onUpdateDateTime);
    on<UpdateAddressEvent>(_onSearchAddressUpdate);
    on<CreateOperationEvent>(_onCreateOperation);
    on<GoToMapPage>(_toMapPage);
    on<GetMessageIdEvent>(_onGetMessageId);
    on<UpdateOperationEvent>(_onUpdateOperation);
    on<UpdateBankOperationEvent>(_onUpdateBankOperation);
  }

  // final FlutterSecureStorage storage = new FlutterSecureStorage();
  late UserNotifierProvider _userInfo;
  late String _uid;
  late String _token;
  OperationCategory? _selectedCategory;
  Bill? _selectedBill;
  late DateTime _date;
  SearchItem? _searchItem;

  void _onUpdateBankOperation(
    UpdateBankOperationEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      if (token != null) {
        _token = token;
        Map<String, String> _body = {};
        if (_selectedCategory != null) {
          _body["categoryId"] = _selectedCategory!.id;
        }

        if (_selectedCategory == null) {
          emit(GoCatCreate());
        } else if (_selectedBill == null) {
          emit(GoBillCreate());
        } else {
          final bool? _responce = await BillInteractor().updateOperation(
            body: _body,
            token: _token,
            id: event.id,
            bankType: event.bankName,
          );
          if (_responce != null && _responce) {
            emit(GoBackEndUpdate());
          }
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onGetMessageId(
    GetMessageIdEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      if (token != null) {
        Map<String, String> body = <String, String>{};
        String codeString = event.codeString!["code"] as String;
        double summ = 0;
        codeString.split("&").forEach((element) {
          var el = element.split("=");

          switch (el.first) {
            case "t":
              var date = DateTime.parse(el.last);
              final DateFormat dateFormat =
                  DateFormat('yyyy-MM-ddTkk:mm:ss', "ru");
              final _date = dateFormat.format(date);
              body["date"] = _date;
              break;
            case "s":
              summ = double.parse(el.last.toString());
              body["sum"] = el.last.split(".").join("");
              break;
            case "fn":
              body["fn"] = el.last;
              break;
            case "i":
              body["fiscalDocumentId"] = el.last;
              break;
            case "fp":
              body["fiscalSign"] = el.last;
              break;
            case "n":
              body["operationType"] = el.last;
              break;
          }
        });

        body["rawData"] = "0";

        final TicketResponceModel? _responce = await FnsInteractor().ticketInfo(
          body: body,
          token: _token,
        );
        if (_responce != null) {
          emit(TicketDataOutputState(data: _responce));
        } else {
          emit(UpdatePrice(sum: summ));
        }
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _toMapPage(
    GoToMapPage event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      emit(ToMapPageState(address: _searchItem));
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUpdateOperation(
    UpdateOperationEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      if (token != null) {
        _token = token;
        Logger().w(_selectedBill.toString());
        Map<String, String> _body = {
          "action": event.type.toString().split(".").last,
          "amount": event.sum.split(".").first,
          "cents": event.sum.split(".").length == 1
              ? "0"
              : event.sum.split(".").last,
          "currency": "RUB",
          "billId": _selectedBill!.id,
        };
        if (event.desc.isNotEmpty) {
          _body["description"] = event.desc;
        }
        if (_searchItem != null) {
          _body["lon"] =
              _searchItem!.geometry.first.point!.longitude.toString();
          _body["lat"] = _searchItem!.geometry.first.point!.latitude.toString();
          _body["geocodedPlace"] =
              _searchItem?.toponymMetadata?.address.formattedAddress ?? "";
        }
        if (_selectedCategory != null) {
          _body["categoryId"] = _selectedCategory!.id;
        }

        if (_selectedCategory == null) {
          emit(GoCatCreate());
        } else if (_selectedBill == null) {
          emit(GoBillCreate());
        } else {
          final bool? _responce = await BillInteractor().updateOperation(
            body: _body,
            token: _token,
            id: event.id,
          );
          if (_responce != null && _responce) {
            emit(GoBackEndUpdate());
          }
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onCreateOperation(
    CreateOperationEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      if (token != null) {
        _token = token;
        Map<String, String> _body = {
          "amount": event.sum.split(",").first,
          "cents": event.sum.split(",").length == 1
              ? "0"
              : event.sum.split(",").last,
        };
        if (event.desc.isNotEmpty) {
          _body["description"] = event.desc;
        }
        if (_searchItem != null) {
          // _body["lon"] =
          //     _searchItem!.geometry.first.point!.longitude.toString();
          // _body["lat"] = _searchItem!.geometry.first.point!.latitude.toString();
          _body["geocodedPlace"] =
              _searchItem?.toponymMetadata?.address.formattedAddress ?? "";
        }
        if (_selectedCategory != null) {
          _body["categoryId"] = _selectedCategory!.id;
        }
        _body["time"] = _date.toIso8601String() + "Z";

        if (_selectedCategory == null) {
          emit(GoCatCreate());
        } else if (_selectedBill == null) {
          emit(GoBillCreate());
        } else {
          Logger().i(_selectedBill?.id.toString());
          Logger().w(_body.toString());
          Logger().w(event.type.toString());
          final bool? _responce = await BillInteractor().createOperation(
            body: _body,
            token: _token,
            billId: _selectedBill!.id,
            type: event.type,
          );
          if (_responce != null && _responce) {
            emit(GoBackEndUpdate());
          }
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onSearchAddressUpdate(
    UpdateAddressEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      _searchItem = event.address;
      emit(UpdateSelectedAddressState(address: event.address));
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUpdateDateTime(
    UpdateDateTimeEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      _date = event.date;
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onCategoryUpdate(
    UpdateSelectedCategory event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      _selectedCategory = event.category;
      emit(UpdateSelectedCategoryState(category: _selectedCategory!));
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onBillUpdate(
    UpdateSelectedBill event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      _selectedBill = event.bill;
      emit(UpdateSelectedBillState(bill: _selectedBill!));
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onCategoryOpenRequested(
    PageOpenedEvent event,
    Emitter<AddOperationScreenState> emit,
  ) async {
    try {
      List<OperationCategory> _categoriesList = <OperationCategory>[];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = await prefs.getString("wallet_box_uid");
      String? token = await prefs.getString("wallet_box_token");
      if (uid != null && token != null) {
        _uid = uid;
        _token = token;
        final CatigoriesResponce? _categories =
            await CategoriesByUidInteractor().execute(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_categories != null && _categories.status == 200) {
          _categoriesList.addAll(_categories.data);
        }
        // final CatigoriesResponce? _categoriesBase =
        //     await CategoriesByUidInteractor().base(
        //   body: <String, String>{
        //     "userId": _uid,
        //   },
        //   token: _token,
        // );
        // if (_categoriesBase != null && _categoriesBase.status == 200) {
        //   _categoriesList.addAll(_categoriesBase.data);
        // }

        if (_categoriesList.isNotEmpty) {
          if (_categoriesList.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = _categoriesList.first;
          }
          emit(UpdateCategoriesList(categories: _categoriesList));
        } else {
          emit(const CategoriesListErrorState());
        }

        final List<Bill>? _bills = await BillInteractor().fullList(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_bills != null) {
          if (_bills.isNotEmpty) _selectedBill = _bills.first;
          emit(UpdateBillsList(bills: _bills));
        } else {
          emit(const BillsListErrorState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
