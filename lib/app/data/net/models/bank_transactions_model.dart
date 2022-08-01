import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';

class BankTransactionsResponse {
  BankTransactionsResponse({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final TransactionsResponcePageInfo data;
  late final String message;

  BankTransactionsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = TransactionsResponcePageInfo.fromJson(json['data']);
    message = json['message'];
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
