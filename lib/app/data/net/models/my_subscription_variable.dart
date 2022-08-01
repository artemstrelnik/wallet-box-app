class MySubscriptionResponce {
  MySubscriptionResponce({
    required this.status,
    required this.data,
  });
  late final int status;
  late final MySubscription data;

  MySubscriptionResponce.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = MySubscription.fromJson(json['data']);
  }
}

class MySubscription {
  MySubscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.variant,
    required this.active,
  });
  late final String id;
  late final String startDate;
  late final String endDate;
  late final Variant variant;
  late final bool active;

  MySubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    variant = Variant.fromJson(json['variant']);
    active = json['active'];
  }
}

class Variant {
  Variant({
    required this.id,
    required this.name,
    required this.description,
    required this.expiration,
    required this.price,
    required this.newPrice,
  });
  late final String id;
  late final String name;
  late final String description;
  late final int expiration;
  late final double price;
  late final double newPrice;

  Variant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    expiration = json['expiration'];
    price = json['price'];
    newPrice = json['newPrice'];
  }
}
