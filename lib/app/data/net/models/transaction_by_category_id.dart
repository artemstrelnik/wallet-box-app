import 'package:flutter/foundation.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';

import '../../enum.dart';
import 'bills_response.dart';

class TransactionsResponce {
  TransactionsResponce({
    required this.status,
    required this.data,
  });
  late final int status;
  late final TransactionsResponcePageInfo data;

  TransactionsResponce.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = TransactionsResponcePageInfo.fromJson(json['data']);
  }
}

class TransactionsResponcePageInfo {
  TransactionsResponcePageInfo({
    required this.page,
    required this.total,
  });
  late final List<Transaction> page;
  late final int total;

  TransactionsResponcePageInfo.fromJson(Map<String, dynamic> json) {
    page = List.from(json['page']).map((e) => Transaction.fromJson(e)).toList();
    total = json['total'];
  }
}

class Transaction {
  Transaction({
    required this.id,
    required this.action,
    required this.sum,
    required this.description,
    required this.currency,
    required this.geocodedPlace,
    required this.longitude,
    required this.latitude,
    required this.category,
    required this.createAt,
    required this.bill,
    required this.status,
    this.amount,
    required this.date,
    this.billName,
    this.billId,
  });
  late final String id;
  late final TransactionTypes action;
  late double? sum;
  late final String? description;
  late final String? currency;
  late final String? geocodedPlace;
  late final double? longitude;
  late final double? latitude;
  late final OperationCategory? category;
  late final String? createAt;
  Bill? bill;
//
  late final String? status;
  late final Amount? amount;
  //late final String? transactionType;
  late final String? date;
  late final String? billName;
  late final String? billId;

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    action = json['action'] != null
        ? TransactionTypes.values
            .where((e) => describeEnum(e) == json['action'])
            .first
        : TransactionTypes.values
            .where((e) => describeEnum(e) == json['transactionType'])
            .first;
    description = json['description'] ?? "";
    currency = json['currency'] ?? "";
    geocodedPlace = json['geocodedPlace'] ?? "";
    longitude = json['longitude'] ?? 0;
    latitude = json['latitude'] ?? 0;
    category = json['category'] != null
        ? OperationCategory.fromJson(json['category'])
        : null;
    createAt = json['createAt'];
    bill = json['bill'] != null ? Bill.fromJson(json['bill']) : null;
    status = json['status'];
    date = json['date'];
    amount = json['amount'];
    sum = json['sum'];
    billName = json['billName'];
    billId = json['billId'];
  }

  Transaction.clone(Transaction object, Bill bill)
      : this(
          id: object.id,
          action: object.action,
          sum: object.sum,
          description: object.description,
          currency: object.currency,
          geocodedPlace: object.geocodedPlace,
          longitude: object.longitude,
          latitude: object.latitude,
          category: object.category,
          createAt: object.createAt,
          bill: bill,
          status: object.status,
          amount: object.amount,
          date: object.date,
          billName: object.billName,
        );
}

class Amount {
  Amount({
    required this.amount,
    required this.cents,
  });
  late final int amount;
  late final int cents;

  Amount.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    cents = json['cents'];
  }
}

class TransactionsResponceNew {
  TransactionsResponceNew({
    required this.status,
    required this.data,
  });
  late final int status;
  late final Data data;

  TransactionsResponceNew.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.page,
    required this.total,
    required this.totalPages,
  });
  late final List<Page> page;
  late final int total;
  late final int totalPages;

  Data.fromJson(Map<String, dynamic> json) {
    page = List.from(json['page']).map((e) => Page.fromJson(e)).toList();
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['page'] = page.map((e) => e.toJson()).toList();
    _data['total'] = total;
    _data['totalPages'] = totalPages;
    return _data;
  }
}

class Page {
  Page({
    required this.id,
    required this.type,
    required this.description,
    required this.transactionType,
    required this.date,
    this.category,
    required this.sum,
    required this.currency,
    required this.billName,
  });
  late final String id;
  late final String type;
  late final String description;
  late final String transactionType;
  late final String date;
  late final Null category;
  late final int? sum;
  late final String currency;
  late final String billName;

  Page.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    description = json['description'];
    transactionType = json['transactionType'];
    date = json['date'];
    category = null;
    sum = json['sum'];
    currency = json['currency'];
    billName = json['billName'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['type'] = type;
    _data['description'] = description;
    _data['transactionType'] = transactionType;
    _data['date'] = date;
    _data['category'] = category;
    _data['sum'] = sum;
    _data['currency'] = currency;
    _data['billName'] = billName;
    return _data;
  }
}
