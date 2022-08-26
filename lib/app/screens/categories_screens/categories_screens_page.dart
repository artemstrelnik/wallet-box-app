import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/home_screen/widgets/icon_loader.dart';

import '../../core/generals_widgets/customBottomSheet.dart';
import 'categoies_open/categories_open_bloc.dart';
import 'categoies_open/categories_open_page.dart';
import 'categories_screens_bloc.dart';
import 'categories_screens_events.dart';
import 'categories_screens_states.dart';

import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:screen_loader/screen_loader.dart';

class CategoriseScreensPage extends StatefulWidget {
  const CategoriseScreensPage({
    this.isOperation = false,
    Key? key,
  }) : super(key: key);

  final bool isOperation;

  @override
  _CategoriseScreensPageState createState() => _CategoriseScreensPageState();
}

class _CategoriseScreensPageState extends State<CategoriseScreensPage>
    with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<LoadingState> _initScreen =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<int> _activeIndexSort = ValueNotifier<int>(0);

  final ValueNotifier<List<OperationCategory>> _categoriesList =
      ValueNotifier<List<OperationCategory>>(<OperationCategory>[]);
  final ValueNotifier<List<OperationIcon>> _iconsList =
      ValueNotifier<List<OperationIcon>>(<OperationIcon>[]);
  final ValueNotifier<List<CategoryColor>> _colorsList =
      ValueNotifier<List<CategoryColor>>(<CategoryColor>[]);

  late ValueNotifier<OperationIcon> _iconSelected;
  late ValueNotifier<CategoryColor> _colorSelected;
  final ValueNotifier<bool> _colorIsLoaded = ValueNotifier<bool>(false);

  final TextEditingController _controller = TextEditingController(text: "");
  final TextEditingController _sumController = TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();
  final _modalFormKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _catType = ValueNotifier<bool>(false);
  Brightness? _brightness;

  @override
  void initState() {
    super.initState();
    context.read<CategoriesScreensBloc>().add(
          PageOpenedEvent(),
        );
  }

  @override
  loader() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ConstContext.lightMode(context)
              ? CustomColors.lightPrimaryBackground
              : CustomColors.darkPrimaryBackground,
        ),
        child: CircularProgressIndicator(
          color: !ConstContext.lightMode(context)
              ? CustomColors.lightPrimaryBackground
              : CustomColors.darkPrimaryBackground,
        ),
        width: 100,
        height: 100,
        alignment: Alignment.center,
      ),
    );
  }

  @override
  loadingBgBlur() => 10.0;

  @override
  Widget build(BuildContext context) {
    _brightness = ThemeModelInheritedNotifier.of(context).theme.brightness;
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<CategoriesScreensBloc, CategoriseScreensState>(
      listener: (context, state) {
        if (state is UpdateCategoriesList) {
          if (state.categories.isNotEmpty) {
            _categoriesList.value = state.categories;
            _initScreen.value = LoadingState.loaded;
          } else {
            _initScreen.value = LoadingState.empty;
          }
          if (state.isEdit) {
            Navigator.pop(context);
            _resetFields();
            showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                content: Text("Категория изменена"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Понятно'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        }
        if (state is ListErrorState) {
          _initScreen.value = LoadingState.empty;
        }
        if (state is UpdateColorsList) {
          if (state.colors.isNotEmpty) {
            _colorsList.value = state.colors;
          }
        }
        if (state is UpdateIconsList) {
          if (state.icons.isNotEmpty) {
            _iconsList.value = state.icons;
          }
        }
        if (state is FirstUpdateSelect) {
          _iconSelected = ValueNotifier<OperationIcon>(state.icon);
          _colorSelected = ValueNotifier<CategoryColor>(state.color);
          _colorIsLoaded.value = true;
        }
        if (state is UpdateSelectedColor) {
          _colorSelected.value = state.color;
        }
        if (state is UpdateSelectedIcon) {
          _iconSelected.value = state.icon;
        }

        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is CategoryEditState) {
          _sumController.text = state.category.categoryLimit.toString();
          _controller.text = state.category.name;
          _catType.value = state.category.forEarn;

          context.read<CategoriesScreensBloc>().add(
                IconChangedEvent(
                    icon: _iconsList.value
                        .where((e) => e.id == state.category.icon!.id)
                        .first),
              );
          context.read<CategoriesScreensBloc>().add(
                ColorChangedEvent(
                    color: _colorsList.value
                        .where((e) => e.name == state.category.color.name)
                        .first),
              );
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (_) => Material(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _newCategory(
                        category: state.category,
                        formKey: _modalFormKey,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is ResetFieldsState) {
          if (widget.isOperation) {
            Map<String, dynamic> _map = <String, dynamic>{};

            _map["successes"] = true;
            if (state.cat != null) {
              _map["cat"] = state.cat;
            }

            Navigator.pop(context, _map);
          } else {
            _resetFields();
            showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                content: Text(
                    state.isEdit ? "Категория изменена" : "Категория создана"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Понятно'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          actions: true,
          leading: true,
          header: textString_69,
          body: ValueListenableBuilder(
            valueListenable: _initScreen,
            builder: (BuildContext context, LoadingState _state, _) {
              switch (_state) {
                case LoadingState.empty:
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _newCategory(formKey: _formKey),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15),
                        Center(
                          child: TextWidget(
                            padding: 0,
                            text: "Вы еще не создали ни одну категорию",
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.bodyCard),
                            align: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                case LoadingState.loaded:
                  return SingleChildScrollView(
                    child: AnimationLimiter(
                      child: Column(
                        children: [
                          AnimationConfiguration.staggeredList(
                            position: 0,
                            delay: Duration(milliseconds: 0),
                            child: SlideAnimation(
                              duration: Duration(milliseconds: 0),
                              curve: Curves.fastLinearToSlowEaseIn,
                              horizontalOffset: 30.0,
                              verticalOffset: 300.0,
                              child: FlipAnimation(
                                duration: Duration(milliseconds: 0),
                                curve: Curves.fastLinearToSlowEaseIn,
                                flipAxis: FlipAxis.y,
                                child: _newCategory(formKey: _formKey),
                              ),
                            ),
                          ),
                          AnimationConfiguration.staggeredList(
                            position: 1,
                            delay: Duration(milliseconds: 200),
                            child: SlideAnimation(
                              duration: Duration(milliseconds: 2700),
                              curve: Curves.fastLinearToSlowEaseIn,
                              horizontalOffset: 30.0,
                              verticalOffset: 300.0,
                              child: FlipAnimation(
                                duration: Duration(milliseconds: 3200),
                                curve: Curves.fastLinearToSlowEaseIn,
                                flipAxis: FlipAxis.y,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        "Сортировать по",
                                        style: StyleTextCustom().setStyleByEnum(
                                            context, StyleTextEnum.bodyCard),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          bottomSheetSort();
                                        },
                                        icon: Icon(CupertinoIcons.sort_down)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _categoriesList,
                            builder: (BuildContext context,
                                    List<OperationCategory> _list, _) =>
                                Column(
                              children: _list.map((_item) {
                                int idx = _list.indexOf(_item);
                                return _singleCategory(
                                    category: _item, index: idx);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );

  void doNothing(BuildContext context) {}

  Widget _newCategory(
          {OperationCategory? category,
          required GlobalKey<FormState> formKey}) =>
      Form(
        key: formKey,
        child: ContainerCustom(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    padding: 0,
                    text: category == null
                        ? "Добавить категорию"
                        : "Редактирование категории",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    align: TextAlign.center,
                  ),
                  category == null
                      ? GestureDetector(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              context.read<CategoriesScreensBloc>().add(
                                    StartCreateCategory(
                                      name: _controller.text,
                                      sum: _sumController.text.isNotEmpty
                                          ? _sumController.text
                                          : "0",
                                      onlyForEarn: _catType.value,
                                    ),
                                  );
                            }
                          },
                          child: const SizedBox(
                            child: Icon(
                              Icons.add_circle,
                              color: CustomColors.pink,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mySelectedIcon(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextFieldWidget(
                        textAlign: TextAlign.start,
                        autofocus: false,
                        textInputType: TextInputType.text,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.neutralText),
                        labelText: "Название",
                        fillColor: StyleColorCustom().setStyleByEnum(
                            context, StyleColorEnum.primaryBackground),
                        validation: (String? value) {
                          if (value != null && value.length < 2) {
                            return 'Не менее 2 символов';
                          }
                          return null;
                        },
                        controller: _controller,
                        contentPadding: const EdgeInsets.only(
                          left: 14.0,
                          bottom: 9.0,
                          top: 8.0,
                        ),
                        isDense: true,
                        paddingTop: EdgeInsets.only(top: 11),
                      ),
                    ),
                  ),
                ],
              ),
              _familyWidgets(
                title: "Иконка",
                child: Container(
                  height: 32,
                  margin: const EdgeInsets.only(
                    top: 12,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _iconsList,
                    builder:
                        (BuildContext context, List<OperationIcon> _list, _) =>
                            ListView(
                      scrollDirection: Axis.horizontal,
                      children: _list
                          .map((_item) => _singleIcon(icon: _item))
                          .toList(),
                    ),
                  ),
                ),
              ),
              _familyWidgets(
                title: "Цвет",
                child: Container(
                  height: 30,
                  margin: const EdgeInsets.only(
                    top: 12,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _colorsList,
                    builder:
                        (BuildContext context, List<CategoryColor> _list, _) =>
                            ListView(
                      scrollDirection: Axis.horizontal,
                      children: _list
                          .map((_item) => _singleColor(color: _item))
                          .toList(),
                    ),
                  ),
                ),
              ),
              _familyWidgets(
                title: "Доходная категория",
                child: ValueListenableBuilder(
                  valueListenable: _catType,
                  builder: (BuildContext context, bool _checked, _) =>
                      ThemeSwitcher(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CupertinoSwitch(
                          activeColor: CustomColors.pink,
                          trackColor: StyleColorCustom().setStyleByEnum(context,
                              StyleColorEnum.cupertinoSwitchTrackColor),
                          thumbColor: StyleColorCustom().setStyleByEnum(context,
                              StyleColorEnum.cupertinoSwitchThumbColor),
                          value: _checked,
                          onChanged: (bool value) async {
                            _catType.value = value;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              category != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonCancel(
                          text: "Отмена",
                          onPressed: () {
                            _resetFields();
                            Navigator.pop(context);
                          },
                        ),
                        ButtonBlue(
                          text: "Сохранить",
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<CategoriesScreensBloc>().add(
                                    StartUpdateCategory(
                                      name: _controller.text,
                                      sum: _sumController.text.isNotEmpty
                                          ? _sumController.text
                                          : "0",
                                      category: category,
                                      onlyForEarn: _catType.value,
                                    ),
                                  );
                            }
                          },
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      );

  Widget _singleCategory(
      {required OperationCategory category, required int index}) {
    Logger().w(index.toString());
    return AnimationConfiguration.staggeredList(
      position: index + 2,
      delay: Duration(milliseconds: 150),
      child: SlideAnimation(
        duration: Duration(milliseconds: 2500),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 30.0,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: Duration(milliseconds: 2700),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          child: ValueListenableBuilder(
            valueListenable: _activeIndexSort,
            builder: (BuildContext context, int _index, _) => (_index == 1 &&
                        category.forEarn) ||
                    (_index == 2 && category.forSpend) ||
                    (_index == 3 && category.favorite) ||
                    (_index == 0)
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) =>
                              CategoriesOpenBloc(category: category),
                          child: const CategoriesOpen(),
                        ),
                      ),
                    ),
                    child: ContainerCustom(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(
                                    "0xFF" + category.color.hex.substring(1),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(int.parse("0xFF" +
                                            category.color.hex.substring(1)))
                                        .withOpacity(.4),
                                    Color(int.parse("0xFF" +
                                        category.color.hex.substring(1))),
                                  ],
                                ),
                              ),
                              child: category.icon?.name != null
                                  ? Center(
                                      child: svgIcon(
                                        baseUrl +
                                            "api/v1/image/content/" +
                                            category.icon!.name,
                                        context,
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  padding: 0,
                                  text: category.name,
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.bodyCard),
                                  align: TextAlign.left,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextWidget(
                                      text: category.forEarn && category.forSpend ? "Средний расход: \nСредний доход: " : category.forSpend
                                          ? "Средний расход: "
                                          : "Средний доход: ",
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: _brightness == Brightness.light
                                            ? CustomColors.lightPrimaryText
                                            : CustomColors.lightPrimaryText,
                                      ),
                                    ),
                                    TextWidget(
                                      text:category.forEarn && category.forSpend ? "${category.categorySpend}\n${category.categoryEarn}" : category.forSpend
                                          ? "${category.categorySpend}"
                                          : "${category.categoryEarn}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _brightness == Brightness.light
                                            ? CustomColors.lightPrimaryText
                                            : CustomColors.lightPrimaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            color: StyleColorCustom().setStyleByEnum(
                              context,
                              StyleColorEnum.secondaryBackground,
                            ),
                            itemBuilder: (context) {
                              var list = <PopupMenuEntry<Object>>[];
                              list.add(
                                PopupMenuItem(
                                  child: Row(children: [
                                    Icon(Icons.delete),
                                    Text(
                                      "Удалить",
                                      style: StyleTextCustom().setStyleByEnum(
                                          context, StyleTextEnum.bodyCard),
                                    )
                                  ]),
                                  value: 1,
                                  onTap: () => context
                                      .read<CategoriesScreensBloc>()
                                      .add(
                                        RemoveCategoryEvent(category: category),
                                      ),
                                ),
                              );
                              list.add(
                                PopupMenuItem(
                                  child: Row(children: [
                                    Icon(
                                      Icons.edit,
                                    ),
                                    Text(
                                      "Редактировать",
                                      style: StyleTextCustom().setStyleByEnum(
                                          context, StyleTextEnum.bodyCard),
                                    )
                                  ]),
                                  value: 2,
                                  onTap: () => context
                                      .read<CategoriesScreensBloc>()
                                      .add(CategoryEditEvent(
                                          category: category)),
                                ),
                              );
                              list.add(
                                PopupMenuItem(
                                  child: Row(children: [
                                    !category.favorite
                                        ? Icon(
                                            Icons.favorite_border,
                                          )
                                        : Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                    Text(
                                      category.favorite
                                          ? "Удалить из избранных"
                                          : "Добавить в избранное",
                                      style: StyleTextCustom().setStyleByEnum(
                                          context, StyleTextEnum.bodyCard),
                                    )
                                  ]),
                                  value: 1,
                                  onTap: () {
                                    final _bloc =
                                        context.read<CategoriesScreensBloc>();
                                    _bloc.add(
                                      UpdateFavoriteCategoryEvent(
                                        category: category,
                                      ),
                                    );
                                  },
                                ),
                              );
                              return list;
                            },
                            icon: Icon(
                              Icons.more_vert,
                              size: 24,
                              color: _brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _mySelectedIcon() => ValueListenableBuilder(
        valueListenable: _colorIsLoaded,
        builder: (BuildContext context, bool _isLoaded, _) => _isLoaded
            ? ValueListenableBuilder(
                valueListenable: _colorSelected,
                builder: (BuildContext context, CategoryColor _color, _) =>
                    ValueListenableBuilder(
                  valueListenable: _iconSelected,
                  builder: (BuildContext context, OperationIcon _icon, _) =>
                      Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xFF" + _color.hex.substring(1))),
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(int.parse("0xFF" + _color.hex.substring(1)))
                              .withOpacity(.4),
                          Color(int.parse("0xFF" + _color.hex.substring(1))),
                        ],
                      ),
                    ),
                    child: Center(
                      child: svgIcon(
                        baseUrl + "api/v1/image/content/" + _icon.name,
                        context,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(height: 30, width: 30),
      );

  Widget _familyWidgets({required String title, required Widget child}) =>
      Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 15,
              child: TextWidget(
                padding: 0,
                text: title,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.neutralTextSmall),
                align: TextAlign.center,
              ),
            ),
            child,
          ],
        ),
      );

  Widget _singleIcon({required OperationIcon icon}) {
    return GestureDetector(
      onTap: () => context.read<CategoriesScreensBloc>().add(
            IconChangedEvent(icon: icon),
          ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: StyleColorCustom()
              .setStyleByEnum(context, StyleColorEnum.primaryBackground),
        ),
        margin: const EdgeInsets.only(right: 12),
        height: 32,
        width: 32,
        child: Center(
          child: svgIcon(
            baseUrl + "api/v1/image/content/" + icon.name,
            context,
            color: StyleColorCustom().setStyleByEnum(
                context, StyleColorEnum.primaryBackgroundReverse),
          ),
        ),
      ),
    );
  }

  Widget _singleColor({required CategoryColor color}) => GestureDetector(
        onTap: () => context.read<CategoriesScreensBloc>().add(
              ColorChangedEvent(color: color),
            ),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(int.parse("0xFF" + color.hex.substring(1))),
          ),
          height: 30,
          width: 30,
        ),
      );

  void _resetFields() {
    _sumController.text = "";
    _controller.text = "";
    _iconSelected.value = _iconsList.value.first;
    _colorSelected.value = _colorsList.value.first;
  }

  bottomSheetSort() {
    return CustomBottomSheet.customBottomSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBottomSheet.topDividerBottomSheet(),
          Text(
            "Сортировка:",
            style: TextStyle(
              color:
                  _brightness == Brightness.dark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          _rowBottomSheet("", 0),
          _rowBottomSheet("Доходные", 1),
          _rowBottomSheet("Расходные", 2),
          _rowBottomSheet("Избранные", 3),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  ListTile _rowBottomSheet(String text, int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      minVerticalPadding: 0,
      onTap: () {
        _activeIndexSort.value = index;
        Navigator.pop(context);
      },
      title: Text(
        text.isEmpty ? "По умолчанию" : "Сортировать по: $text",
        style: TextStyle(
          color: _brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      trailing: CircleAvatar(
        radius: 13,
        backgroundColor:
            _activeIndexSort.value == index ? Colors.blue : Colors.grey,
        child: CircleAvatar(
          radius: 11,
          backgroundColor: _activeIndexSort.value != index
              ? _brightness == Brightness.dark
                  ? CustomColors.darkSecondaryBackground
                  : Colors.white
              : Colors.blue,
          child: CircleAvatar(
            radius: 5,
            backgroundColor: _brightness != Brightness.dark
                ? Colors.white
                : CustomColors.darkSecondaryBackground,
          ),
        ),
      ),
    );
  }
}
