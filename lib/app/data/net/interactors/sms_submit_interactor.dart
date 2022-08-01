import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/sms_submit_model.dart';

import '../api.dart';

class SmsSubmitInteractor {
  Future<SmsSubmitModel?> smsSubmit({required Map<String, String> body}) async {
    try {
      var response = await Session().smsSubmit(
        body: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final SmsSubmitModel _result = SmsSubmitModel.fromJson(data);

        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<SmsSubmitResultModel?> smsSubmitResult(
      {required Map<String, String> body}) async {
    try {
      var response = await Session().smsSubmitResult(
        body: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final SmsSubmitResultModel _result =
            SmsSubmitResultModel.fromJson(data);

        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
