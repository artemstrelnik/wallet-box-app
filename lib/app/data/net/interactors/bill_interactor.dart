import 'dart:convert';
import 'dart:core';

import 'package:logger/logger.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import '../api.dart';

class BillInteractor {
  Future<bool?> removeById(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/bill/" + body["billId"]!;
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

  Future<List<Bill>?> fullList(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/bill/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final BillResponse _result = BillResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> createOperation({
    required Map<String, String> body,
    required String token,
    required String billId,
    required TransactionTypes type,
  }) async {
    try {
      await Session().setToken(token: token);
      Logger().e('message333333333');
      String _t = "/api/v1/bill/" + type.name.toLowerCase() + "/" + billId;
      Logger().w(_t.toString());
      Logger().w(body.toString());
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      Logger().w(response.body.toString());
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final SingleBillResponse _result = SingleBillResponse.fromJson(data);
        return true;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<Bill?> createNewBill({
    required Map<String, String> body,
    required String token,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/bill/";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final SingleBillResponse _result = SingleBillResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> updateBill({
    required Map<String, String> body,
    required String token,
    required String billId,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/bill/" + billId;
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final SingleBillResponse _result = SingleBillResponse.fromJson(data);
        return true;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> updateOperation({
    required Map<String, String> body,
    required String token,
    required String id,
    BankTypes? bankType,
  }) async {
    try {
      Logger().e("message11111111");
      await Session().setToken(token: token);
      Logger().e(bankType?.name.toString());
      String _t =
          "/api/v1/${bankType != null ? bankType.name + "/" : ""}transaction/" +
              id;
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return true;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
