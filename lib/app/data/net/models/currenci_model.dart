class CurrenciesResponce {
  CurrenciesResponce({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<Currency> data;

  CurrenciesResponce.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Currency.fromJson(e)).toList();
  }
}

class Currency {
  Currency({
    required this.walletSystemName,
    required this.walletDisplayName,
  });
  late final String walletSystemName;
  late final String walletDisplayName;

  Currency.fromJson(Map<String, dynamic> json) {
    walletSystemName = json['walletSystemName'];
    walletDisplayName = json['walletDisplayName'];
  }
}

class CourseResponse {
  CourseResponse({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<Course> data;

  CourseResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = List.from(json['data']).map((e) => Course.fromJson(e)).toList();
  }
}

class Course {
  Course({
    required this.wallet,
    required this.value,
  });
  late final String wallet;
  late final double? value;

  Course.fromJson(Map<String, dynamic> json) {
    wallet = json['wallet'];
    value = json['value'];
  }
}
