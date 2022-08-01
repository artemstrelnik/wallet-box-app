class BankResponse {
  BankResponse({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final _UserInfo data;
  late final String message;

  BankResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = _UserInfo.fromJson(json['data']);
    message = json['message'];
  }
}

class _UserInfo {
  _UserInfo({
    required this.id,
    required this.userId,
  });
  late final String id;
  late final String? userId;

  _UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
  }
}
