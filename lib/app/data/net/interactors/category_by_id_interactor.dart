import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import '../api.dart';

class CategoryByIdInteractor {
  Future<CategoriesResponse?> execute(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/category/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final CategoriesResponse _result = CategoriesResponse.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
