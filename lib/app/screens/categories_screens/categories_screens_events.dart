import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';

abstract class CategoriseScreensEvent {
  const CategoriseScreensEvent();
}

class PageOpenedEvent extends CategoriseScreensEvent {}

class ColorChangedEvent extends CategoriseScreensEvent {
  const ColorChangedEvent({required this.color});

  final CategoryColor color;
}

class IconChangedEvent extends CategoriseScreensEvent {
  const IconChangedEvent({required this.icon});

  final OperationIcon icon;
}

class StartCreateCategory extends CategoriseScreensEvent {
  const StartCreateCategory({
    required this.name,
    required this.sum,
    required this.onlyForEarn,
  });

  final String name;
  final String sum;
  final bool onlyForEarn;
}

class RemoveCategoryEvent extends CategoriseScreensEvent {
  const RemoveCategoryEvent({required this.category});

  final OperationCategory category;
}

class CategoryEditEvent extends CategoriseScreensEvent {
  const CategoryEditEvent({required this.category});

  final OperationCategory category;
}

class StartUpdateCategory extends CategoriseScreensEvent {
  const StartUpdateCategory({
    required this.name,
    required this.sum,
    required this.category,
    required this.onlyForEarn,
  });

  final String name;
  final String sum;
  final OperationCategory category;
  final bool onlyForEarn;
}
