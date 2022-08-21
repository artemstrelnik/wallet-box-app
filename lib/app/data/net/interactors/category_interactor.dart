import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';

import '../api.dart';

class CategoryInteractor {
  Future<OperationCategory?> execute(
      {required Map<String, dynamic> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/";
      var response = await Session().generalRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return OperationCategory.fromJson(data["data"]);
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> update(
      {required Map<String, dynamic> body,
      required String token,
      required String categoryId}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/" + categoryId;
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> delete(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/" + body["categoryId"]!;
      var response = await Session().generalRequestDelete(
        url: _t,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> updateFavoriteCategory({
    required Map<String, dynamic> body,
    required String token,
    String? categoryId,
  }) async {
    try {
      await Session().setToken(token: token);
      late Response response;
      if (categoryId == null) {
        String _t = "/api/v1/category/favorite";
        response = await Session().generalPatchRequest(
          url: _t,
          body: body,
        );
      } else {
        String _t = "/api/v1/category/favorite/$categoryId";
        response = await Session().generalRequestDelete(url: _t);
      }
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }
}
