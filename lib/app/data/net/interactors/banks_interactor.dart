import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bank_cards_iist_response.dart';
import 'package:wallet_box/app/data/net/models/bank_response.dart';
import 'package:wallet_box/app/data/net/models/bank_transactions_model.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import '../api.dart';

class BanksInteractor {
  Future<List<Bill>?> removeTransaction({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/cards/" +
          body["userId"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final BankCardsListResponse _result =
            BankCardsListResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<Bill>?> syncCard({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/cards/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
        error: false,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final BankCardsListResponse _result =
            BankCardsListResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> bankConnectSubmit({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/connect/submit";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<String?> bankConnectStart({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/connect/start";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        switch (bank) {
          case BankTypes.tinkoff:
            final BankResponse _result = BankResponse.fromJson(data);
            return _result.data.id;
          case BankTypes.sber:
            return "sber";
          // case BankTypes.vtb:
          //   return "vtb";
          case BankTypes.tochka:
            return "tochka";
        }
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> bankIntegrationCheck({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: <String, String>{},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> sync({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/sync/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<List<Transaction>?> bankTransactionsRequest({
    required Map<String, String> body,
    required String token,
    String? id,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t =
          "/api/v1/${bank!.toString().split(".").last}/transactions/" + id!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final list = BankTransactionsResponse.fromJson(data);
        return list.data.page;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> removeIntegration({
    required Map<String, String> body,
    required String token,
    required BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/";
      var response = await Session().generalRequestDelete(
        url: _t,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> tochkaBankConnectSubmit({
    required Map<String, String> body,
    required String token,
    BankTypes? bank,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/${bank!.toString().split(".").last}/submit-auth";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }
}
