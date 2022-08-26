import 'dart:async';
import 'dart:collection';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/constants/string_extension.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/down_to_up_animation.dart';
import 'package:wallet_box/app/core/generals_widgets/right_to_left_animation.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/categories_colors_model.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_bloc.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen_bloc.dart';
import 'package:wallet_box/app/screens/budget_screens/budget_screen.dart';
import 'package:wallet_box/app/screens/budget_screens/budget_screen_bloc.dart';
import 'package:wallet_box/app/screens/cards_screens/card_screen.dart';
import 'package:wallet_box/app/screens/cards_screens/card_screen_bloc.dart';
import 'package:wallet_box/app/screens/categories_screens/categories_screens_bloc.dart';
import 'package:wallet_box/app/screens/categories_screens/categories_screens_page.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_page.dart';
import 'package:wallet_box/app/screens/tochka_webview/tochka_webview.dart';

import '../../data/net/models/permission_role_provider.dart';
import 'home_screen_bloc.dart';
import 'home_screen_events.dart';
import 'home_screen_states.dart';
import 'widgets/icon_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.type}) : super(key: key);
  final OperationType? type;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ScreenLoader {
  int touchedIndex = -1;

  final ValueNotifier<List<Transaction>?> _transactionList =
      ValueNotifier<List<Transaction>?>(null);
  final ValueNotifier<List<Bill>?> _billsList =
      ValueNotifier<List<Bill>?>(null);
  final ValueNotifier<LoadingState> _billLoadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<List<Transaction>?> _schemeTransactionsList =
      ValueNotifier<List<Transaction>?>(null);
  final ValueNotifier<LoadingState> _schemeLoadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);

  final ValueNotifier<CalendarSortTypes> _sortTypeState =
      ValueNotifier<CalendarSortTypes>(CalendarSortTypes.currentMonth);

  final ValueNotifier<bool> _nextIsVisible = ValueNotifier<bool>(false);

  final ValueNotifier<String> _selectedBill = ValueNotifier<String>("");

  final ValueNotifier<bool> _calendarPicked = ValueNotifier<bool>(false);
  Timer? _debounce;
  DateRangePickerController controller = DateRangePickerController();
  late UserNotifierProvider _userProvider;
  late Brightness _brightness;

  DateTime? _start;
  DateTime? _end;
  DateTime? _startRange;
  DateTime? _endRange;
  late DateFormat dateFormat;
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '### ### ### ### ### ### ###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    context.read<HomeScreenBloc>().add(PageOpenedEvent(
        user: _userProvider, isExpense: _userProvider.isEarnActive));
    if (widget.type != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _openOperation(context);
      });
    }
    initializeDateFormatting("ru");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _openOperation(BuildContext context) async {
    final bool? returnBack = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: '/add_operation_screen'),
        builder: (_) => BlocProvider(
          create: (context) => AddOperationScreenBloc(),
          child: AddOperationScreen(type: widget.type),
        ),
      ),
    );
    if (returnBack != null && returnBack) {
      context
          .read<HomeScreenBloc>()
          .add(PageOpenedEvent(isExpense: _userProvider.isEarnActive));
    }
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
    return BlocListener<HomeScreenBloc, HomeScreenState>(
      listener: (context, state) {
        if (state is UpdateSelectedBill) {
          _selectedBill.value = state.bill;
        }
        if (state is UpdateTransactionList) {
          _transactionList.value = state.transaction;
        }
        if (state is UpdateUserState) {
          _userProvider.setUser = state.user;
        }
        if (state is UpdateBillList) {
          if (state.bills.isNotEmpty) {
            _billsList.value = state.bills;
            _billLoadingState.value = LoadingState.loaded;
          } else {
            _billLoadingState.value = LoadingState.empty;
            _schemeLoadingState.value = LoadingState.empty;
          }
        }
        if (state is UpdateSchemeState) {
          _nextIsVisible.value = state.index != 0;
          _start = state.start;
          _end = state.end;
          _schemeTransactionsList.value = [];
          _schemeTransactionsList.value = state.transaction;

          _sortTypeState.value = state.sort;
          if (state.transaction.isNotEmpty) {
            _schemeLoadingState.value = LoadingState.loaded;
          } else {
            _schemeLoadingState.value = LoadingState.empty;
          }
          if (state.sort == CalendarSortTypes.rangeDates) {
            controller.selectedRange = PickerDateRange(state.start, state.end);
          } else {
            controller.selectedRange = null;
          }
        }
        if (state is CloseDialogState) {
          Navigator.pop(context);
        }
        if (state is NeedUpdateBillsListState) {
          context
              .read<HomeScreenBloc>()
              .add(PageOpenedEvent(isExpense: _userProvider.isEarnActive));
        }
        if (state is ListLoadingOpacityState) startLoading();
        if (state is ListLoadingOpacityHideState) stopLoading();
      },
      child: _scaffold(context),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      if (args.value != null) {
        PickerDateRange _picker = args.value as PickerDateRange;
        if (_picker.endDate != null && _picker.startDate != null) {
          _startRange = _picker.startDate;
          _endRange = _picker.endDate;
          _calendarPicked.value = true;
          return;
        }
      }
    }
    _calendarPicked.value = false;
    _startRange = null;
    _endRange = null;
  }

  Future<void> share() async {
    showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoShareBottomSheet(),
    );
  }

  Widget _scaffold(BuildContext _context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          margin: false,
          appBar: false,
          //onTap: share,
          body: GestureDetector(
            onTap: () {
              if (touchedIndex != -1) {
                setState(() {
                  touchedIndex = -1;
                });
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          _billsListWidget(),
                          DownToUp(delay: 2.5, child: _schemeWidget(context)),
                        ],
                      ),
                    ),
                    DownToUp(delay: 3, child: _transactionListWidget()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ContainerCustom(
                        turnColor: false,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => BudgetScreenBloc(),
                                    child: BudgetScreen(),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: CustomColors.listGradienAction,
                                    ).createShader(bounds);
                                  },
                                  child: SvgPicture.asset(
                                    menuOne,
                                    width: 25,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (context) =>
                                          CategoriesScreensBloc(),
                                      child: const CategoriseScreensPage(),
                                    ),
                                  ),
                                );
                                context.read<HomeScreenBloc>().add(
                                      PageOpenedEvent(
                                          isExpense:
                                              _userProvider.isEarnActive),
                                    );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: CustomColors.listGradienAction,
                                    ).createShader(bounds);
                                  },
                                  child: SvgPicture.asset(
                                    menuTwo,
                                    width: 25,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => CardScreenBloc(),
                                    child: CardScreen(),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: CustomColors.listGradienAction,
                                    ).createShader(bounds);
                                  },
                                  child: SvgPicture.asset(
                                    menuThree,
                                    width: 25,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                // final bool? returnBack =
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (context) => SettingScreenBloc(),
                                      child: const SettingScreen(),
                                    ),
                                  ),
                                );
                                context.read<HomeScreenBloc>().add(
                                      PageOpenedEvent(
                                          isExpense:
                                              _userProvider.isEarnActive),
                                    );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      colors: CustomColors.listGradienAction,
                                    ).createShader(bounds);
                                  },
                                  child: SvgPicture.asset(
                                    menuFour,
                                    width: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final bool? returnBack = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings:
                                  RouteSettings(name: '/add_operation_screen'),
                              builder: (_) => BlocProvider(
                                create: (context) => AddOperationScreenBloc(),
                                child: const AddOperationScreen(),
                              ),
                            ),
                          );
                          if (returnBack != null && returnBack) {
                            context.read<HomeScreenBloc>().add(PageOpenedEvent(
                                isExpense: _userProvider.isEarnActive));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                                colors: CustomColors.listGradienAction),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget _transactionListWidget() => ValueListenableBuilder(
        valueListenable: _transactionList,
        builder: (BuildContext context, List<Transaction>? _transactions, _) {
          if (_transactions == null || _transactions.isEmpty)
            return Container();

          Map<String, Map<String, Transaction>> _historyList =
              <String, Map<String, Transaction>>{};

          DateTime now = DateTime.now();
          String toDay = DateFormat("dd.MM.yyyy").format(DateTime.now());
          String yesterDay = DateFormat("dd.MM.yyyy")
              .format(DateTime(now.year, now.month, now.day - 1));

          _transactions.forEach((transaction) {
            final String berlinWallFellDate = DateFormat("dd.MM.yyyy").format(
                DateTime.parse(transaction.createAt ?? transaction.date!));
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
                  DateTime.parse(transaction.createAt ?? transaction.date!));
              if (!_historyList.containsKey(_date)) {
                _historyList[_date] = <String, Transaction>{};
              }
              _historyList[_date]![transaction.id] = transaction;
            }
          });

          List<Widget> _list = <Widget>[];

          if (_historyList.containsKey("Сегодня")) {
            _list.add(
              _familyList(
                day: "Сегодня",
                list: _historyList["Сегодня"]!
                    .values
                    .map((e) => _singleTransaction(context, transaction: e))
                    .toList(),
              ),
            );
            _historyList.removeWhere((key, value) => key == "Сегодня");
          }
          if (_historyList.containsKey("Вчера")) {
            _list.add(
              _familyList(
                day: "Вчера",
                list: _historyList["Вчера"]!
                    .values
                    .map((e) => _singleTransaction(context, transaction: e))
                    .toList(),
              ),
            );
            _historyList.removeWhere((key, value) => key == "Вчера");
          }

          List<DateTime> sortedKeys = _historyList.keys
              .map((e) => DateTime.parse(e.split(".").reversed.join("-")))
              .toList()
            ..sort();

          Map<String, Map<String, Transaction>> _newHistory =
              <String, Map<String, Transaction>>{};
          sortedKeys.forEach((e) => _newHistory[
                  e.toString().split(" ").first.split("-").reversed.join(".")] =
              _historyList[e
                  .toString()
                  .split(" ")
                  .first
                  .split("-")
                  .reversed
                  .join(".")]!);

          final _reverseHistoryList =
              LinkedHashMap.fromEntries(_newHistory.entries.toList().reversed);
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ContainerCustom(
              margin: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 95),
                child: Column(
                  children: _list,
                ),
              ),
            ),
          );
        },
      );

  Widget _familyDay({required String title}) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextWidget(
          text: title,
          style: StyleTextCustom()
              .setStyleByEnum(context, StyleTextEnum.neutralText),
          align: TextAlign.center,
        ),
      );

  Widget _familyList({required String day, required List<Widget> list}) =>
      Column(
        children: [_familyDay(title: day), ...list],
      );

  Widget _singleTransaction(BuildContext _context,
      {required Transaction transaction}) {
    String _color = transaction.category != null
        ? transaction.category!.color.hex.substring(1)
        : "ededed";

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        final _bill =
            _billsList.value!.where((e) => e.id == transaction.billId).first;

        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: transaction.bill?.bankName == null
                ? <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                      child: const Text('Изменить'),
                      onPressed: () async {
                        Navigator.pop(context);
                        // final bool? returnBack =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: '/add_operation_screen'),
                            builder: (_) => BlocProvider(
                              create: (context) => AddOperationScreenBloc(),
                              child: AddOperationScreen(
                                isEditing: true,
                                transaction:
                                    Transaction.clone(transaction, _bill),
                              ),
                            ),
                          ),
                        );
                        // if (returnBack != null && returnBack) {
                        _context.read<HomeScreenBloc>().add(
                              PageOpenedEvent(
                                  isExpense: _userProvider.isEarnActive),
                            );
                        // }
                      },
                    ),
                    CupertinoActionSheetAction(
                      child: const Text('Удалить'),
                      onPressed: () async {
                        _context.read<HomeScreenBloc>().add(
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
                        // final bool? returnBack =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings:
                                RouteSettings(name: '/add_operation_screen'),
                            builder: (_) => BlocProvider(
                              create: (context) => AddOperationScreenBloc(),
                              child: AddOperationScreen(
                                isEditing: true,
                                transaction:
                                    Transaction.clone(transaction, _bill),
                              ),
                            ),
                          ),
                        );
                        // if (returnBack != null && returnBack) {
                        _context.read<HomeScreenBloc>().add(
                              PageOpenedEvent(
                                  isExpense: _userProvider.isEarnActive),
                            );
                        // }
                      },
                    ),
                  ],
          ),
        );
      },
      child: ContainerCustom(
        margin: true,
        padding: const EdgeInsets.only(top: 16, left: 15, right: 15),
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
                            : transaction.bill?.status != null
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
                                text: transaction.category?.name ??
                                    transaction.description ??
                                    "Операция",
                                style: StyleTextCustom().setStyleByEnum(
                                    context, StyleTextEnum.bodyCard),
                                align: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              _textWidget(
                                padding: 0,
                                text: transaction.bill != null
                                    ? transaction.bill!.name
                                    : transaction.billName ?? "Счет",
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
                                  "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
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
    );
  }

  Widget _fullSumCard({double balance = 0}) {
    final _balance = balance.toStringAsFixed(2);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => context.read<HomeScreenBloc>().add(
            UpdateSortEvent(
                sort: _sortTypeState.value,
                billChange: true,
                isExpense: _userProvider.isEarnActive),
          ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: ContainerCustom(
          padding: const EdgeInsets.all(5),
          gradient: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0, top: 2.0),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: TextWidget(
                      padding: 0,
                      text: textString_60,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.white),
                    ),
                  ),
                  PopupMenuButton<String>(
                      color: StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.secondaryBackground,
                      ),
                      child: Icon(Icons.more_horiz),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  _userProvider.isHiddenBills
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _userProvider.isHiddenBills
                                      ? "Скрыть скрытые"
                                      : "Показать скрытые",
                                  style: StyleTextCustom().setStyleByEnum(
                                    context,
                                    StyleTextEnum.bodyCard,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              _userProvider.isHiddenBills
                                  ? _userProvider.setIsHiddenBills = false
                                  : _userProvider.setIsHiddenBills = true;
                            },
                          ),
                        ];
                      }),
                ],
              ),
              TextWidget(
                align: TextAlign.end,
                padding: 0,
                text: (maskFormatter
                            .maskText(_balance
                                .toString()
                                .split(".")
                                .first
                                .split("")
                                .reversed
                                .join(""))
                            .split("")
                            .reversed
                            .join("") +
                        "," +
                        _balance.toString().split(".").last) +
                    " ₽",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addNewBill() => GestureDetector(
        onTap: () async {
          // final bool? returnBack =
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AddInvoiceBloc(),
                child: const AddInvoice(),
              ),
            ),
          );
          // if (returnBack != null && returnBack) {
          context.read<HomeScreenBloc>().add(
                PageOpenedEvent(isExpense: _userProvider.isEarnActive),
              );
          // }
        },
        child: Container(
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 5,
          ),
          width: 200,
          decoration: BoxDecoration(
            color: StyleColorCustom().setStyleByEnum(
              context,
              StyleColorEnum.secondaryBackground,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget(
                align: TextAlign.end,
                padding: 0,
                text: "Добавить счет",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.bodyCard)
                    .copyWith(
                      fontSize: 14,
                      height: 17 / 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 9),
                child: SvgPicture.asset(AssetsPath.plusBill),
              )
            ],
          ),
        ),
      );

  Widget _billsListWidget() => ValueListenableBuilder(
        valueListenable: _selectedBill,
        builder: (BuildContext context, String _selectedBillValue, _) =>
            ValueListenableBuilder(
          valueListenable: _billLoadingState,
          builder: (BuildContext context, LoadingState _state, _) =>
              ValueListenableBuilder(
            valueListenable: _billsList,
            builder: (BuildContext context, List<Bill>? _items, _) {
              late Widget _child;

              final double _price = _items
                      ?.map((bill) => double.parse((bill.balance).toString()))
                      // "." +
                      // ((bill.balance?.cents ?? 0) != null
                      //     ? (bill.balance?.cents ?? 0).toString()
                      //     : "00")))
                      .toList()
                      .reduce((a, b) => a + b) ??
                  0.0;

              switch (_state) {
                case LoadingState.loading:
                  _child = const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                  break;
                case LoadingState.empty:
                  _child = Container();
                  break;
                case LoadingState.loaded:
                  _child = Row(
                    children: [
                      RightToLeft(
                        delay: 0.5,
                        child: _fullSumCard(balance: _price),
                      ),
                      for (int i = 0; i < _items!.length; i++)
                        _singleBillCard(
                          context,
                          index: i,
                          bill: _items[i],
                          isActive: _selectedBillValue == _items[i].id,
                        )
                    ],
                  );
                  break;
              }

              return SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 20),
                    _child,
                    _addNewBill(),
                    const SizedBox(width: 20),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _singleBillCard(
    BuildContext _context, {
    required int index,
    required Bill bill,
    bool isActive = false,
  }) {
    final _balance = (bill.balance).toStringAsFixed(2);
    return RightToLeft(
      delay: index + 1,
      child: Selector<UserNotifierProvider, bool>(
          builder: (context, isHiddenState, _) => bill.hidden &&
                  (!isHiddenState)
              ? SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    _context.read<HomeScreenBloc>().add(
                          UpdateSortEvent(
                              sort: _sortTypeState.value,
                              //bill: bill,
                              billId: bill.id,
                              isExpense: _userProvider.isEarnActive),
                        );
                  },
                  onLongPress: () {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        actions: bill.bankName == null
                            ? [
                                CupertinoActionSheetAction(
                                  child: const Text('Изменить'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    // final bool? returnBack =
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                            create: (context) =>
                                                AddInvoiceBloc(),
                                            child: AddInvoice(
                                                isEditing: true,
                                                id: bill.id,
                                                name: bill.name,
                                                balance:
                                                    bill.balance.toString())
                                            // "." +
                                            // (bill.balance?.cents ?? 0).toString()),
                                            ),
                                      ),
                                    );
                                    // if (returnBack != null && returnBack) {
                                    _context.read<HomeScreenBloc>().add(
                                        PageOpenedEvent(
                                            isExpense:
                                                _userProvider.isEarnActive));
                                    // }
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: const Text('Удалить'),
                                  onPressed: () {
                                    _context
                                        .read<HomeScreenBloc>()
                                        .add(BillRemoveEvent(billId: bill.id));
                                  },
                                )
                              ]
                            : [
                                CupertinoActionSheetAction(
                                  child: const Text('Обновить'),
                                  onPressed: () {
                                    _context.read<HomeScreenBloc>().add(
                                        BankBillUpdateEvent(
                                            bank: bill.bankName));
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: const Text('Удалить'),
                                  onPressed: () {
                                    _context.read<HomeScreenBloc>().add(
                                        BankBillRemoveEvent(
                                            bank: bill.bankName));
                                  },
                                ),
                              ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 10, right: 10, left: 10),
                    margin:
                        const EdgeInsets.only(top: 10, bottom: 5, right: 12),
                    width: 200,
                    decoration: BoxDecoration(
                      color: StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.secondaryBackground,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isActive
                            ? Colors.red
                            : StyleColorCustom().setStyleByEnum(
                                context,
                                StyleColorEnum.secondaryBackground,
                              ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: bill.bankName != null
                                  ? SizedBox(
                                      child: bill.bankName!.icon(),
                                      width: 20,
                                      height: 20,
                                    )
                                  : Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: StyleColorCustom().setStyleByEnum(
                                        context,
                                        StyleColorEnum.primaryBackgroundReverse,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextWidget(
                                padding: 0,
                                text: bill.bankName != null
                                    ? bill.bankName!.title()
                                    : bill.name,
                                style: StyleTextCustom()
                                    .setStyleByEnum(
                                        context, StyleTextEnum.bodyCard)
                                    .copyWith(
                                      fontSize: 12,
                                      height: 15 / 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                                color: StyleColorCustom().setStyleByEnum(
                                  context,
                                  StyleColorEnum.secondaryBackground,
                                ),
                                child: Icon(Icons.more_horiz),
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      child: Row(
                                        children: [
                                          Icon(!bill.hidden
                                              ? CupertinoIcons.eye_slash
                                              : CupertinoIcons.eye),
                                          SizedBox(width: 10),
                                          Text(
                                            !bill.hidden
                                                ? "Скрыть"
                                                : "Показать",
                                            style: StyleTextCustom()
                                                .setStyleByEnum(
                                              context,
                                              StyleTextEnum.bodyCard,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        bill.hidden
                                            ? context
                                                .read<HomeScreenBloc>()
                                                .add(UpdateBillHiddenEvent(
                                                  id: bill.id,
                                                  isHidden: false,
                                                ))
                                            : context
                                                .read<HomeScreenBloc>()
                                                .add(UpdateBillHiddenEvent(
                                                  id: bill.id,
                                                  isHidden: true,
                                                ));
                                      },
                                    ),
                                  ];
                                }),
                          ],
                        ),
                        Row(
                          children: [
                            bill.bankName != null
                                ? TextWidget(
                                    padding: 0,
                                    text: "**** " +
                                        bill.cardNumber!.substring(
                                            bill.cardNumber!.length - 4),
                                    style: StyleTextCustom()
                                        .setStyleByEnum(
                                            context, StyleTextEnum.bodyCard)
                                        .copyWith(
                                          fontSize: 12,
                                          height: 15 / 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox(),
                            Expanded(
                              child: TextWidget(
                                align: TextAlign.end,
                                padding: 0,
                                text: (maskFormatter
                                            .maskText(_balance
                                                .toString()
                                                .split(".")
                                                .first
                                                .split("")
                                                .reversed
                                                .join(""))
                                            .split("")
                                            .reversed
                                            .join("") +
                                        "," +
                                        _balance.toString().split(".").last) +
                                    " ₽",
                                style: StyleTextCustom()
                                    .setStyleByEnum(
                                        context, StyleTextEnum.bodyCard)
                                    .copyWith(
                                      fontSize: 14,
                                      height: 17 / 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          selector: (_, provider) => provider.isHiddenBills),
    );
  }

  Widget _schemeWidget(BuildContext _context) => ValueListenableBuilder(
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
                builder: (BuildContext context, List<Transaction>? _items, _) {
                  return _schemeFront(_context, _items);
                },
              );
          }
        },
      );

  Widget _bottomSlider(
    bool isEmpty,
    Map<String, Map<String, Transaction>> byCategory,
    Map<String, OperationCategory> categories,
    List<Transaction>? items,
    double fullPrice,
  ) {
    Map<double, List<Widget>> _l = <double, List<Widget>>{};
    categories.values.forEach((cat) {
      List<double> t = byCategory[cat.id]!
          .values
          .map((transaction) => transaction.sum != null && transaction.sum != 0
              ? (transaction.sum!.roundToDouble() *
                  ((transaction.action == TransactionTypes.SPEND ||
                          transaction.action == TransactionTypes.WITHDRAW)
                      ? -1
                      : 1))
              : (double.parse(
                          "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                      .roundToDouble()) *
                  ((transaction.action == TransactionTypes.SPEND ||
                          transaction.action == TransactionTypes.WITHDRAW)
                      ? -1
                      : 1))
          .toList();
      var v = t.isNotEmpty ? t.reduce((double a, double b) => a + b) : 0.0;
      //var _v = v.isNegative ? v * -1 : v;

      if (!_l.containsKey(t.isNotEmpty ? t.reduce((a, b) => a + b) : 0)) {
        _l[v] = [];
      }
      _l[v]!.add(_singleCard(
        cat,
        t.isNotEmpty ? t.reduce((double a, double b) => a + b) : 0,
      ));
    });

    //_l.entries.toList().sort(((a, b) => a.key.compareTo(b.key)));
    final sorted =
        SplayTreeMap<double, dynamic>.from(_l, (a, b) => a.compareTo(b));

    List<Widget> _cats = <Widget>[];

    sorted.forEach((key, value) {
      _cats.addAll(value);
    });

    return SizedBox(
      height: 85,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 20),
          ..._cats,
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _titleScheme(BuildContext _context) => ValueListenableBuilder(
        valueListenable: _sortTypeState,
        builder: (BuildContext context, CalendarSortTypes _state, _) {
          String? _title;
          if (_start != null) {
            switch (_state) {
              case CalendarSortTypes.currentMonth:
              case CalendarSortTypes.lastMonth:
              case CalendarSortTypes.customMonth:
                var month =
                    DateFormat.MMMM("ru_RU").dateSymbols.STANDALONEMONTHS;
                dateFormat = DateFormat('yyyy', "ru");
                _title =
                    month[_start!.month - 1] + " " + dateFormat.format(_start!);
                break;
              case CalendarSortTypes.currentWeek:
                _title = "Текущая неделя";
                break;
              case CalendarSortTypes.lastWeek:
                _title = "Прошлая неделя";
                break;
              case CalendarSortTypes.customWeek:
              case CalendarSortTypes.rangeDates:
                dateFormat = DateFormat('MMMM yyyy', "ru");
                _title = _start!.day.toString() +
                    "-" +
                    _end!.day.toString() +
                    " " +
                    dateFormat.format(_start!);
                break;
            }
          } else {
            _title = "";
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              TextWidget(
                text: _start != null ? _title.capitalize() : "",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.titleCard),
                align: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: _context,
                    builder: (_) {
                      final ValueNotifier<CalendarSortTypes> _sort =
                          ValueNotifier<CalendarSortTypes>(_state);
                      return Material(
                        color: Colors.transparent,
                        child: ValueListenableBuilder(
                          valueListenable: _sort,
                          builder: (BuildContext context,
                                  CalendarSortTypes _state, _) =>
                              Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: 311,
                                  decoration: BoxDecoration(
                                    color: StyleColorCustom().setStyleByEnum(
                                        context,
                                        StyleColorEnum.primaryBackground),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      // TextWidget(
                                      //   padding: 0,
                                      //   text: "Календарь",
                                      //   style: StyleTextCustom().setStyleByEnum(
                                      //       context,
                                      //       StyleTextEnum.dialogCalendarTitle),
                                      //   align: TextAlign.center,
                                      // ),
                                      // const SizedBox(height: 16),
                                      ...CalendarSortTypes.values
                                          .where(
                                              (e) => e.getTitleDate() != null)
                                          .map((sort) => _sortButton(sort,
                                              _state == sort, _sort, _context))
                                          .toList(),
                                      Container(
                                        height: 1,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors:
                                                CustomColors.listGradienDivider,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ButtonCancel(
                                            text: "Отмена",
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            widthCustom: 131.5,
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          ButtonBlue(
                                            text: "Применить",
                                            onPressed: () {
                                              _context
                                                  .read<HomeScreenBloc>()
                                                  .add(
                                                    UpdateSortEvent(
                                                        sort: _sort.value,
                                                        isExpense: _userProvider
                                                            .isEarnActive),
                                                  );
                                            },
                                            widthCustom: 131.5,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      color: StyleColorCustom()
                          .setStyleByEnum(context, StyleColorEnum.colorIcon),
                    ),
                  ),
                ),
                behavior: HitTestBehavior.translucent,
              ),
            ],
          );
        },
      );

  Widget _circleInScheme(
    bool isEmpty,
    Map<String, Map<String, Transaction>> _byCategory,
    Map<String, OperationCategory> _categories,
    List<Transaction>? _items,
    double _fullPrice,
  ) {
    Map<double, List<PieChartSectionData>> _l =
        <double, List<PieChartSectionData>>{};

    _categories.values.forEach((section) {
      var t = _byCategory[section.id]!
          .values
          .map((transaction) => _calc(transaction))
          .toList();
      var v = t.isNotEmpty ? t.reduce((double a, double b) => a + b) : 0.0;

      if (!_l.containsKey(t.isNotEmpty ? t.reduce((a, b) => a + b) : 0)) {
        _l[v] = [];
      }

      final i = _categories.values.toList().indexOf(section);
      final isTouched = i == touchedIndex;

      _l[v]!.add(PieChartSectionData(
        value: _calcPercent(
            _fullPrice, t.isNotEmpty ? t.reduce((a, b) => a + b) : 0),
        color: Color(int.parse("0xFF" + section.color.hex.substring(1))),
        showTitle: false,
        borderSide: BorderSide(
          width: isTouched ? 0.5 : 2,
          color: StyleColorCustom().setStyleByEnum(
            context,
            isTouched
                ? StyleColorEnum.secondaryBackgroundReverse
                : StyleColorEnum.secondaryBackground,
          ),
        ),
      ));
    });

    final sorted =
        SplayTreeMap<double, dynamic>.from(_l, (a, b) => a.compareTo(b));

    List<PieChartSectionData> _cats = <PieChartSectionData>[];

    sorted.forEach((key, value) {
      _cats.addAll(value);
    });
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                height: 240,
                width: 240,
                child: PieChart(
                  swapAnimationDuration: Duration(milliseconds: 500),
                  PieChartData(
                    startDegreeOffset: 270,
                    borderData: FlBorderData(show: false),
                    pieTouchData: (PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    })),
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: !isEmpty
                        ? _cats
                        : [
                            PieChartSectionData(
                              value: 100,
                              color: Colors.grey,
                              showTitle: false,
                              borderSide: BorderSide(
                                width: 2,
                                color: StyleColorCustom().setStyleByEnum(
                                  context,
                                  StyleColorEnum.secondaryBackground,
                                ),
                              ),
                            )
                          ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: Text(
                  "",
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.titleCard),
                ),
                secondChild: Text(
                  touchedIndex == -1
                      ? ""
                      : _categories.values.toList()[touchedIndex].name,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.titleCard),
                ),
                duration: Duration(milliseconds: 500),
                reverseDuration: Duration(seconds: 500),
                crossFadeState: touchedIndex == -1
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ],
          ),
          (_userProvider.isEarnActive
              ? _incomeWidget(!isEmpty
                  ? _items
                          ?.map((transaction) => transaction.action ==
                                      TransactionTypes.DEPOSIT ||
                                  transaction.action == TransactionTypes.EARN //
                              ? transaction.sum != null && transaction.sum != 0
                                  ? transaction.sum!.roundToDouble()
                                  : double.parse(
                                          "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                                      .roundToDouble()
                              : 0.0)
                          .toList()
                          .reduce((a, b) => a + b) ??
                      0.0
                  : 0)
              : _consumptionWidget(
                  !isEmpty
                      ? _items
                              ?.map((transaction) => transaction.action ==
                                          TransactionTypes.WITHDRAW ||
                                      transaction.action ==
                                          TransactionTypes.SPEND //
                                  ? transaction.sum != null &&
                                          transaction.sum != 0
                                      ? transaction.sum!.roundToDouble()
                                      : double.parse(
                                              "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                                          .roundToDouble()
                                  : 0.0)
                              .toList()
                              .reduce((a, b) => a + b) ??
                          0.0
                      : 0,
                )),
        ],
      ),
    );
  }

  Widget _schemeFront(BuildContext _context, List<Transaction>? items) {
    Map<String, Map<String, Transaction>> _byCategory =
        <String, Map<String, Transaction>>{};
    Map<String, OperationCategory> _categories = <String, OperationCategory>{};
    bool isEmpty = true;
    final double _fullPrice = (items != null && items.isNotEmpty)
        ? items
            .map((transaction) => transaction.action == TransactionTypes.SPEND
                ? (transaction.sum != null && transaction.sum != 0
                    ? transaction.sum!.abs().roundToDouble()
                    : double.parse(
                            "${transaction.amount!.amount}.${transaction.amount!.cents}")
                        .abs()
                        .roundToDouble())
                : (transaction.sum != null && transaction.sum != 0
                    ? transaction.sum!.roundToDouble()
                    : double.parse(
                            "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                        .roundToDouble()))
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
          if (!_byCategory.containsKey("withdraw")) {
            _byCategory["withdraw"] = <String, Transaction>{};
          }
          switch (item.action) {
            case TransactionTypes.WITHDRAW:
            case TransactionTypes.SPEND:
              _byCategory["deposit"]![item.id] = item;
              break;
            case TransactionTypes.DEPOSIT:
            case TransactionTypes.EARN:
              _byCategory["withdraw"]![item.id] = item;
              break;
          }
          if (!_categories.containsKey("withdraw")) {
            _categories["withdraw"] = OperationCategory(
              id: "withdraw",
              name: "Не сортированные расходы",
              color: CategoryColor(
                hex: "#ededed",
                systemName: "ededed",
                name: "ededed",
              ),
              icon: OperationIcon(
                id: "test",
                name: "test",
                path: "test",
                tag: "test",
              ),
              description: "",
              categoryLimit: 0,
              forEarn: false,
              forSpend: true,
            );
          }
          if (!_categories.containsKey("deposit")) {
            _categories["deposit"] = OperationCategory(
              id: "deposit",
              name: "Не сортированные доходы",
              color: CategoryColor(
                hex: "#ededed",
                systemName: "ededed",
                name: "ededed",
              ),
              icon: OperationIcon(
                id: "test",
                name: "test",
                path: "test",
                tag: "test",
              ),
              description: "",
              categoryLimit: 0,
              forEarn: true,
              forSpend: false,
            );
          }
        }
      });
      isEmpty = false;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ContainerCustom(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Column(
                  children: [
                    _titleScheme(_context),
                    BlocBuilder<HomeScreenBloc, HomeScreenState>(
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Stack(
                            children: [
                              (state is ListLoadingState ||
                                      state is UpdateBillList)
                                  ? Center(
                                      child: SizedBox(
                                        height: 240.0,
                                        width: double.infinity,
                                        child: Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      ),
                                    )
                                  : _circleInScheme(
                                      isEmpty,
                                      _byCategory,
                                      _categories,
                                      items,
                                      _fullPrice,
                                    ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      late CalendarSortTypes _filter;
                                      switch (_sortTypeState.value) {
                                        case CalendarSortTypes.currentMonth:
                                        case CalendarSortTypes.lastMonth:
                                        case CalendarSortTypes.customMonth:
                                          _filter =
                                              CalendarSortTypes.customMonth;
                                          break;
                                        case CalendarSortTypes.currentWeek:
                                        case CalendarSortTypes.lastWeek:
                                        case CalendarSortTypes.customWeek:
                                          _filter =
                                              CalendarSortTypes.customWeek;
                                          break;
                                        case CalendarSortTypes.rangeDates:
                                          _filter =
                                              CalendarSortTypes.rangeDates;
                                          break;
                                      }

                                      if (_debounce?.isActive ?? false)
                                        _debounce!.cancel();
                                      _debounce = Timer(
                                        const Duration(milliseconds: 500),
                                        () {
                                          context.read<HomeScreenBloc>().add(
                                                UpdateSortEvent(
                                                    sort: _filter,
                                                    prev: true,
                                                    isExpense: _userProvider
                                                        .isEarnActive),
                                              );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.chevron_left_outlined,
                                      size: 40,
                                      color: StyleColorCustom().setStyleByEnum(
                                          context, StyleColorEnum.colorIcon),
                                    ),
                                  ),
                                  SizedBox(height: 240.0),
                                  ValueListenableBuilder(
                                    valueListenable: _nextIsVisible,
                                    builder: (BuildContext context,
                                            bool _isActive, _) =>
                                        _isActive
                                            ? GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  late CalendarSortTypes
                                                      _filter;
                                                  switch (
                                                      _sortTypeState.value) {
                                                    case CalendarSortTypes
                                                        .currentMonth:
                                                    case CalendarSortTypes
                                                        .lastMonth:
                                                    case CalendarSortTypes
                                                        .customMonth:
                                                      _filter =
                                                          CalendarSortTypes
                                                              .customMonth;
                                                      break;
                                                    case CalendarSortTypes
                                                        .currentWeek:
                                                    case CalendarSortTypes
                                                        .lastWeek:
                                                    case CalendarSortTypes
                                                        .customWeek:
                                                      _filter =
                                                          CalendarSortTypes
                                                              .customWeek;
                                                      break;
                                                    case CalendarSortTypes
                                                        .rangeDates:
                                                      _filter =
                                                          CalendarSortTypes
                                                              .rangeDates;
                                                      break;
                                                  }
                                                  if (_debounce?.isActive ??
                                                      false)
                                                    _debounce!.cancel();
                                                  _debounce = Timer(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                    Logger().i("message0");
                                                    context
                                                        .read<HomeScreenBloc>()
                                                        .add(
                                                          UpdateSortEvent(
                                                              sort: _filter,
                                                              next: true,
                                                              isExpense:
                                                                  _userProvider
                                                                      .isEarnActive),
                                                        );
                                                    Logger().i("message");
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.chevron_right_outlined,
                                                  size: 40,
                                                  color: StyleColorCustom()
                                                      .setStyleByEnum(
                                                          context,
                                                          StyleColorEnum
                                                              .colorIcon),
                                                ),
                                              )
                                            : Container(width: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {
                      final bloc = context.read<HomeScreenBloc>();
                      if (_userProvider.isEarnActive) {
                        bloc.add(UpdateSchemeTypeEvent(isExpense: false));
                        _userProvider.setIsEarnActive = false;
                      } else {
                        bloc.add(UpdateSchemeTypeEvent(isExpense: true));
                        _userProvider.setIsEarnActive = true;
                      }
                    },
                    icon: Icon(CupertinoIcons.repeat),
                  ),
                ),
              ],
            ),
          ),
        ),
        _bottomSlider(isEmpty, _byCategory, _categories, items, _fullPrice),
      ],
    );
  }

  double _calcPercent(double fullPrice, double reduce) {
    final double share = (reduce / fullPrice) * 100;
    return share;
  }

  Widget _incomeWidget(double value) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextWidget(
                padding: 0,
                text: textString_63,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.bodyCard),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_drop_up_outlined,
                    color: CustomColors.blue,
                    size: 30,
                  ),
                  TextWidget(
                    padding: 0,
                    text: maskFormatter
                            .maskText(value
                                .round()
                                .toString()
                                .split(".")
                                .first
                                .split("")
                                .reversed
                                .join("."))
                            .split("")
                            .reversed
                            .join("") +
                        " ₽",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.titleCard),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _consumptionWidget(double value) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextWidget(
                  padding: 0,
                  text: textString_64,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: CustomColors.pink,
                    size: 30,
                  ),
                  TextWidget(
                    padding: 0,
                    text: maskFormatter
                            .maskText(value
                                .round()
                                .toString()
                                .split(".")
                                .first
                                .split("")
                                .reversed
                                .join("."))
                            .split("")
                            .reversed
                            .join("") +
                        " ₽",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.titleCard),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _singleCard(OperationCategory cat, double price) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: ContainerCustom(
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Color(int.parse("0xFF" + cat.color.hex.substring(1))),
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse("0xFF" + cat.color.hex.substring(1)))
                          .withOpacity(.4),
                      Color(int.parse("0xFF" + cat.color.hex.substring(1))),
                    ],
                  ),
                ),
                child: cat.icon?.name != null
                    ? Center(
                        child: svgIcon(
                          baseUrl + "api/v1/image/content/" + cat.icon!.name,
                          context,
                        ),
                      )
                    : SizedBox(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    padding: 0,
                    text: cat.name,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    align: TextAlign.center,
                  ),
                  TextWidget(
                    padding: 0,
                    text: //(cat.id == "deposit" ? "" : "-") +
                        (price).toString() + " ₽", //.abs()
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    align: TextAlign.center,
                  ),
                ],
              )
            ],
          ),
        ),
      );

  void _showRange(BuildContext _context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext alertContext) {
        return ContainerCustom(
            child: Column(
          children: [
            SfDateRangePicker(
              controller: controller,
              onSelectionChanged: _onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              // initialSelectedRange: PickerDateRange(
              //   _start,
              //   _end,
              // ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonCancel(
                  text: "Отмена",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _calendarPicked,
                  builder: (BuildContext context, bool value, _) =>
                      IgnorePointer(
                    ignoring: !value,
                    child: Opacity(
                      opacity: value ? 1 : .5,
                      child: ButtonBlue(
                        text: "Продолжить",
                        onPressed: () {
                          if (_calendarPicked.value == true &&
                              _startRange != null &&
                              _endRange != null) {
                            _sortTypeState.value = CalendarSortTypes.rangeDates;
                            _context.read<HomeScreenBloc>().add(
                                  UpdateRangeDatesEvent(
                                    start: _startRange,
                                    end: _endRange,
                                  ),
                                );
                            _context.read<HomeScreenBloc>().add(
                                  UpdateSortEvent(
                                      sort: _sortTypeState.value,
                                      isExpense: _userProvider.isEarnActive),
                                );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
      },
    );
  }

  Widget _sortButton(CalendarSortTypes sort, bool active,
          ValueNotifier<CalendarSortTypes> _sort, BuildContext _context) =>
      GestureDetector(
        onTap: () {
          if (sort == CalendarSortTypes.rangeDates) {
            Navigator.pop(_context);
            _showRange(_context);
          } else {
            _sort.value = sort;
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: active ? CustomColors.blue : Colors.transparent,
          ),
          height: 40,
          alignment: Alignment.center,
          child: TextWidget(
            padding: 0,
            text: sort.getTitleDate()!,
            style: active
                ? StyleTextCustom()
                    .setStyleByEnum(
                        context, StyleTextEnum.dialogCalendarTitleLigth)
                    .copyWith(color: CustomColors.lightPrimaryText)
                : StyleTextCustom().setStyleByEnum(
                    context, StyleTextEnum.dialogCalendarTitleLigth),
            align: TextAlign.center,
          ),
        ),
        behavior: HitTestBehavior.translucent,
      );

  double _calc(Transaction transaction) {
    switch (transaction.action) {
      case TransactionTypes.WITHDRAW:
      case TransactionTypes.SPEND:
        return (transaction.sum != null && transaction.sum != 0
            ? transaction.sum!.abs().roundToDouble()
            : double.parse(
                    "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                .abs()
                .roundToDouble());
      case TransactionTypes.DEPOSIT:
      case TransactionTypes.EARN:
        return transaction.sum != null && transaction.sum != 0
            ? transaction.sum!.roundToDouble()
            : double.parse(
                    "${transaction.amount?.amount ?? 0}.${transaction.amount?.cents ?? 0}")
                .roundToDouble();
    }
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
}
