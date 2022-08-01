import 'dart:convert';
import 'dart:core';

import 'package:wallet_box/app/data/net/models/ticket_responce_model.dart';
import '../api.dart';

class FnsInteractor {
  Future<TicketResponceModel?> ticketInfo(
      {required Map<String, String> body, required String token}) async {
    try {
      var response = await Session().generalRequestGet(
        url: "/api/v1/fns/ticket-info",
        queryParameters: body,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String _data = data["data"];
        String messageId =
            _data.split("<MessageId>").last.split("</MessageId>").first;

        if (messageId.isNotEmpty) {
          final TicketResponceModel? _result =
              await message(body: {"messageId": messageId});
          if (_result != null) {
            return _result;
          }
        }
      }
      return null;
    } catch (ex) {
      return null;
    }
  }

  Future<TicketResponceModel?> message(
      {required Map<String, String> body}) async {
    try {
      var response = await Session().generalRequestGet(
        url: "/api/v1/fns/message",
        queryParameters: body,
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        var _json = data["data"]
            .toString()
            .split("<Ticket>")
            .last
            .split("</Ticket>")
            .first;
        final _data = json.decode(_json);

        final TicketResponceModel _result = TicketResponceModel.fromJson(_data);

        return _result;
      }
      return null;
    } catch (ex) {
      return null;
    }
  }
}
