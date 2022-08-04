import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_icons_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';

import '../api.dart';

class CategoriesByUidInteractor {
  Future<CatigoriesResponce?> base(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/base-category/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CatigoriesResponce _result = CatigoriesResponce.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<CatigoriesResponce?> execute(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CatigoriesResponce _result = CatigoriesResponce.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<OperationIcon>?> getIcons({required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/image/tag/CATEGORY_ICON";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CategoriesIconsResponce _result =
            CategoriesIconsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<CategoryColor>?> getColors({required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/colors/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CategoriesColorsResponce _result =
            CategoriesColorsResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
