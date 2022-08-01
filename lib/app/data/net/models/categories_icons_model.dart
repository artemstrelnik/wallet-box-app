import 'categories_responce.dart';

class CategoriesIconsResponce {
  CategoriesIconsResponce({
    required this.status,
    required this.data,
    required this.message,
    required this.advices,
  });
  late final int status;
  late final List<OperationIcon> data;
  late final String message;
  late final List<dynamic> advices;

  CategoriesIconsResponce.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        List.from(json['data']).map((e) => OperationIcon.fromJson(e)).toList();
    message = json['message'];
    advices = List.castFrom<dynamic, dynamic>(json['advices']);
  }
}
