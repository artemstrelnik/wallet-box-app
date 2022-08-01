import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import '../api.dart';

class UserUpdateInfoInteractor {
  Future<UserRegistrationModel?> execute(
      {required Map<String, dynamic> body, required String uid}) async {
    try {
      String _t = "/api/v1/user/"; // + uid;
      var response = await Session().generalPatchRequest(url: _t, body: body);
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
