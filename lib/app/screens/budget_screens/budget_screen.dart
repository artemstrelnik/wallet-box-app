import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/src/provider.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/constants/string_extension.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/categories_screens/categoies_open/categories_open_page.dart';
import 'package:wallet_box/app/screens/home_screen/widgets/icon_loader.dart';

import '../categories_screens/categoies_open/categories_open_bloc.dart';
import 'budget_screen_bloc.dart';
import 'budget_screen_events.dart';
import 'budget_screen_states.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<List<Transaction>?> _schemeTransactionsList =
      ValueNotifier<List<Transaction>?>(null);
  final ValueNotifier<LoadingState> _schemeLoadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<DateTime?> _titleFromDate =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> _nextIsVisible = ValueNotifier<bool>(false);

  final ValueNotifier<OperationCategory?> _selectedCategory =
      ValueNotifier<OperationCategory?>(null);

  bool isFirstOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<BudgetScreenBloc>().add(
          PageOpenedEvent(),
        );
    initializeDateFormatting("ru");
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
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<BudgetScreenBloc, BudgetScreenState>(
      listener: (context, state) {
        if (state is UpdateTransactionListState) {
          _titleFromDate.value = state.start;
          _schemeTransactionsList.value = state.transaction;
          _nextIsVisible.value = state.index != 0;
          if (state.transaction.isNotEmpty) {
            _schemeLoadingState.value = LoadingState.loaded;
          } else {
            _schemeLoadingState.value = LoadingState.empty;
          }
        }

        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          title: textString_80,
          leading: true,
          actions: true,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListView(
                children: [
                  _headerWidget(),
                  ValueListenableBuilder(
                    valueListenable: _selectedCategory,
                    builder: (BuildContext context,
                            OperationCategory? _selected, _) =>
                        _diagrams(_selected),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _schemeLoadingState,
                    builder: (BuildContext context, LoadingState _state, _) {
                      switch (_state) {
                        case LoadingState.loading:
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case LoadingState.empty:
                        case LoadingState.loaded:
                          return ValueListenableBuilder(
                            valueListenable: _schemeTransactionsList,
                            builder: (BuildContext context,
                                    List<Transaction>? _items, _) =>
                                ValueListenableBuilder(
                              valueListenable: _selectedCategory,
                              builder: (BuildContext context,
                                      OperationCategory? _selected, _) =>
                                  _schemeFront(context, _items, _selected),
                            ),
                          );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _schemeFront(BuildContext _context, List<Transaction>? items,
      OperationCategory? selected) {
    Map<String, Map<String, Transaction>> _byCategory =
        <String, Map<String, Transaction>>{};
    Map<String, OperationCategory> _categories = <String, OperationCategory>{};
    bool isEmpty = true;

    final double _fullPrice = (items != null && items.isNotEmpty)
        ? items
            .map((transaction) => transaction.action ==
                    TransactionTypes.WITHDRAW
                ? (transaction.sum != null
                    ? transaction.sum! * -1
                    : double.parse(
                        "${transaction.amount!.amount}.${transaction.amount!.cents}"))
                : (transaction.sum != null
                    ? transaction.sum!
                    : double.parse(
                        "${transaction.amount!.amount}.${transaction.amount!.cents}")))
            .toList()
            .reduce((a, b) => a + b)
        : 0.0;

    if (items != null && items.isNotEmpty) {
      items.forEach((item) {
        if (item.category != null) {
          if (!_byCategory.containsKey(item.category!.id)) {
            _byCategory[item.category!.id] = <String, Transaction>{};
          }
          _byCategory[item.category!.id]![item.id] = item;
          if (!_categories.containsKey(item.category!.id)) {
            _categories[item.category!.id] = item.category!;
          }
        } else {
          if (!_byCategory.containsKey("deposit")) {
            _byCategory["deposit"] = <String, Transaction>{};
          }
          _byCategory["deposit"]![item.id] = item;
          if (!_categories.containsKey("deposit")) {
            _categories["deposit"] = OperationCategory(
              id: "deposit",
              name: "Наличный",
              color: CategoryColor(
                hex: "#ededed",
                systemName: "ededed",
                name: "ededed",
              ),
              categoryLimit: 0,
            );
          }
        }
      });
      isEmpty = false;
    }

    return Column(
      children: _bottomSlider(
          isEmpty, _byCategory, _categories, items, _fullPrice, selected),
    );
  }

  List<Widget> _bottomSlider(
    bool isEmpty,
    Map<String, Map<String, Transaction>> byCategory,
    Map<String, OperationCategory> categories,
    List<Transaction>? items,
    double fullPrice,
    OperationCategory? selected,
  ) {
    List<Widget> _widgets = [];

    Future.forEach(categories.values, (OperationCategory cat) {
      if (cat.categoryEarn != null && cat.categoryEarn != 0.0) {
        _widgets.add(_singleCategoryInfoWidget(
          cat,
          cat.categoryEarn!,
          selected,
          type: TransactionTypes.EARN,
        ));
      }
      if (cat.categorySpend != null && cat.categorySpend != 0.0) {
        _widgets.add(_singleCategoryInfoWidget(
          cat,
          cat.categorySpend!,
          selected,
          type: TransactionTypes.SPEND,
        ));
      }
    });

    if (categories.isNotEmpty && isFirstOpen == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isFirstOpen = true;
      });
    }

    return _widgets;
  }

  Widget _singleCategoryInfoWidget(
          OperationCategory cat, double reduce, OperationCategory? selected,
          {required TransactionTypes type}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: selected != null && selected.id == cat.id
                      ? Colors.red
                      : Colors.transparent)),
          child: ContainerCustom(
            margin: true,
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (_selectedCategory.value == cat) {
                        _selectedCategory.value = null;
                      } else {
                        _selectedCategory.value = cat;
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                      "0xFF" + cat.color.hex.substring(1))),
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(int.parse("0xFF" +
                                              cat.color.hex.substring(1)))
                                          .withOpacity(.4),
                                      Color(int.parse(
                                          "0xFF" + cat.color.hex.substring(1))),
                                    ],
                                  ),
                                ),
                                child: cat.icon?.name != null
                                    ? Center(
                                        child: svgIcon(
                                          baseUrl +
                                              "api/v1/image/content/" +
                                              cat.icon!.name,
                                          context,
                                        ),
                                      )
                                    : SizedBox(),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextWidget(
                                            padding: 0,
                                            text: cat.name,
                                            style: StyleTextCustom()
                                                .setStyleByEnum(context,
                                                    StyleTextEnum.bodyCard),
                                            align: TextAlign.start,
                                          ),
                                        ),
                                        TextWidget(
                                          padding: 0,
                                          text: (cat.categoryLimit != 0
                                                  ? (reduce.round().abs() /
                                                          (cat.categoryLimit /
                                                              100))
                                                      .toStringAsFixed(1)
                                                  : "0") +
                                              "%",
                                          style: StyleTextCustom()
                                              .setStyleByEnum(context,
                                                  StyleTextEnum.bodyCard),
                                          align: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    TextWidget(
                                      padding: 0,
                                      text: reduce.round().abs().toString() +
                                          " из " +
                                          cat.categoryLimit.toString() +
                                          " ₽",
                                      style: StyleTextCustom().setStyleByEnum(
                                          context, StyleTextEnum.bodyCard),
                                      align: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: type == TransactionTypes.WITHDRAW ||
                                          type == TransactionTypes.SPEND
                                      ? CustomColors.pink
                                      : CustomColors.blue,
                                ),
                              ),
                            ],
                          ),
                          LinearPercentIndicator(
                            padding: const EdgeInsets.only(left: 45, right: 12),
                            // width: 240,
                            lineHeight: 10.0,
                            percent: cat.categoryLimit != 0
                                ? (reduce.round().abs() / cat.categoryLimit) >
                                        1.0
                                    ? 1.0
                                    : (reduce.round().abs() / cat.categoryLimit)
                                : 0.0,
                            progressColor: type == TransactionTypes.WITHDRAW ||
                                    type == TransactionTypes.SPEND
                                ? CustomColors.pink
                                : CustomColors.blue,
                            backgroundColor: StyleColorCustom().setStyleByEnum(
                                context, StyleColorEnum.primaryBackground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => CategoriesOpenBloc(category: cat),
                        child: const CategoriesOpen(),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15, left: 8),
                    child: SvgPicture.asset(AssetsPath.arrowRigth),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget _headerWidget() => ContainerCustom(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.read<BudgetScreenBloc>().add(
                    PageOpenedEvent(prev: true),
                  ),
              child: Icon(
                Icons.chevron_left_outlined,
                color: StyleColorCustom()
                    .setStyleByEnum(context, StyleColorEnum.colorIcon),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _titleFromDate,
              builder: (BuildContext context, DateTime? _date, _) {
                if (_date == null) {
                  return Container();
                }
                var month =
                    DateFormat.MMMM("ru_RU").dateSymbols.STANDALONEMONTHS;
                final DateFormat dateFormat = DateFormat('yyyy', "ru");
                final _title =
                    month[_date.month - 1] + " " + dateFormat.format(_date);
                return TextWidget(
                  padding: 0,
                  text: _title.capitalize(),
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.titleCard),
                  align: TextAlign.center,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: _nextIsVisible,
              builder: (BuildContext context, bool _isActive, _) => _isActive
                  ? GestureDetector(
                      onTap: () => context.read<BudgetScreenBloc>().add(
                            PageOpenedEvent(next: true),
                          ),
                      child: Icon(
                        Icons.chevron_right_outlined,
                        color: StyleColorCustom()
                            .setStyleByEnum(context, StyleColorEnum.colorIcon),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      );

  Widget _consumptionWidget(
      OperationCategory? selected, List<Transaction>? items) {
    List<Transaction> _byCategoryTransactions = [];

    if (items != null && items.isNotEmpty) {
      if (selected != null) {
        _byCategoryTransactions = items
            .where((e) =>
                e.category != null &&
                e.category!.id == selected.id &&
                (e.action == TransactionTypes.WITHDRAW ||
                    e.action == TransactionTypes.SPEND))
            .toList();
      } else {
        _byCategoryTransactions = items
            .where((e) =>
                e.category != null &&
                (e.action == TransactionTypes.WITHDRAW ||
                    e.action == TransactionTypes.SPEND))
            .toList();
      }
    }

    return ContainerCustom(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                padding: 0,
                text: textString_82,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
              TextWidget(
                padding: 0,
                text: textString_83,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.bodyCard),
                align: TextAlign.center,
              ),
              TextWidget(
                padding: 0,
                text: _byCategoryTransactions.isNotEmpty
                    ? _byCategoryTransactions
                        .map((e) => e.sum)
                        .toList()
                        .reduce((a, b) => a! + b!)!
                        .toDouble()
                        .toString()
                    : "0.0" + " ₽",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
              TextWidget(
                padding: 0,
                text: textString_84,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.bodyCard),
                align: TextAlign.center,
              ),
              TextWidget(
                padding: 0,
                text: selected != null
                    ? (selected.forSpend ? (selected.categoryLimit) : 0.0)
                            .toString() +
                        " ₽"
                    : _byCategoryTransactions
                            .map((e) => e.category)
                            .where((e) => e!.forSpend)
                            .toList()
                            .isNotEmpty
                        ? _byCategoryTransactions
                            .map((e) => e.category)
                            .toList()
                            .unique((x) => x!.id)
                            .where((e) => e!.forSpend)
                            .toList()
                            .map((e) => e!.categoryLimit)
                            .toList()
                            .reduce((a, b) => a + b)
                            .toDouble()
                            .toString()
                        : "0.0 ₽",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 55.0,
            lineWidth: 10.0,
            animation: true,
            percent: selected != null
                ? ((selected.categoryLimit) != 0.0 &&
                        _byCategoryTransactions.isNotEmpty &&
                        _byCategoryTransactions
                                .map((e) => e.sum)
                                .toList()
                                .reduce((a, b) => a! + b!)!
                                .toDouble() !=
                            0.0)
                    ? _byCategoryTransactions
                                    .map((e) => e.sum)
                                    .toList()
                                    .reduce((a, b) => a! + b!)!
                                    .toDouble() /
                                (selected.categoryLimit) >
                            1.0
                        ? 1.0
                        : _byCategoryTransactions
                                .map((e) => e.sum)
                                .toList()
                                .reduce((a, b) => a! + b!)!
                                .toDouble() /
                            (selected.categoryLimit)
                    : 0.0
                : _byCategoryTransactions
                        .where((e) => e.category!.forSpend)
                        .toList()
                        .isNotEmpty
                    ? _byCategoryTransactions
                                    .map((e) => e.sum)
                                    .toList()
                                    .reduce((a, b) => a! + b!)!
                                    .toDouble() /
                                _byCategoryTransactions
                                    .where((e) => e.category!.forSpend)
                                    .toList()
                                    .map((e) => e.category!.categoryLimit)
                                    .toList()
                                    .reduce((a, b) => a + b)
                                    .toDouble() >
                            1.0
                        ? 1.0
                        : _byCategoryTransactions
                                .map((e) => e.sum)
                                .toList()
                                .reduce((a, b) => a! + b!)!
                                .toDouble() /
                            _byCategoryTransactions
                                .where((e) => e.category!.forSpend)
                                .toList()
                                .map((e) => e.category!.categoryLimit)
                                .toList()
                                .reduce((a, b) => a + b)
                                .toDouble()
                    : 0.0,
            center: TextWidget(
              padding: 0,
              text: ((selected != null
                              ? ((selected.categoryLimit) != 0.0 &&
                                      _byCategoryTransactions.isNotEmpty &&
                                      _byCategoryTransactions
                                              .map((e) => e.sum)
                                              .toList()
                                              .reduce((a, b) => a! + b!)!
                                              .toDouble() !=
                                          0.0)
                                  ? _byCategoryTransactions
                                                  .map((e) => e.sum)
                                                  .toList()
                                                  .reduce((a, b) => a! + b!)!
                                                  .toDouble() /
                                              (selected.categoryLimit) >
                                          1.0
                                      ? 1.0
                                      : _byCategoryTransactions
                                              .map((e) => e.sum)
                                              .toList()
                                              .reduce((a, b) => a! + b!)!
                                              .toDouble() /
                                          (selected.categoryLimit)
                                  : 0.0
                              : _byCategoryTransactions
                                      .where((e) => e.category!.forSpend)
                                      .toList()
                                      .isNotEmpty
                                  ? _byCategoryTransactions
                                          .map((e) => e.sum)
                                          .toList()
                                          .reduce((a, b) => a! + b!)!
                                          .toDouble() /
                                      _byCategoryTransactions
                                          .where((e) => e.category!.forSpend)
                                          .toList()
                                          .map((e) => e.category!.categoryLimit)
                                          .toList()
                                          .reduce((a, b) => a + b)
                                          .toDouble()
                                  : 0.0) *
                          100)
                      .toStringAsFixed(1) +
                  "%",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.indicator),
              align: TextAlign.center,
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: CustomColors.pink,
          ),
        ],
      ),
    );
  }

  Widget _depositWidget(OperationCategory? selected, List<Transaction>? items) {
    List<Transaction> _byCategoryTransactions = [];

    if (items != null && items.isNotEmpty) {
      if (selected != null) {
        _byCategoryTransactions = items
            .where((e) =>
                e.category != null &&
                e.category!.id == selected.id &&
                (e.action == TransactionTypes.DEPOSIT ||
                    e.action == TransactionTypes.EARN))
            .toList();
      } else {
        _byCategoryTransactions = items
            .where((e) =>
                e.category != null &&
                (e.action == TransactionTypes.DEPOSIT ||
                    e.action == TransactionTypes.EARN))
            .toList();
      }
    }

    return ContainerCustom(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              padding: 0,
              text: textString_86,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
              align: TextAlign.center,
            ),
            TextWidget(
              padding: 0,
              text: textString_83,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.bodyCard),
              align: TextAlign.center,
            ),
            TextWidget(
              padding: 0,
              text: _byCategoryTransactions.isNotEmpty
                  ? _byCategoryTransactions
                      .map((e) => e.sum)
                      .toList()
                      .reduce((a, b) => a! + b!)!
                      .toDouble()
                      .toString()
                  : "0.0" + " ₽",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
              align: TextAlign.center,
            ),
            TextWidget(
              padding: 0,
              text: textString_84,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.bodyCard),
              align: TextAlign.center,
            ),
            TextWidget(
              padding: 0,
              text: selected != null
                  ? (selected.forEarn ? (selected.categoryLimit) : 0.0)
                          .toString() +
                      " ₽"
                  : _byCategoryTransactions
                          .map((e) => e.category)
                          .where((e) => e!.forEarn)
                          .toList()
                          .isNotEmpty
                      ? _byCategoryTransactions
                          .map((e) => e.category)
                          .toList()
                          .unique((x) => x!.id)
                          .where((e) => e!.forEarn)
                          .toList()
                          .map((e) => e!.categoryLimit)
                          .toList()
                          .reduce((a, b) => a + b)
                          .toDouble()
                          .toString()
                      : "0.0 ₽",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
              align: TextAlign.center,
            ),
          ],
        ),
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 10.0,
          animation: true,
          percent: selected != null
              ? ((selected.categoryLimit) != 0.0 &&
                      _byCategoryTransactions.isNotEmpty &&
                      _byCategoryTransactions
                              .map((e) => e.sum)
                              .toList()
                              .reduce((a, b) => a! + b!)!
                              .toDouble() !=
                          0.0)
                  ? _byCategoryTransactions
                                  .map((e) => e.sum)
                                  .toList()
                                  .reduce((a, b) => a! + b!)!
                                  .toDouble() /
                              (selected.categoryLimit) >
                          1.0
                      ? 1.0
                      : _byCategoryTransactions
                              .map((e) => e.sum)
                              .toList()
                              .reduce((a, b) => a! + b!)!
                              .toDouble() /
                          (selected.categoryLimit)
                  : 0.0
              : _byCategoryTransactions
                      .where((e) => e.category!.forEarn)
                      .toList()
                      .isNotEmpty
                  ? _byCategoryTransactions
                                  .map((e) => e.sum)
                                  .toList()
                                  .reduce((a, b) => a! + b!)!
                                  .toDouble() /
                              _byCategoryTransactions
                                  .where((e) => e.category!.forEarn)
                                  .toList()
                                  .map((e) => e.category!.categoryLimit)
                                  .toList()
                                  .reduce((a, b) => a + b)
                                  .toDouble() >
                          1.0
                      ? 1.0
                      : _byCategoryTransactions
                              .map((e) => e.sum)
                              .toList()
                              .reduce((a, b) => a! + b!)!
                              .toDouble() /
                          _byCategoryTransactions
                              .where((e) => e.category!.forEarn)
                              .toList()
                              .map((e) => e.category!.categoryLimit)
                              .toList()
                              .reduce((a, b) => a + b)
                              .toDouble()
                  : 0.0,
          center: TextWidget(
            padding: 0,
            text: ((selected != null
                            ? ((selected.categoryLimit) != 0.0 &&
                                    _byCategoryTransactions.isNotEmpty &&
                                    _byCategoryTransactions
                                            .map((e) => e.sum)
                                            .toList()
                                            .reduce((a, b) => a! + b!)!
                                            .toDouble() !=
                                        0.0)
                                ? _byCategoryTransactions
                                                .map((e) => e.sum)
                                                .toList()
                                                .reduce((a, b) => a! + b!)!
                                                .toDouble() /
                                            (selected.categoryLimit) >
                                        1.0
                                    ? 1.0
                                    : _byCategoryTransactions
                                            .map((e) => e.sum)
                                            .toList()
                                            .reduce((a, b) => a! + b!)!
                                            .toDouble() /
                                        (selected.categoryLimit)
                                : 0.0
                            : _byCategoryTransactions
                                    .where((e) => e.category!.forEarn)
                                    .toList()
                                    .isNotEmpty
                                ? _byCategoryTransactions
                                        .map((e) => e.sum)
                                        .toList()
                                        .reduce((a, b) => a! + b!)!
                                        .toDouble() /
                                    _byCategoryTransactions
                                        .where((e) => e.category!.forEarn)
                                        .toList()
                                        .map((e) => e.category!.categoryLimit)
                                        .toList()
                                        .reduce((a, b) => a + b)
                                        .toDouble()
                                : 0.0) *
                        100)
                    .toStringAsFixed(1) +
                "%",
            style: StyleTextCustom()
                .setStyleByEnum(context, StyleTextEnum.indicator),
            align: TextAlign.center,
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: CustomColors.blue,
        ),
      ]),
    );
  }

  Widget _diagrams(OperationCategory? selected) {
    return ValueListenableBuilder(
      valueListenable: _schemeTransactionsList,
      builder: (BuildContext context, List<Transaction>? items, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _consumptionWidget(selected, items),
            _depositWidget(selected, items),
          ],
        );
      },
    );
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}
