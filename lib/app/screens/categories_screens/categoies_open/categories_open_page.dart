import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string_extension.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/screens/categories_screens/categoies_open/categories_open_events.dart';
import 'package:wallet_box/app/screens/home_screen/widgets/icon_loader.dart';

import '../../../core/themes/colors.dart';
import '../../add_operation_screens/add_operation_screen.dart';
import '../../add_operation_screens/add_operation_screen_bloc.dart';
import 'categories_open_bloc.dart';
import 'categories_open_states.dart';

class CategoriesOpen extends StatefulWidget {
  const CategoriesOpen({Key? key}) : super(key: key);

  @override
  _CategoriesOpenState createState() => _CategoriesOpenState();
}

class _CategoriesOpenState extends State<CategoriesOpen> with ScreenLoader {
  final ValueNotifier<OperationCategory?> _category =
      ValueNotifier<OperationCategory?>(null);
  final ValueNotifier<List<Transaction>> _transactionList =
      ValueNotifier<List<Transaction>>(<Transaction>[]);
  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<DateTime?> _titleFromDate =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<bool> _nextIsVisible = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<CategoriesOpenBloc>().add(PageOpenedEvent());
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
    return BlocListener<CategoriesOpenBloc, CategoriesOpenState>(
      listener: (context, state) {
        if (state is SetBaseCategory) {
          _category.value = state.category;
        }
        if (state is UpdateTransactionList) {
          _titleFromDate.value = state.start;
          _nextIsVisible.value = state.index != 0;
          if (state.transaction != null && state.transaction!.isNotEmpty) {
            _transactionList.value = state.transaction!;
            _loadingState.value = LoadingState.loaded;
          } else {
            _loadingState.value = LoadingState.empty;
          }
        }
        if (state is CloseDialogState) {
          Navigator.pop(context);
        }
        if (state is NeedUpdateBillsListState) {
          context.read<CategoriesOpenBloc>().add(
                PageOpenedEvent(),
              );
        }
        if (state is ListLoadingOpacityState) startLoading();
        if (state is ListLoadingOpacityHideState) stopLoading();
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => ValueListenableBuilder(
        valueListenable: _category,
        builder: (BuildContext context, OperationCategory? _cat, _) => _cat ==
                null
            ? const SafeArea(
                child: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ))
            : ScaffoldAppBarCustom(
                header: _cat.name,
                leading: true,
                actions: true,
                svgIcon: Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color:
                        Color(int.parse("0xFF" + _cat.color.hex.substring(1))),
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse("0xFF" + _cat.color.hex.substring(1)))
                            .withOpacity(.4),
                        Color(int.parse("0xFF" + _cat.color.hex.substring(1))),
                      ],
                    ),
                  ),
                  child: _cat.icon?.name != null
                      ? Center(
                          child: svgIcon(
                            baseUrl + "api/v1/image/content/" + _cat.icon!.name,
                            context,
                          ),
                        )
                      : SizedBox(),
                ),
                body: ValueListenableBuilder(
                  valueListenable: _loadingState,
                  builder: (BuildContext context, LoadingState _state, _) =>
                      _state == LoadingState.loaded
                          ? SingleChildScrollView(
                              child: _body(
                              state: _state,
                            ))
                          : _body(
                              state: _state,
                            ),
                ),
              ),
      );

  Widget _singleTransaction(BuildContext _context,
      {required Transaction transaction}) {
    String _color = transaction.category != null
        ? transaction.category!.color.hex.substring(1)
        : "ededed";

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: transaction.bill?.bankName == null
                ? <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                      child: const Text('Изменить'),
                      onPressed: () async {
                        Navigator.pop(context);
                        final bool? returnBack = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: '/add_operation_screen'),
                            builder: (_) => BlocProvider(
                              create: (context) => AddOperationScreenBloc(),
                              child: AddOperationScreen(
                                isEditing: true,
                                transaction: transaction,
                              ),
                            ),
                          ),
                        );
                        // if (returnBack != null && returnBack) {
                        _context.read<CategoriesOpenBloc>().add(
                              PageOpenedEvent(),
                            );
                        // }
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: const Text('Удалить'),
                      onPressed: () async {
                        _context.read<CategoriesOpenBloc>().add(
                              RemoveTransaction(transaction: transaction.id),
                            );
                      },
                    ),
                  ]
                : [
                    CupertinoActionSheetAction(
                      child: const Text('Изменить'),
                      onPressed: () async {
                        Navigator.pop(context);
                        final bool? returnBack = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: '/add_operation_screen'),
                            builder: (_) => BlocProvider(
                              create: (context) => AddOperationScreenBloc(),
                              child: AddOperationScreen(
                                isEditing: true,
                                transaction: transaction,
                              ),
                            ),
                          ),
                        );
                        // if (returnBack != null && returnBack) {
                        _context.read<CategoriesOpenBloc>().add(
                              PageOpenedEvent(),
                            );
                        // }
                      },
                    ),
                  ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ContainerCustom(
          margin: true,
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Color(int.parse("0xFF" + _color)),
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(int.parse("0xFF" + _color)).withOpacity(.4),
                            Color(int.parse("0xFF" + _color)),
                          ],
                        ),
                      ),
                      child: Center(
                          child: transaction.category != null &&
                                  transaction.category!.icon?.name != null
                              ? svgIcon(
                                  baseUrl +
                                      "api/v1/image/content/" +
                                      transaction.category!.icon!.name,
                                  context,
                                )
                              : transaction.bill!.status != null
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: transaction.bill!.bankName!.icon(),
                                    )
                                  : const Icon(Icons.plus_one)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: transaction.status != null
                            ? [
                                _textWidget(
                                  padding: 0,
                                  text: transaction.description!,
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.bodyCard),
                                  align: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                _textWidget(
                                  padding: 0,
                                  text: "**** " +
                                      transaction.bill!.cardNumber!.substring(
                                          transaction.bill!.cardNumber!.length -
                                              4),
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.bodyCard),
                                  align: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ]
                            : [
                                _textWidget(
                                  padding: 0,
                                  text: transaction.category!.name,
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.bodyCard),
                                  align: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                _textWidget(
                                  padding: 0,
                                  text: transaction.billName != null
                                      ? transaction.billName!
                                      : "Счет",
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.bodyCard),
                                  align: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
              TextWidget(
                padding: 0,
                text: (transaction.action == TransactionTypes.WITHDRAW ||
                            transaction.action == TransactionTypes.SPEND
                        ? "-"
                        : "") +
                    (transaction.sum != null &&
                                transaction.sum != 0 &&
                                transaction.sum != 0
                            ? transaction.sum!.abs().roundToDouble()
                            : double.parse(
                                    "${transaction.amount!.amount}.${transaction.amount!.cents}")
                                .abs()
                                .roundToDouble())
                        .toString() +
                    " ₽",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body({required LoadingState state}) {
    switch (state) {
      case LoadingState.empty:
        return Column(
          children: [
            _headerDate(),
            _headerWidget(),
            Expanded(
                child: Center(
              child: TextWidget(
                padding: 0,
                text: "Вы еще не совершали транзакций в этой категории",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
            ))
          ],
        );
      case LoadingState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      default:
        return Column(
          children: [
            _headerDate(),
            _headerWidget(),
            _transactionListWidget(),
          ],
        );
    }
  }

  ContainerCustom _headerDate() {
    return ContainerCustom(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_category.value != null && _category.value!.forSpend)
                  Row(
                    children: [
                      TextWidget(
                        padding: 0,
                        text: "Средний расход: ",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.bodyCard),
                      ),
                      TextWidget(
                        padding: 0,
                        text: "${_category.value!.categorySpend}",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard),
                      ),
                    ],
                  ),
                if (_category.value != null && _category.value!.forEarn)
                  Row(
                    children: [
                      TextWidget(
                        padding: 0,
                        text: "Средний доход: ",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.bodyCard),
                      ),
                      TextWidget(
                        padding: 0,
                        text: "${_category.value!.categoryEarn}",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard),
                      ),
                    ],
                  ),
              ],
            ),
          );
  }

  _textWidget({
    double? padding,
    required String text,
    required TextStyle style,
    TextAlign? align,
    TextOverflow overflow = TextOverflow.visible,
  }) =>
      Padding(
        padding: EdgeInsets.only(top: padding ?? 10),
        child: Text(
          text,
          textAlign: align ?? TextAlign.left,
          style: style,
          overflow: overflow,
          maxLines: 1,
        ),
      );

  Widget _transactionListWidget() => ValueListenableBuilder(
        valueListenable: _transactionList,
        builder: (BuildContext context, List<Transaction> _transactions, _) {
          Map<String, Map<String, Transaction>> _historyList =
              <String, Map<String, Transaction>>{};

          DateTime now = DateTime.now();
          String toDay = DateFormat("dd.MM.yyyy").format(DateTime.now());
          String yesterDay = DateFormat("dd.MM.yyyy")
              .format(DateTime(now.year, now.month, now.day - 1));

          _transactions.forEach((transaction) {
            final String berlinWallFellDate = DateFormat("dd.MM.yyyy").format(
                DateTime.parse(transaction.createAt != null
                    ? transaction.createAt!
                    : transaction.date!));
            if (berlinWallFellDate.compareTo(toDay) == 0) {
              if (!_historyList.containsKey("Сегодня")) {
                _historyList["Сегодня"] = <String, Transaction>{};
              }
              _historyList["Сегодня"]![transaction.id] = transaction;
            } else if (berlinWallFellDate.compareTo(yesterDay) == 0) {
              if (!_historyList.containsKey("Вчера")) {
                _historyList["Вчера"] = <String, Transaction>{};
              }
              _historyList["Вчера"]![transaction.id] = transaction;
            } else {
              final String _date = DateFormat("dd.MM.yyyy").format(
                  DateTime.parse(transaction.createAt != null
                      ? transaction.createAt!
                      : transaction.date!));
              if (!_historyList.containsKey(_date)) {
                _historyList[_date] = <String, Transaction>{};
              }
              _historyList[_date]![transaction.id] = transaction;
            }
          });

          List<Widget> _list = <Widget>[];

          final _reverseHistoryList =
              LinkedHashMap.fromEntries(_historyList.entries.toList().reversed);
          _reverseHistoryList.forEach(
            (key, value) => _list.add(
              _familyList(
                day: key,
                list: value.values
                    .map((e) => _singleTransaction(context, transaction: e))
                    .toList(),
              ),
            ),
          );
          return Column(children: _list);
        },
      );

  Widget _familyDay({required String title}) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 15),
        child: TextWidget(
          padding: 0,
          text: title,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.titleCard),
          align: TextAlign.center,
        ),
      );

  Widget _familyList({required String day, required List<Widget> list}) =>
      Column(
        children: [_familyDay(title: day), ...list],
      );

  _headerWidget() => ContainerCustom(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.read<CategoriesOpenBloc>().add(
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
                      onTap: () => context.read<CategoriesOpenBloc>().add(
                            PageOpenedEvent(next: true),
                          ),
                      child: Icon(
                        Icons.chevron_right_outlined,
                        color: StyleColorCustom()
                            .setStyleByEnum(context, StyleColorEnum.colorIcon),
                      ),
                    )
                  : Container(
                      width: 24,
                    ),
            ),
          ],
        ),
      );
}
