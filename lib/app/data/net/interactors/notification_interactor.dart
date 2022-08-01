import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import '../api.dart';

class NotificationInteractor {
  Future<bool?> saveUserToken({
    required Map<String, String> body,
    required String token,
  }) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/user/device-token";
      var response = await Session().generalPatchRequest(
        url: _t,
        body: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }
}
