import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/user_registration_model.dart';

import '../api.dart';

class UserRegistrationInteractor {
  Future<UserRegistrationModel?> execute(
      {required Map<String, String> body}) async {
    try {
      var response = await Session().generalRequest(
        body: body,
        url: "/api/v1/user/",
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
