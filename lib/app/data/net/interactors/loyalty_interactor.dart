import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import '../api.dart';

class LoyaltyInteractor {
  Future<bool?> deleteById(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-card/" + body["cardId"]!;
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

  Future<MyLoyaltyData?> getCardById(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-card/" + body["cardId"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: <String, String>{},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final MySingleLoyaltyResponseModel _result =
            MySingleLoyaltyResponseModel.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<Loyalty>?> blankList(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-blank/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final LoyaltyResponseModel _result =
            LoyaltyResponseModel.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<MyLoyaltyData>?> getMyCard(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-card/user";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final MyLoyaltyResponseModel _result =
            MyLoyaltyResponseModel.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<String?> createCard({
    required Map<String, String> body,
    required String token,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-card/";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201) {
        final CreatedLoyaltyResponseModel _result =
            CreatedLoyaltyResponseModel.fromJson(data);
        return _result.data.id;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> customImage({
    required Map<String, String> body,
    required String token,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/loyalty-card/custom-image/" + body["cardId"]!;

      final StreamedResponse? response = await Session().uploadFile(
        url: _t,
        body: body,
      );
      if (response != null) {
        if (response.statusCode == 200) {
          return true;
        }
      }

      return null;
    } catch (ex) {
      return null;
    }
  }
}
