import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import '../api.dart';

class PinCodeUpdateInteractor {
  Future<UserRegistrationModel?> execute(
      {required Map<String, String> body}) async {
    try {
      String _t = "/api/v1/user/pin";
      var response = await Session().generalPatchRequest(
        body: body,
        url: _t,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final UserRegistrationModel _result =
            UserRegistrationModel.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<UserRegistrationModel?> remove(
      {required Map<String, String> body}) async {
    try {
      String _t = "/api/v1/user/pin/" + body["userId"]!;
      var response = await Session().generalRequestDelete(
        url: _t,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final UserRegistrationModel _result =
            UserRegistrationModel.fromJson(data);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
