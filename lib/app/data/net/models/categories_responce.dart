import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';

class CategoriesResponse {
  CategoriesResponse({
    required this.status,
    required this.data,
    required this.message,
    required this.advices,
  });
  late final int status;
  late final List<OperationCategory> data;
  late final String message;
  late final List<String> advices;

  CategoriesResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data'])
        .map((e) => OperationCategory.fromJson(e))
        .toList();
    message = json['message'];
    advices = List.castFrom<dynamic, String>(json['advices']);
  }
}

class OperationCategory {
  OperationCategory({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    this.description,
    required this.categoryLimit,
    // this.user,
    this.forEarn = false,
    this.forSpend = false,
    this.percentsFromLimit,
    this.categorySpend,
    this.categoryEarn,
  });
  late final String id;
  late final String name;
  late final CategoryColor color;
  late final OperationIcon? icon;
  late final String? description;
  late final double categoryLimit;
  // late final User? user;
  late final bool forEarn;
  late final bool forSpend;
  late final double? percentsFromLimit;
  late final double? categorySpend;
  late final double? categoryEarn;
  late final bool favorite;

  OperationCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = CategoryColor.fromJson(json['color']);
    icon = json['icon'] != null ? OperationIcon.fromJson(json['icon']) : null;
    description = json['description']??"";
    categoryLimit = (json['categoryLimit']) == 0 ? 0.0 : json["categoryLimit"];
    // user = User.fromJson(json['user']);
    forEarn = json['forEarn'];
    forSpend = json['forSpend'];
    percentsFromLimit = json['percentsFromLimit']== 0 ? 0.0 : json["percentsFromLimit"];
    categorySpend = json['categorySpend']== 0 ? 0.0 : json["categorySpend"] ;
    categoryEarn = json['categoryEarn']== 0 ? 0.0 : json["categoryEarn"];
    favorite = json['favorite'];
  }
}

class OperationIcon {
  OperationIcon({
    required this.id,
    required this.name,
    required this.path,
    required this.tag,
  });
  late final String id;
  late final String name;
  late final String path;
  late final String tag;

  OperationIcon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    path = json['path'];
    tag = json['tag'];
  }
}
