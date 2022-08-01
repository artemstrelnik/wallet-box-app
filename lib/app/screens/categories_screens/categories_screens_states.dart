import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';

abstract class CategoriseScreensState {
  const CategoriseScreensState();
}

class ListLoadingState extends CategoriseScreensState {
  const ListLoadingState();
}

class ListLoadedState extends CategoriseScreensState {
  const ListLoadedState();
}

class ListErrorState extends CategoriseScreensState {
  const ListErrorState();
}

class ListLoadingOpacityState extends CategoriseScreensState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends CategoriseScreensState {
  const ListLoadingOpacityHideState();
}

class UpdateCategoriesList extends CategoriseScreensState {
  const UpdateCategoriesList({required this.categories, this.isEdit = false});

  final List<OperationCategory> categories;
  final bool isEdit;
}

class UpdateColorsList extends CategoriseScreensState {
  const UpdateColorsList({required this.colors});

  final List<CategoryColor> colors;
}

class UpdateIconsList extends CategoriseScreensState {
  const UpdateIconsList({required this.icons});

  final List<OperationIcon> icons;
}

class UpdateSelectedIcon extends CategoriseScreensState {
  const UpdateSelectedIcon({required this.icon});

  final OperationIcon icon;
}

class UpdateSelectedColor extends CategoriseScreensState {
  const UpdateSelectedColor({required this.color});

  final CategoryColor color;
}

class FirstUpdateSelect extends CategoriseScreensState {
  const FirstUpdateSelect({required this.color, required this.icon});

  final CategoryColor color;
  final OperationIcon icon;
}

class CategoryEditState extends CategoriseScreensState {
  const CategoryEditState({required this.category});

  final OperationCategory category;
}

class ResetFieldsState extends CategoriseScreensState {
  const ResetFieldsState({this.cat, this.isEdit = false});

  final OperationCategory? cat;
  final bool isEdit;
}
