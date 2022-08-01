import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/categories_by_uid_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/category_interactor.dart';
import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'categories_screens_events.dart';
import 'categories_screens_states.dart';

class CategoriesScreensBloc
    extends Bloc<CategoriseScreensEvent, CategoriseScreensState> {
  CategoriesScreensBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<IconChangedEvent>(_onIconChanged);
    on<ColorChangedEvent>(_onColorChanged);
    on<StartCreateCategory>(_onCreateCategoryRequested);
    on<CategoryEditEvent>(
        (event, emit) => emit(CategoryEditState(category: event.category)));
    on<RemoveCategoryEvent>(_onCategoryRemove);
    on<StartUpdateCategory>(_onCategoryUpdateRequested);
  }

  late CategoryColor _color;
  late OperationIcon _icon;

  late String _uid;
  late String _token;

  late User _user;
  // final FlutterSecureStorage storage = const FlutterSecureStorage();

  void _onCategoryUpdateRequested(
    StartUpdateCategory event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final bool? _responce = await CategoryInteractor().update(
        body: <String, dynamic>{
          "name": event.name,
          "description": "description",
          "icon": _icon.id,
          "color": _color.systemName,
          "categoryLimit": event.sum,
          "forEarn": event.onlyForEarn,
          "forSpend": !event.onlyForEarn,
        },
        token: _token,
        categoryId: event.category.id,
      );
      emit(const ListLoadingOpacityHideState());
      if (_responce != null && _responce) {
        emit(const ListLoadingOpacityHideState());
        final CatigoriesResponce? _categories =
            await CategoriesByUidInteractor().execute(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_categories != null && _categories.status == 200) {
          emit(
              UpdateCategoriesList(categories: _categories.data, isEdit: true));
        } else {
          emit(const ListErrorState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onCategoryRemove(
    RemoveCategoryEvent event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final bool? _isDelete = await CategoryInteractor().delete(
        body: <String, String>{"categoryId": event.category.id},
        token: _token,
      );
      emit(const ListLoadingOpacityHideState());
      if (_isDelete != null && _isDelete) {
        final CatigoriesResponce? _categories =
            await CategoriesByUidInteractor().execute(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_categories != null && _categories.status == 200) {
          emit(UpdateCategoriesList(categories: _categories.data));
          emit(ResetFieldsState());
        } else {
          emit(const ListErrorState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onIconChanged(
    IconChangedEvent event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    _icon = event.icon;
    emit(UpdateSelectedIcon(icon: event.icon));
  }

  void _onColorChanged(
    ColorChangedEvent event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    _color = event.color;
    emit(UpdateSelectedColor(color: event.color));
  }

  void _onCreateCategoryRequested(
    StartCreateCategory event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final Map<String, dynamic> _body = {
        "name": event.name,
        "description": "description",
        "icon": _icon.id,
        "color": _color.systemName,
        "userId": _uid,
        "categoryLimit": event.sum,
        "forEarn": event.onlyForEarn,
        "forSpend": !event.onlyForEarn,
      };
      final OperationCategory? _responce = await CategoryInteractor().execute(
        body: _body,
        token: _token,
      );
      emit(const ListLoadingOpacityHideState());
      if (_responce != null) {
        final CatigoriesResponce? _categories =
            await CategoriesByUidInteractor().execute(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_categories != null && _categories.status == 200) {
          emit(UpdateCategoriesList(categories: _categories.data));
          emit(ResetFieldsState(cat: _responce));
        } else {
          emit(const ListErrorState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<CategoriseScreensState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = await prefs.getString("wallet_box_uid");
      String? token = await prefs.getString("wallet_box_token");
      if (uid != null && token != null) {
        List<OperationCategory> _categoriesList = <OperationCategory>[];
        _uid = uid;
        _token = token;
        final List<CategoryColor>? _colors =
            await CategoriesByUidInteractor().getColors(token: token);
        if (_colors != null && _colors.isNotEmpty) {
          emit(UpdateColorsList(colors: _colors));
          _color = _colors.first;
        }

        final List<OperationIcon>? _icons =
            await CategoriesByUidInteractor().getIcons(token: token);
        if (_icons != null && _icons.isNotEmpty) {
          emit(UpdateIconsList(icons: _icons));
          _icon = _icons.first;
        }

        if (_icons != null &&
            _icons.isNotEmpty &&
            _colors != null &&
            _colors.isNotEmpty) {
          emit(FirstUpdateSelect(color: _color, icon: _icon));
        }
        final CatigoriesResponce? _categories =
            await CategoriesByUidInteractor().execute(
          body: <String, String>{
            "userId": _uid,
          },
          token: _token,
        );
        if (_categories != null && _categories.status == 200) {
          _categoriesList.addAll(_categories.data);
        }
        // final CatigoriesResponce? _categoriesBase =
        //     await CategoriesByUidInteractor().base(
        //   body: <String, String>{
        //     "userId": _uid,
        //   },
        //   token: _token,
        // );
        // if (_categoriesBase != null && _categoriesBase.status == 200) {
        //   _categoriesList.addAll(_categoriesBase.data);
        // }
        if (_categoriesList.isNotEmpty) {
          emit(UpdateCategoriesList(categories: _categoriesList));
        } else {
          emit(const ListErrorState());
        }
      } else {
        // go to auth
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
