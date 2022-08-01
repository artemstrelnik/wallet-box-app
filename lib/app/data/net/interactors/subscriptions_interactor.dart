import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/groups_list_response.dart';
import 'package:wallet_box/app/data/net/models/my_subscription_variable.dart';
import '../api.dart';

class SubscriptionsInteractor {
  Future<List<Group>?> fullGroupsList(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/subscription-variant/group/";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final GroupsListResponse _result = GroupsListResponse.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<MySubscription?> getMySubscription(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/subscription/user/" + body["userId"]!;
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: {},
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final MySubscriptionResponce _result =
            MySubscriptionResponce.fromJson(data);
        return _result.data;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<String?> linkSubscriptionPay(
      {required Map<String, String> body, required String token}) async {
    try {
      await Session().setToken(token: token);
      String _t = "/api/v1/acquiring/tinkoff/payment-url";
      var response = await Session().generalRequestGet(
        url: _t,
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return data["data"];
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  // Future<List<Subscription>?> fullList(
  //     {required Map<String, String> body, required String token}) async {
  //   try {
  //     await Session().setToken(token: token);
  //     String _t = "/api/v1/subscription-variant/";
  //     var response = await Session().generalRequestGet(
  //       url: _t,
  //       queryParameters: body,
  //     );
  //     final data = json.decode(utf8.decode(response.bodyBytes));
  //     if (response.statusCode == 200) {
  //       final SubscriptionsResponse _result =
  //           SubscriptionsResponse.fromJson(data);
  //       return _result.data;
  //     }
  //     return null;
  //   } catch (ex) {
  //     return null;
  //   }
  // }
}
