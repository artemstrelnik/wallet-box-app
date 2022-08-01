class SubscriptionsResponse {
  SubscriptionsResponse({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<Subscription> data;

  SubscriptionsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        List.from(json['data']).map((e) => Subscription.fromJson(e)).toList();
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
  });
  late final String id;
  late final String name;
  late final String description;
  late final int expiration;
  late final double price;
  late final double newPrice;

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    expiration = json['expiration'];
    price = json['price'];
    newPrice = json['newPrice'];
  }
}
