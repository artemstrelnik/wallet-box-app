import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

class UserRegistrationModel {
  UserRegistrationModel({
    required this.status,
    required this.data,
  });
  late final int status;
  late final User data;

  UserRegistrationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = User.fromJson(json['data']);
  }
}
