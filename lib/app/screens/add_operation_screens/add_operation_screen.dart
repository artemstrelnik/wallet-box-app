import 'dart:async';

import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/data_time.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_bloc.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen_bloc.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen_events.dart';
import 'package:wallet_box/app/screens/add_operation_screens/add_operation_screen_states.dart';
import 'package:wallet_box/app/screens/categories_screens/categories_screens_bloc.dart';
import 'package:wallet_box/app/screens/categories_screens/categories_screens_page.dart';
import 'package:wallet_box/app/screens/home_screen/widgets/icon_loader.dart';
import 'package:wallet_box/app/screens/map_search_page/map_search_page.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:screen_loader/screen_loader.dart';

class AddOperationScreen extends StatefulWidget {
  const AddOperationScreen({
    Key? key,
    this.isEditing = false,
    this.transaction,
    this.type,
  }) : super(key: key);

  final OperationType? type;
  final bool isEditing;
  final Transaction? transaction;

  @override
  _AddOperationScreenPageState createState() => _AddOperationScreenPageState();
}

class _AddOperationScreenPageState extends State<AddOperationScreen>
    with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<List<OperationCategory>> _categoriesList =
      ValueNotifier<List<OperationCategory>>(<OperationCategory>[]);
  final ValueNotifier<List<Bill>> _billsList =
      ValueNotifier<List<Bill>>(<Bill>[]);
  final ValueNotifier<LoadingState> _catState =
      ValueNotifier<LoadingState>(LoadingState.loading);
  final ValueNotifier<LoadingState> _billState =
      ValueNotifier<LoadingState>(LoadingState.loading);
  late ValueNotifier<OperationCategory> _selectedCategory;
  late ValueNotifier<Bill> _selectedBill;
  final ValueNotifier<SearchItem?> _selectedAddress =
      ValueNotifier<SearchItem?>(null);

  final ValueNotifier<TransactionTypes> _transactionType =
      ValueNotifier<TransactionTypes>(TransactionTypes.WITHDRAW);

  final ValueNotifier<bool> _canEdited = ValueNotifier<bool>(true);

  final DateTime _now = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '### ### ###,## ₽',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final TextEditingController _controllerSum = TextEditingController();
  final TextEditingController _controllerDesc = TextEditingController();

  String _scanBarcode = 'Unknown';
  List<OperationCategory>? _temporaryList = <OperationCategory>[];

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );

    if (widget.isEditing && widget.transaction?.bill?.bankName == null) {
      _canEdited.value = true;
    } else if (!widget.isEditing) {
      _canEdited.value = true;
    } else {
      _canEdited.value = false;
    }

    context.read<AddOperationScreenBloc>().add(UpdateDateTimeEvent(date: _now));
    context
        .read<AddOperationScreenBloc>()
        .add(PageOpenedEvent(userInfo: _userProvider));
    if (widget.isEditing && widget.transaction != null) {
      _controllerSum.text = widget.transaction!.sum.toString();

      _controllerDesc.text = widget.transaction?.description ?? "";

      _transactionType.value = widget.transaction!.action;
      Logger().w(widget.transaction?.category.toString());
      if (widget.transaction!.category != null) {
        context.read<AddOperationScreenBloc>().add(
              UpdateSelectedCategory(category: widget.transaction!.category),
            );
      }

      context.read<AddOperationScreenBloc>().add(
            UpdateSelectedBill(bill: widget.transaction!.bill!),
          );
      _search(query: widget.transaction!.geocodedPlace!);
    }
    if (widget.type != null && widget.type == OperationType.qr) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _openOperationQr(context);
      });
    }
  }

  void _openOperationQr(BuildContext context) async {
    final Map<String, dynamic>? arr = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScannerScreen(),
      ),
    );
    if (arr != null && arr.isNotEmpty) {
      context.read<AddOperationScreenBloc>().add(
            GetMessageIdEvent(codeString: arr),
          );
    }
  }

  Future<void> _toMapPage(SearchItem? item) async {
    final SearchItem? _returnBack = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchExample(
          lat: item?.geometry.first.point?.latitude,
          lon: item?.geometry.first.point?.longitude,
        ),
      ),
    );
    if (_returnBack != null) {
      context.read<AddOperationScreenBloc>().add(
            UpdateAddressEvent(address: _returnBack),
          );
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
    return BlocListener<AddOperationScreenBloc, AddOperationScreenState>(
      listener: (context, state) {
        if (state is UpdatePrice) {
          _controllerSum.text = state.sum.toString();
        }
        if (state is ToMapPageState) {
          _toMapPage(state.address);
        }
        if (state is UpdateCategoriesList) {
          if (state.categories.isNotEmpty) {
            _categoriesList.value = state.categories;
            if (!widget.isEditing || widget.transaction!.category == null) {
              if (_transactionType.value == TransactionTypes.DEPOSIT ||
                  _transactionType.value == TransactionTypes.DEPOSIT) {
                Logger().d(state.categories.toString());
                _selectedCategory = ValueNotifier<OperationCategory>(
                    state.categories.firstWhere((e) => e.forEarn));
              } else {
                _selectedCategory = ValueNotifier<OperationCategory>(
                    state.categories.firstWhere((e) => e.forSpend));
              }

              _catState.value = LoadingState.loaded;
            }
          } else {
            _catState.value = LoadingState.empty;
          }
        }
        if (state is CategoriesListErrorState) {
          _catState.value = LoadingState.empty;
        }
        if (state is UpdateBillsList) {
          if (state.bills.isNotEmpty) {
            _billsList.value = state.bills;
            if (!widget.isEditing) {
              _selectedBill = ValueNotifier<Bill>(state.bills.first);
              _billState.value = LoadingState.loaded;
            }
          } else {
            _billState.value = LoadingState.empty;
          }
        }

        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is GoBillCreate) {
          _showMyDialog(
            context,
            message: "У вас нет активных счетов, хотите создать?",
            onPress: () async {
              Navigator.pop(context);
              final bool? returnBack = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => AddInvoiceBloc(),
                    child: const AddInvoice(isOperation: true),
                  ),
                ),
              );
              if (returnBack != null && returnBack) {
                context.read<AddOperationScreenBloc>().add(
                      PageOpenedEvent(userInfo: _userProvider),
                    );
              }
            },
          );
        }
        if (state is GoCatCreate) {
          _showMyDialog(
            context,
            message: "У вас нет активных категорий, хотите создать?",
            onPress: () async {
              Navigator.pop(context);
              final Map<String, dynamic>? returnBack = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => CategoriesScreensBloc(),
                    child: const CategoriseScreensPage(isOperation: true),
                  ),
                ),
              );
              if (returnBack != null && returnBack["successes"] as bool) {
                context.read<AddOperationScreenBloc>().add(
                      PageOpenedEvent(userInfo: _userProvider),
                    );
              }
            },
          );
        }

        if (state is UpdateSelectedBillState) {
          if (widget.isEditing) {
            _selectedBill = ValueNotifier<Bill>(state.bill);
            _billState.value = LoadingState.loaded;
          } else {
            _selectedBill.value = state.bill;
          }
        }
        if (state is UpdateSelectedCategoryState) {
          if (widget.isEditing && _catState.value == LoadingState.loading) {
            _selectedCategory =
                ValueNotifier<OperationCategory>(state.category);
            _catState.value = LoadingState.loaded;
          } else {
            _selectedCategory.value = state.category;
          }
        }
        if (state is UpdateSelectedAddressState) {
          _selectedAddress.value = state.address;
        }
        if (state is GoBackEndUpdate) {
          showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              content: Text("Операция " +
                  (widget.isEditing ? "отредактирована" : "создана")),
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
          ).whenComplete(() => Navigator.pop(context, true));
        }
        if (state is TicketDataOutputState) {
          _controllerSum.text = state.data.content.totalSum.toString();
          _controllerDesc.text = state.data.content.retailPlace!;

          _search(query: state.data.address);
          context.read<AddOperationScreenBloc>().add(
                UpdateDateTimeEvent(date: _now),
              );
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _canEditedField({Widget? child}) => ValueListenableBuilder(
        valueListenable: _canEdited,
        builder: (BuildContext context, bool _state, _) => IgnorePointer(
          ignoring: !_state,
          child: Opacity(
            opacity: _state ? 1 : .3,
            child: child!,
          ),
        ),
      );

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          title: widget.isEditing ? "Редактирование операции" : textString_72,
          actions: true,
          leading: true,
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                _canEditedField(
                  child: ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          padding: 0,
                          text: textString_73,
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.bodyCard),
                        ),
                        DataTimeWidget(
                          now: _now,
                          updateDate: (DateTime _date) =>
                              context.read<AddOperationScreenBloc>().add(
                                    UpdateDateTimeEvent(date: _date),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                _canEditedField(
                  child: ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          padding: 0,
                          text: "Тип операции",
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.titleCard),
                        ),
                        _transactionTypeWidget(),
                      ],
                    ),
                  ),
                ),
                ContainerCustom(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        padding: 0,
                        text: textString_74,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _catState,
                        builder:
                            (BuildContext context, LoadingState _state, _) {
                          switch (_state) {
                            case LoadingState.empty:
                              return TextWidget(
                                padding: 10,
                                text: "Вы еще не добавили ни одну категорию",
                                style: StyleTextCustom().setStyleByEnum(
                                    context, StyleTextEnum.bodyCard),
                                align: TextAlign.center,
                              );
                            case LoadingState.loaded:
                              return ValueListenableBuilder(
                                valueListenable: _selectedCategory,
                                builder: (BuildContext context,
                                        OperationCategory _cat, _) =>
                                    _singleCat(
                                        _cat,
                                        () =>
                                            _showBottom(context, "Категория")),
                              );
                            default:
                              return CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                _canEditedField(
                  child: _billWidget(),
                ),
                _canEditedField(
                  child: _sumWidget(),
                ),
                _canEditedField(
                  child: _descriptionWidget(),
                ),
                _canEditedField(
                  child: _addressSelect(),
                ),
                _canEditedField(
                  child: _scanWidget(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonCancel(
                      text: textString_11,
                      onPressed: () => Navigator.pop(context),
                    ),
                    ButtonPink(
                      text: textString_10,
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final String? token =
                            prefs.getString("wallet_box_token");
                        Logger().i("$token");
                        if (_formKey.currentState!.validate()) {
                          if (widget.isEditing) {
                            if (widget.transaction?.bill?.bankName != null) {
                              Logger().i("message1");
                              context.read<AddOperationScreenBloc>().add(
                                    UpdateBankOperationEvent(
                                      id: widget.transaction!.id,
                                      bankName:
                                          widget.transaction!.bill!.bankName!,
                                    ),
                                  );
                            } else {
                              Logger().i("message2");
                              context.read<AddOperationScreenBloc>().add(
                                    UpdateOperationEvent(
                                      desc: _controllerDesc.text,
                                      sum: _controllerSum.text,
                                      type: _transactionType.value,
                                      id: widget.transaction!.id,
                                    ),
                                  );
                            }
                          } else {
                            Logger().i("messag3e");
                            context.read<AddOperationScreenBloc>().add(
                                  CreateOperationEvent(
                                    desc: _controllerDesc.text,
                                    sum: _controllerSum.text,
                                    type: _transactionType.value,
                                  ),
                                );
                          }
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16)
              ],
            ),
          ),
        ),
      );

  Widget _singleCat(OperationCategory _cat, Function() _func,
          {bool arrow = true}) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _func,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: Color(
                          int.parse("0xFF" + _cat.color.hex.substring(1))),
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(int.parse("0xFF" + _cat.color.hex.substring(1)))
                              .withOpacity(.4),
                          Color(
                              int.parse("0xFF" + _cat.color.hex.substring(1))),
                        ],
                      ),
                    ),
                    child: _cat.icon?.name != null
                        ? Center(
                            child: svgIcon(
                              baseUrl +
                                  "api/v1/image/content/" +
                                  _cat.icon!.name,
                              context,
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
                TextWidget(
                  padding: 10,
                  text: _cat.name,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard),
                  align: TextAlign.center,
                ),
              ],
            ),
            arrow
                ? Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.colorIcon,
                      ),
                      size: 30,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );

  Widget _singleBill(Bill _bill, Function() _func, {bool arrow = true}) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _func,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.withOpacity(.3),
                          Colors.grey,
                        ],
                      ),
                    ),
                  ),
                ),
                TextWidget(
                  padding: 10,
                  text: _bill.name,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard),
                  align: TextAlign.center,
                ),
              ],
            ),
            arrow
                ? Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.colorIcon,
                      ),
                      size: 30,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );

  Future<void> _showMyDialog(context,
      {String? title,
      required String message,
      required Function() onPress}) async {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(message.split(":").last.trim()),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Создать'),
            onPressed: onPress,
          ),
        ],
      ),
    );
  }

  void _showBottom(
    BuildContext _context,
    String title, {
    bool isBill = false,
  }) =>
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: StyleColorCustom()
                  .setStyleByEnum(context, StyleColorEnum.secondaryBackground),
            ),
            padding: const EdgeInsets.all(32),
            height: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      padding: 0,
                      text: title,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.titleCard),
                    ),
                    GestureDetector(
                      onTap: !isBill
                          ? () async {
                              final Map<String, dynamic>? returnBack =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) =>
                                        CategoriesScreensBloc(),
                                    child: const CategoriseScreensPage(
                                        isOperation: true),
                                  ),
                                ),
                              );
                              if (returnBack != null &&
                                  returnBack["successes"] as bool) {
                                var cat =
                                    returnBack["cat"] as OperationCategory;

                                _categoriesList.value.add(cat);
                                _context.read<AddOperationScreenBloc>().add(
                                      UpdateSelectedCategory(category: cat),
                                    );
                                Navigator.pop(context);
                              }
                            }
                          : () async {
                              final Map<String, dynamic>? returnBack =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => AddInvoiceBloc(),
                                    child: const AddInvoice(isOperation: true),
                                  ),
                                ),
                              );
                              if (returnBack != null &&
                                  returnBack["successes"] as bool) {
                                var bill = returnBack["bill"] as Bill;
                                _billsList.value.add(bill);

                                _context.read<AddOperationScreenBloc>().add(
                                      UpdateSelectedBill(bill: bill),
                                    );
                                Navigator.pop(context);
                              }
                            },
                      child: const SizedBox(
                        child: Icon(
                          Icons.add_circle,
                          color: CustomColors.pink,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: isBill
                          ? _billsList.value
                              .map((e) => _singleBill(e, () {
                                    _context.read<AddOperationScreenBloc>().add(
                                          UpdateSelectedBill(bill: e),
                                        );
                                    Navigator.pop(context);
                                  }, arrow: false))
                              .toList()
                          : _categoriesList.value
                              .map((e) => _singleCat(e, () {
                                    _context.read<AddOperationScreenBloc>().add(
                                          UpdateSelectedCategory(category: e),
                                        );
                                    Navigator.pop(context);
                                  }, arrow: false))
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _billWidget() => ContainerCustom(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              padding: 0,
              text: "Счет",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
            ),
            ValueListenableBuilder(
              valueListenable: _billState,
              builder: (BuildContext context, LoadingState _state, _) {
                switch (_state) {
                  case LoadingState.empty:
                    return TextWidget(
                      padding: 10,
                      text: "Вы еще не добавили ни одну счета",
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.bodyCard),
                      align: TextAlign.center,
                    );
                  case LoadingState.loaded:
                    return ValueListenableBuilder(
                      valueListenable: _selectedBill,
                      builder: (BuildContext context, Bill _bill, _) =>
                          _singleBill(
                        _bill,
                        () => _showBottom(
                          context,
                          "Счет",
                          isBill: true,
                        ),
                      ),
                    );
                  default:
                    return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      );

  Widget _descriptionWidget() => ContainerCustom(
        width: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              padding: 0,
              text: textString_77,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
            ),
            TextFieldWidget(
              contentPadding: const EdgeInsets.only(
                left: 0,
                bottom: 5.0,
                top: 5.0,
              ),
              isDense: true,
              autofocus: false,
              textInputType: TextInputType.text,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.neutralText),
              fillColor: StyleColorCustom()
                  .setStyleByEnum(context, StyleColorEnum.secondaryBackground),
              labelText: textString_75,
              validation: (String? value) {
                if (value?.length != 0) {
                  if (value!.length < 2) {
                    return 'Пожалуйста введите укажите описание';
                  }
                }
                return null;
              },
              controller: _controllerDesc,
            ),
          ],
        ),
      );

  Widget _sumWidget() => ContainerCustom(
        width: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              padding: 0,
              text: "Сумма",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard),
            ),
            TextFieldWidget(
              contentPadding: const EdgeInsets.only(
                left: 0,
                bottom: 5.0,
                top: 5.0,
              ),
              isDense: true,
              //filteringTextInputFormatter: <TextInputFormatter>[maskFormatter],
              autofocus: false,
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  StyleTextCustom().setStyleByEnum(context, StyleTextEnum.pink),
              labelText: "Укажите сумму",
              fillColor: StyleColorCustom()
                  .setStyleByEnum(context, StyleColorEnum.secondaryBackground),
              validation: (String? value) {
                if (value?.length == 0) {
                  return 'Пожалуйста введите сумму';
                }
                return null;
              },
              controller: _controllerSum,
            ),
          ],
        ),
      );

  Widget _addressSelect() => GestureDetector(
        onTap: () async {
          context.read<AddOperationScreenBloc>().add(
                GoToMapPage(),
              );
        },
        child: ContainerCustom(
          width: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                  padding: 0,
                  text: textString_78,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.titleCard)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _selectedAddress,
                      builder:
                          (BuildContext context, SearchItem? _address, _) =>
                              TextWidget(
                        text: _address != null
                            ? _address.toponymMetadata!.address.formattedAddress
                            : "Адрес еще не указан",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.bodyCard),
                        align: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 10),
                    child: Icon(
                      Icons.chevron_right_outlined,
                      color: StyleColorCustom().setStyleByEnum(
                        context,
                        StyleColorEnum.colorIcon,
                      ),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _scanWidget() => GestureDetector(
        onTap: () async {
          final Map<String, dynamic>? arr = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ScannerScreen(),
            ),
          );
          if (arr != null && arr.isNotEmpty) {
            context.read<AddOperationScreenBloc>().add(
                  GetMessageIdEvent(codeString: arr),
                );
          }
        },
        child: ContainerCustom(
          width: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.qr_code_scanner_outlined,
                  color: StyleColorCustom().setStyleByEnum(
                    context,
                    StyleColorEnum.colorIcon,
                  ),
                  size: 30,
                ),
              ),
              TextWidget(
                padding: 0,
                text: textString_79,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.bodyCard),
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _transactionTypeWidget() => ValueListenableBuilder(
        valueListenable: _transactionType,
        builder: (BuildContext context, TransactionTypes _type, _) {
          return Container(
            child: Column(
              children: TransactionTypes.values
                  .map((e) => widget.transaction?.bill?.cardId != null
                      ? e.isBank()
                          ? _checkbox(e, _type == e)
                          : SizedBox()
                      : !e.isBank()
                          ? _checkbox(e, _type == e)
                          : SizedBox())
                  .toList(),
            ),
          );
        },
      );

  Widget _checkbox(TransactionTypes e, bool isActive) => Container(
        margin: EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              padding: 0,
              text: e.title(),
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.bodyCard),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _transactionType.value = e;
                if (_temporaryList != null && _temporaryList!.isNotEmpty)
                  _categoriesList.value = _temporaryList!;

                _temporaryList = List.of(_categoriesList.value);
                if (e == TransactionTypes.DEPOSIT ||
                    e == TransactionTypes.EARN) {
                  _temporaryList = List.of(_categoriesList.value);
                  var _l = _categoriesList.value
                      .where((e) => e.forEarn == true)
                      .toList();
                  if (_l.isNotEmpty) {
                    _categoriesList.value = _l;
                    context.read<AddOperationScreenBloc>().add(
                          UpdateSelectedCategory(category: _l.first),
                        );
                    _catState.value = LoadingState.loaded;
                  } else {
                    _catState.value = LoadingState.empty;
                  }
                } else {
                  _temporaryList = List.of(_categoriesList.value);
                  var _l = _categoriesList.value
                      .where((e) => e.forSpend == true)
                      .toList();
                  if (_l.isNotEmpty) {
                    _categoriesList.value = _l;
                    context.read<AddOperationScreenBloc>().add(
                          UpdateSelectedCategory(category: _l.first),
                        );
                    _catState.value = LoadingState.loaded;
                  } else {
                    _catState.value = LoadingState.empty;
                  }
                }
              },
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:
                      !isActive ? CustomColors.neutralText : CustomColors.pink,
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  void _search({String? query}) async {
    final SearchResultWithSession resultWithSession = _resultList(query!);
    final SearchSessionResult result = await resultWithSession.result;

    if (result.items != null && result.items!.isNotEmpty) {
      context.read<AddOperationScreenBloc>().add(
            UpdateAddressEvent(address: result.items!.first),
          );
    }
  }

  SearchResultWithSession _resultList(String query) =>
      YandexSearch.searchByText(
        searchText: query,
        geometry: Geometry.fromBoundingBox(BoundingBox(
          southWest:
              Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
          northEast: Point(
              latitude: 55.785322774728414, longitude: 37.590924677311705),
        )),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
        ),
      );
}

final codeStream = StreamController<Barcode>.broadcast();

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    this.isBarcode = false,
    Key? key,
  }) : super(key: key);

  final bool isBarcode;

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _torchIconState = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BarcodeCamera(
        types: const [
          BarcodeType.aztec,
          BarcodeType.code128,
          BarcodeType.code39,
          BarcodeType.code39mod43,
          BarcodeType.code93,
          BarcodeType.codabar,
          BarcodeType.dataMatrix,
          BarcodeType.ean13,
          BarcodeType.ean8,
          BarcodeType.itf,
          BarcodeType.pdf417,
          BarcodeType.qr,
          BarcodeType.upcA,
          BarcodeType.upcE,
          BarcodeType.interleaved,
        ],
        resolution: Resolution.hd720,
        framerate: Framerate.fps30,
        mode: DetectionMode.pauseVideo,
        onScan: (code) {
          codeStream.add(code);
          CameraController.instance.resumeDetector();
          Navigator.pop(context, <String, dynamic>{
            "code": code.value,
            "isBarcode": widget.isBarcode,
            "codeType": code.type,
          });
        },
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8),
                      BlendMode.srcOut), // This one will create the magic
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            backgroundBlendMode: BlendMode
                                .dstOut), // This one will handle background + difference out
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 50),
                          height: 283,
                          width: 283,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    widget.isBarcode ? AssetsPath.barcode : AssetsPath.qr,
                    color: Colors.white,
                  ),
                  Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: TextWidget(
                      text: widget.isBarcode
                          ? "Наведите камеру на штрихкод карты"
                          : "Наведите камеру телефона на QR код чека",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: CustomColors.darkPrimaryText,
                      ),
                      align: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ButtonPink(
                      text: "Отменить",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              )),
              const Positioned(
                child: Opacity(
                  opacity: 0,
                  child: IgnorePointer(
                    child: DetectionsCounter(),
                  ),
                ),
              ),
              Positioned(
                child: SafeArea(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.colorIcon),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size(
                          MediaQuery.of(context).size.width,
                          30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextWidget(
                                padding: 0,
                                text: widget.isBarcode
                                    ? "Скан карты"
                                    : "Скан чека",
                                style: StyleTextCustom().setStyleByEnum(
                                    context, StyleTextEnum.header),
                              ),
                            ),
                          ],
                        ),
                      ),
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    backgroundColor: Colors.transparent,
                    body: Container(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DetectionsCounter extends StatefulWidget {
  const DetectionsCounter({Key? key}) : super(key: key);

  @override
  _DetectionsCounterState createState() => _DetectionsCounterState();
}

class _DetectionsCounterState extends State<DetectionsCounter> {
  @override
  void initState() {
    super.initState();
    _streamToken = codeStream.stream.listen((event) {
      final count = detectionCount.update(event.value, (value) => value + 1,
          ifAbsent: () => 1);
      detectionInfo.value = "${count}x\n${event.value}";
    });
  }

  late StreamSubscription _streamToken;
  Map<String, int> detectionCount = {};
  final detectionInfo = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        child: ValueListenableBuilder(
          valueListenable: detectionInfo,
          builder: (context, dynamic info, child) => Text(
            info,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamToken.cancel();
    super.dispose();
  }
}
