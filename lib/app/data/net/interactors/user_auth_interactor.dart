import 'dart:convert';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import '../models/user_auth_model.dart';

class UserAuthInteractor {
  Future<UserAuthModel?> execute({required Map<String, String> body}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await Session().userAuth(
        body: body,
      );
      final data = jsonDecode(response.body);
      prefs.setString("result", response.body);
      if (response.statusCode == 200) {
        final UserAuthModel _result = UserAuthModel.fromJson(data);
        await Session().setToken(token: _result.data!.token);
        return _result;
      } else {
        final UserAuthModel _result = UserAuthModel.fromJson(data);
        return _result;
      }
    } catch (ex) {
      return null;
    }
  }

  Future<UserAuthModel?> byEmail({required Map<String, String> body}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await Session().generalRequest(
        body: body,
        url: "/api/v1/auth/cred",
      );
      final data = jsonDecode(response.body);
      prefs.setString("result", response.body);
      if (response.statusCode == 200) {
        final UserAuthModel _result = UserAuthModel.fromJson(data);
        await Session().setToken(token: _result.data!.token);
        return _result;
      } else {
        final UserAuthModel _result = UserAuthModel.fromJson(data);
        return _result;
      }
    } catch (ex) {
      return null;
    }
  }

  Future<UserAuthModel?> smsExecute({required Map<String, String> body}) async {
    try {
      var response = await Session().generalRequest(
        body: body,
        url: "/api/v1/auth/sms",
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final UserAuthModel _result = UserAuthModel.fromJson(data);
        await Session().setToken(token: _result.data!.token);
        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<bool?> remove({required Map<String, String> body}) async {
    try {
      var response = await Session().generalRequestDelete(
        url: "/api/v1/user/",
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
