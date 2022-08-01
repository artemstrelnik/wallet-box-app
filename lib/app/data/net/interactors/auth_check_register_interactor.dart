import 'dart:convert';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/models/auth_check_register.dart';

import '../api.dart';

class AuthCheckRegisterInteractor {
  Future<bool?> checkEmail({required Map<String, String> body}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await Session()
          .generalRequest(body: body, url: "/api/v1/auth/check-register/email");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final AuthCheckRegisterResponce _result =
            AuthCheckRegisterResponce.fromJson(data);

        return _result.data;
      } else if (response.statusCode == 500) {
        await prefs.remove("wallet_box_uid");
        await prefs.remove("wallet_box_token");
        Session().removeToken();
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> execute({required String phone}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await Session().authCheckRegister(
        body: <String, String>{"phone": phone},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final AuthCheckRegisterResponce _result =
            AuthCheckRegisterResponce.fromJson(data);

        return _result.data;
      } else if (response.statusCode == 500) {
        await prefs.remove("wallet_box_uid");
        await prefs.remove("wallet_box_token");
        Session().removeToken();
      }
      return false;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> checkRegisterEmail({required String email}) async {
    try {
      var response = await Session().generalRequest(
        url: "/api/v1/auth/check-register/email",
        body: <String, String>{"email": email},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }
}
