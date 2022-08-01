class CategoriesColorsResponce {
  CategoriesColorsResponce({
    required this.status,
    required this.data,
    required this.message,
    required this.advices,
  });
  late final int status;
  late final List<CategoryColor> data;
  late final String message;
  late final List<dynamic> advices;

  CategoriesColorsResponce.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        List.from(json['data']).map((e) => CategoryColor.fromJson(e)).toList();
    message = json['message'];
    advices = List.castFrom<dynamic, dynamic>(json['advices']);
  }
}

class CategoryColor {
  CategoryColor({
    required this.systemName,
    required this.hex,
    required this.name,
  });
  late final String systemName;
  late final String hex;
  late final String name;

  CategoryColor.fromJson(Map<String, dynamic> json) {
    systemName = json['systemName'];
    hex = json['hex'];
    name = json['name'];
  }
}
