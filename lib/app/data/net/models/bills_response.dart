import 'package:flutter/foundation.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

class BillResponse {
  BillResponse({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final List<Bill> data;
  late final String message;

  BillResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Bill.fromJson(e)).toList();
    message = json['message'];
  }
}

class SingleBillResponse {
  SingleBillResponse({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final Bill data;
  late final String message;

  SingleBillResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = Bill.fromJson(json['data']);
    message = json['message'];
  }
}

class ObjectBillResponse{
  ObjectBillResponse({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final Bill data;
  late final String message;

  ObjectBillResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = Bill.fromJson(json['data']['bill']);
    message = json['message'];
  }
}

class Bill {
  Bill({
    required this.id,
    required this.name,
    required this.user,
    required this.balance,
    required this.cardNumber,
    required this.cardId,
    required this.status,
    required this.expiration,
    this.createdInBank,
    required this.currency,
    this.bankName,
    required this.hidden,
  });
  late final String id;
  late final String name;
  late final User? user;
  late final double balance;

  late final String? cardNumber;
  late final String? cardId;
  late final String? status;
  late final String? expiration;
  late final String? createdInBank;
  late final String? currency;
  late BankTypes? bankName;
  late final bool hidden;

  Bill.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    balance =
        json['balance'];

    cardNumber = json['cardNumber'];
    cardId = json['cardId'];
    status = json['status'];
    expiration = json['expiration'];
    createdInBank = json['createdInBank'];
    currency = json['currency'];
    bankName = json['bankName'] != null
        ? BankTypes.values
            .where((e) =>
                describeEnum(e) == (json['bankName'] as String).toLowerCase())
            .first
        : null;
    hidden = json["hidden"];
  }
}

// class Subscription {
//   Subscription({
//     required this.id,
//     required this.active,
//     this.startDate,
//     this.endDate,
//   });
//   late final String id;
//   late final bool active;
//   late final Null startDate;
//   late final Null endDate;

//   Subscription.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     active = json['active'];
//     startDate = null;
//     endDate = null;
//   }
// }
