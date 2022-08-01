class AuthCheckRegisterResponce {
  AuthCheckRegisterResponce({
    required this.status,
    required this.data,
    required this.message,
  });

  int status;
  bool data;
  String message;

  AuthCheckRegisterResponce.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? json['status'],
        data = json['data'] ?? json['data'],
        message = json['message'] ?? json['message'];
}
