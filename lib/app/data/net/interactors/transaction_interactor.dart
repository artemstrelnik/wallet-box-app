import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';

import '../api.dart';

class TransactionInteractor {
  Future<bool?> removeIntegration(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/transaction/" + body["transaction"]!;
      var response = await Session().generalRequestDelete(
        url: _t,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<TransactionsResponcePageInfo?> categoryId(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/transaction/category/" + body["categoryId"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {
          "page": "0",
          "pageSize": "100",
        },
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final TransactionsResponce _result =
            TransactionsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<TransactionsResponcePageInfo?> fullList(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/transaction/user/" + body["uid"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {
          "page": "0",
          "pageSize": "100",
        },
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final TransactionsResponce _result =
            TransactionsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<TransactionsResponcePageInfo?> transactionsMonth(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);

      body["page"] = "0";
      body["pageSize"] = "9999";

      String _t = "/api/v1/transaction/period";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final TransactionsResponce _result =
            TransactionsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<TransactionsResponcePageInfo?> abstractAllTransactions({
    required Map<String, String> body,
    required String token,
    bool? isExpense,
  }) async {
    try {
      await Session().setToken(token: token);

      body["page"] = "0";
      body["pageSize"] = "1000";

      if (isExpense != null) {
        body["transactionType"] = isExpense ? "DEPOSIT" : "WITHDRAW";
      }

      String _t = "/api/v1/abstract/all-transactions";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final TransactionsResponce _result =
            TransactionsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<User?> updateEarnSpend(
      {required Map<String, dynamic> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/user/plans";
      Response response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        UserRegistrationModel user = UserRegistrationModel.fromJson(data);
        return user.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
