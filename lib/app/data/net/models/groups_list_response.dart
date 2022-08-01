class GroupsListResponse {
  GroupsListResponse({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<Group> data;

  GroupsListResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Group.fromJson(e)).toList();
  }
}

class Group {
  Group({
    required this.id,
    required this.name,
    required this.variants,
  });
  late final String id;
  late final String name;
  late final List<Subscription> variants;

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    variants = List.from(json['variants'])
        .map((e) => Subscription.fromJson(e))
        .toList();
  }
}

class Subscription {
  Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.expiration,
    required this.price,
    required this.newPrice,
    required this.role,
  });
  late final String id;
  late final String name;
  late final String description;
  late final int expiration;
  late final double price;
  late final double newPrice;
  late final Role role;

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    expiration = json['expiration'];
    price = json['price'];
    newPrice = json['newPrice'];
    role = Role.fromJson(json['role']);
  }
}

class Role {
  Role({
    required this.id,
    required this.name,
  });
  late final String id;
  late final String name;

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}
