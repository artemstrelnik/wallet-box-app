class LoyaltyResponseModel {
  LoyaltyResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final List<Loyalty> data;
  late final String message;

  LoyaltyResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Loyalty.fromJson(e)).toList();
    message = json['message'];
  }
}

class Loyalty {
  Loyalty({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });
  late final String id;
  late final String name;
  late final String description;
  late final LoyaltyImage? image;

  Loyalty.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = LoyaltyImage.fromJson(json['image']);
  }
}

class LoyaltyImage {
  LoyaltyImage({
    required this.id,
    required this.name,
    required this.path,
    required this.tag,
  });
  late final String id;
  late final String name;
  late final String path;
  late final String tag;

  LoyaltyImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    path = json['path'];
    tag = json['tag'];
  }
}
