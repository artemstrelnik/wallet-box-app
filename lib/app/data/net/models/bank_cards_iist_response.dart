import 'package:wallet_box/app/data/net/models/bills_response.dart';

class BankCardsListResponse {
  BankCardsListResponse({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<Bill> data;

  BankCardsListResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Bill.fromJson(e)).toList();
  }
}
