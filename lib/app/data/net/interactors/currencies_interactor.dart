import 'dart:convert';
import 'dart:core';

import 'package:logger/logger.dart';
import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import '../api.dart';

class CurrenciesInteractor {
  Future<List<Currency>?> execute() async {
    try {
      String _t = "/api/v1/wallet/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CurrenciesResponce _result = CurrenciesResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<List<Course>?> course() async {
    try {
      String _t = "/api/v1/wallet/course/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final CourseResponse _result = CourseResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
