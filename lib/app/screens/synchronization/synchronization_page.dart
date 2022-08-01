import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_bloc.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_events.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_states.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:screen_loader/screen_loader.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class SynchronizationPage extends StatefulWidget {
  const SynchronizationPage({
    Key? key,
  }) : super(key: key);

  @override
  _SynchronizationPageState createState() => _SynchronizationPageState();
}

class _SynchronizationPageState extends State<SynchronizationPage>
    with ScreenLoader {
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
  Widget build(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          header: "Синхронизация\nс банком",
          leading: true,
          height: 82,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: _singleAdvantage(
                      "Безопасно", "Данные надежно зашифрованы"),
                ),
                _singleAdvantage("Надежно", "Не производим транзакции с карт."),
                _singleAdvantage("Удобно",
                    "Главное, экономия времени.\nВсе операции подгружается\nавтоматически по категориям."),
                Padding(
                  padding: const EdgeInsets.only(top: 92.0),
                  child: Center(
                      child: ButtonBlue(
                    text: "Подключить",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BankListPage(),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _singleAdvantage(String title, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextWidget(
              padding: 18,
              text: title,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.indicator),
            ),
            TextWidget(
              padding: 18,
              text: text,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.bodyCard),
            ),
          ],
        ),
      );
}

class BankListPage extends StatefulWidget {
  const BankListPage({
    Key? key,
  }) : super(key: key);

  @override
  _BankListPageState createState() => _BankListPageState();
}

class _BankListPageState extends State<BankListPage> {
  @override
  Widget build(BuildContext context) => ScaffoldAppBarCustom(
        header: "Банки",
        leading: true,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: BankTypes.values.map((e) => _singleBank(e)).toList(),
          ),
        ),
      );

  void _linkOpen() async {
    const url =
        "https://enter.tochka.com/api/v1/authorize/?response_type=code&client_id=C1VLYt1nQC8QPtDPyVPf9pfNsRXXCrom";
    if (await canLaunch(url))
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        universalLinksOnly: false,
      );
    else
      throw "Could not launch $url";
  }

  Widget _singleBank(BankTypes bank) => GestureDetector(
        onTap: () => bank.isWebView()
            ? _linkOpen()
            : bank.isTap()
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => AddInvoiceBloc(),
                        child: SingleBankPage(bank: bank),
                      ),
                    ),
                  )
                : {},
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: bank.icon(),
                width: 50,
                height: 50,
                clipBehavior: Clip.hardEdge,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: StyleColorCustom().setStyleByEnum(
                      context,
                      StyleColorEnum.secondaryBackground,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  height: 40,
                  margin: const EdgeInsets.only(left: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        padding: 0,
                        text: bank.title(),
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.bankTitle),
                      ),
                      SvgPicture.asset(AssetsPath.arrowRigth)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
}

class SingleBankPage extends StatefulWidget {
  const SingleBankPage({
    Key? key,
    required this.bank,
    this.code,
  }) : super(key: key);

  final BankTypes bank;
  final String? code;

  @override
  _SingleBankPageState createState() => _SingleBankPageState();
}

class _SingleBankPageState extends State<SingleBankPage> with ScreenLoader {
  final _formKey = GlobalKey<FormState>();
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  TextEditingController _controllerPhone = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  ValueNotifier<DateTime>? _dateTimePicker;

  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("ru");

    DateTime _dateTime = DateTime.now();

    _selectedDate =
        DateTime(_dateTime.year, _dateTime.month - 1, _dateTime.day);
    _dateTimePicker = ValueNotifier<DateTime>(_selectedDate!);

    context.read<AddInvoiceBloc>().add(DateUpdateEvent(date: _selectedDate!));
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
  Widget build(BuildContext context) =>
      BlocListener<AddInvoiceBloc, AddInvoiceState>(
        listener: (context, state) {
          if (state is ListErrorState) {
            stopLoading();

            showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text("Произошла ошибка"),
                content: const Text("Попробуйте повторить позднее"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text('Ок'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          }
          if (state is UpdateDateState) {
            _dateTimePicker!.value = state.date;
          }
          if (state is ListLoadingOpacityState) {
            startLoading();
          }
          if (state is ListLoadingOpacityHideState) {
            stopLoading();
          }
          if (state is CodeScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => AddInvoiceBloc(
                    bank: widget.bank,
                    bankUserId: state.tinkoffUserId,
                    phone: state.phone,
                    password: state.password,
                    date: state.date,
                  ),
                  child: CodeScreenPage(bank: widget.bank),
                ),
              ),
            );
          }
          if (state is GoToHomeScreen) {
            showCupertinoDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text("Успех"),
                content: const Text(
                    "Синхронизация прошла успешно, карты были добавлены!"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text('Ок'),
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  )
                ],
              ),
            );
          }
        },
        child: loadableWidget(
          child: ScaffoldAppBarCustom(
            header: widget.bank.title(),
            leading: true,
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _paranoiaWidget(),
                    widget.bank != BankTypes.tochka
                        ? _fieldWrapper(
                            "Введите логин от мобильного банка",
                            TextFieldWidget(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              filteringTextInputFormatter:
                                  widget.bank == BankTypes.tinkoff
                                      ? <TextInputFormatter>[maskFormatter]
                                      : [],
                              textAlign: TextAlign.center,
                              autofocus: true,
                              textInputType: widget.bank == BankTypes.tinkoff
                                  ? TextInputType.phone
                                  : TextInputType.text,
                              style: StyleTextCustom().setStyleByEnum(
                                  context, StyleTextEnum.afterInput),
                              labelText: widget.bank == BankTypes.tinkoff
                                  ? "+7**********"
                                  : "Введите логин",
                              fillColor: Colors.transparent,
                              validation: (String? value) {
                                if (widget.bank == BankTypes.tinkoff) {
                                  String pattern = r'(^(?:\+7)?[0-9\s]{14}$)';
                                  RegExp regExp = new RegExp(pattern);
                                  if (value?.length == 0) {
                                    return 'Пожалуйста введите номер телефона';
                                  } else if (!regExp.hasMatch(value!)) {
                                    return 'Пожалуйста введите номер телефона правильно';
                                  }
                                } else {
                                  if (value?.length == 0) {
                                    return 'Пожалуйста введите логин';
                                  }
                                }
                                return null;
                              },
                              controller: _controllerPhone,
                              underLineStyle: true,
                            ),
                          )
                        : SizedBox(),
                    widget.bank == BankTypes.tinkoff
                        ? _fieldWrapper(
                            "Пароль от интернет-банка и пин-код\nдля входа в приложение Тинькофф – \nразличные пароли.\nЕго необходимо активировать в ЛК банка.",
                            TextFieldWidget(
                              isDense: true,
                              obscureText: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              textAlign: TextAlign.center,
                              autofocus: true,
                              textInputType: TextInputType.visiblePassword,
                              style: StyleTextCustom().setStyleByEnum(
                                  context, StyleTextEnum.afterInput),
                              labelText: "Пароль",
                              fillColor: Colors.transparent,
                              validation: (String? value) {
                                if (value!.length < 4) {
                                  return 'Пожалуйста введите пароль правильно';
                                }
                                return null;
                              },
                              controller: _controllerPassword,
                              underLineStyle: true,
                            ),
                          )
                        : const SizedBox(),
                    _fieldWrapper(
                      "Дата загрузки операций",
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _showDialog(
                            CupertinoDatePicker(
                              initialDateTime: _selectedDate,
                              minimumDate: DateTime(2010, 1, 1),
                              maximumDate: _selectedDate,
                              mode: CupertinoDatePickerMode.date,
                              use24hFormat: true,
                              onDateTimeChanged: (DateTime newDate) {
                                context.read<AddInvoiceBloc>().add(
                                      DateUpdateEvent(
                                        date: newDate,
                                      ),
                                    );
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: StyleColorCustom().setStyleByEnum(
                                    context, StyleColorEnum.neitralColor),
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: ValueListenableBuilder(
                                      valueListenable: _dateTimePicker!,
                                      builder: (BuildContext context,
                                          DateTime _date, _) {
                                        var t = DateFormat.yMMMMd('ru')
                                            .format(_date);

                                        return TextWidget(
                                          padding: 0,
                                          text: t,
                                          style: StyleTextCustom()
                                              .setStyleByEnum(context,
                                                  StyleTextEnum.afterInput),
                                        );
                                      }),
                                ),
                              ),
                              Positioned(
                                child: SvgPicture.asset(
                                  AssetsPath.calendar,
                                  color: StyleColorCustom().setStyleByEnum(
                                      context, StyleColorEnum.neitralColor),
                                ),
                                right: 0,
                                top: 6,
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0, bottom: 18),
                      child: Center(
                        child: ButtonBlue(
                          text: "Подключить",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (widget.bank == BankTypes.tochka) {
                                context.read<AddInvoiceBloc>().add(
                                      SaveTochkaBankEvent(
                                        bank: widget.bank,
                                        date: DateTime.now(),
                                        code: widget.code,
                                      ),
                                    );
                              } else {
                                context.read<AddInvoiceBloc>().add(
                                      SaveBankEvent(
                                        bank: widget.bank,
                                        phone: _controllerPhone.text,
                                        password: _controllerPassword.text,
                                        date: DateTime.now(),
                                      ),
                                    );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  void _showDialog(Widget child) => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: child,
            ),
          ));

  Widget _paranoiaWidget() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: StyleColorCustom().setStyleByEnum(
            context,
            StyleColorEnum.secondaryBackground,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              color: CustomColors.dialButtonShadow,
              blurRadius: 15,
            )
          ],
        ),
        margin: const EdgeInsets.only(top: 20, left: 14, right: 14),
        padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 30),
        child: Stack(
          children: [
            TextWidget(
              padding: 0,
              text:
                  "Компании Wallet Box недоступны\nваши данные. Они шифруются и\nхранятся у вас в телефоне.\n\nСинхронизация данных не позволяет\nпереводить деньги с вашего счета! …",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.security),
            ),
            Positioned(
              right: 0,
              top: 0,
              width: 20,
              height: 20,
              child: SvgPicture.asset(AssetsPath.security_shield),
            )
          ],
        ),
      );

  Widget _fieldWrapper(String label, Widget _widget) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        margin: const EdgeInsets.only(top: 34),
        child: Column(
          children: [
            _widget,
            TextWidget(
              align: TextAlign.center,
              padding: 10,
              text: label,
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.afterInputText),
            ),
          ],
        ),
      );
}

class CodeScreenPage extends StatefulWidget {
  const CodeScreenPage({
    Key? key,
    required this.bank,
  }) : super(key: key);

  final BankTypes bank;

  @override
  _CodeScreenPageState createState() => _CodeScreenPageState();
}

class _CodeScreenPageState extends State<CodeScreenPage> with ScreenLoader {
  final _formKey = GlobalKey<FormState>();
  // MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
  //   mask: '####',
  //   filter: {"#": RegExp(r'[0-9]')},
  // );
  final ValueNotifier<int> _lock = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (timer.tick == 300) timer.cancel();
        _lock.value = 300 - timer.tick;
      },
    );
  }

  final TextEditingController _controllerCode = TextEditingController(text: "");
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
  Widget build(BuildContext context) =>
      BlocListener<AddInvoiceBloc, AddInvoiceState>(
        listener: (context, state) {
          if (state is ListLoadingOpacityState) {
            startLoading();
          }
          if (state is ListLoadingOpacityHideState) {
            stopLoading();
          }
          if (state is GoToHomeScreen) {
            showCupertinoDialog<void>(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                title: const Text("Успех"),
                content: const Text(
                    "Синхронизация прошла успешно, карты были добавлены!"),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text('Ок'),
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  )
                ],
              ),
            );
          }
        },
        child: loadableWidget(
          child: ScaffoldAppBarCustom(
            header: widget.bank.title(),
            leading: true,
            body: Form(
              key: _formKey,
              child: Center(
                child: ContainerCustom(
                  turnColor: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        padding: 0,
                        text: "Введите код из SMS",
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.security),
                        align: TextAlign.center,
                      ),
                      TextFieldWidget(
                        obscureText: true,
                        filteringTextInputFormatter: <TextInputFormatter>[
                          MaskTextInputFormatter(
                            mask: widget.bank == BankTypes.tinkoff
                                ? '####'
                                : '#####',
                            filter: {"#": RegExp(r'[0-9]')},
                          )
                        ],
                        textAlign: TextAlign.center,
                        autofocus: true,
                        textInputType: TextInputType.number,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.neutralText),
                        labelText:
                            widget.bank == BankTypes.tinkoff ? "0000" : "00000",
                        fillColor: StyleColorCustom().setStyleByEnum(
                            context, StyleColorEnum.secondaryBackground),
                        validation: (String? value) {
                          if (value?.length != 4) {
                            return 'Пожалуйста введите код правильно';
                          }
                          return null;
                        },
                        controller: _controllerCode,
                      ),
                      SizedBox(
                        width: 190,
                        child: ValueListenableBuilder(
                          valueListenable: _lock,
                          builder: (BuildContext context, int _state, _) =>
                              TextWidget(
                            padding: 10,
                            text:
                                "${(_state ~/ 60).round().toString().padLeft(2, '0')}:${(_state % 60).toString().padLeft(2, '0')}",
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.security),
                            align: TextAlign.center,
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {},
                            child: SizedBox(
                              height: 40,
                              width: 134,
                              child: Center(
                                child: TextWidget(
                                  padding: 10,
                                  text: "Отменить",
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.indicator),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => context.read<AddInvoiceBloc>().add(
                                  BankConnectSubmit(
                                    code: _controllerCode.text,
                                  ),
                                ),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 5),
                                    color: CustomColors.dialButtonShadow,
                                    blurRadius: 15,
                                  )
                                ],
                                color: StyleColorCustom().setStyleByEnum(
                                  context,
                                  StyleColorEnum.secondaryBackground,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              margin: const EdgeInsets.only(left: 18),
                              height: 40,
                              width: 60,
                              child: Center(
                                child: TextWidget(
                                  padding: 10,
                                  text: "Ok",
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.indicator),
                                  align: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
