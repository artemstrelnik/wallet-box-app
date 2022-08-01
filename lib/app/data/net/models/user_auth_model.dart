import 'package:flutter/foundation.dart';
import 'package:wallet_box/app/data/enum.dart';

class UserAuthModel {
  UserAuthModel({
    required this.status,
    this.data,
    this.message,
    this.error,
  });
  late final int status;
  late final Data? data;
  late final String? message;
  late final String? error;

  UserAuthModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
    error = json['error'];
  }
}

class Data {
  Data({
    required this.token,
    required this.user,
  });
  late final String token;
  late final User user;

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = User.fromJson(json['user']);
  }
}

class User {
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.email,
    required this.type,
    required this.walletType,
    required this.touchID,
    required this.faceID,
    required this.pinCode,
  });
  late final String id;
  late final String? username;
  late final Role role;
  late final UserEmail email;
  late final UserType type;
  late final String walletType;
  late final bool touchID;
  late final bool faceID;
  late final String pinCode;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    role = Role.fromJson(json['role']);
    email = UserEmail.fromJson(json['email']);
    type = enumFromStringOther(UserType.values, json['type']);
    walletType = json['walletType'];
    touchID = json['touchID'] ?? false;
    faceID = json['faceID'] ?? false;
    pinCode = json['pinCode'] ?? "";
  }
}

class UserEmail {
  UserEmail({
    required this.address,
    required this.activated,
  });
  late final String? address;
  late final bool activated;

  UserEmail.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    activated = json['activated'];
  }
}

class Role {
  Role({
    required this.id,
    required this.name,
    required this.autoApply,
  });
  late final String id;
  late final String name;
  late final bool autoApply;

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    autoApply = json['autoApply'];
  }
}
