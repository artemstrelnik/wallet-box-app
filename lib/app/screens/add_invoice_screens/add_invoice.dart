import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/screens/synchronization/synchronization_page.dart';

import '../../core/constants/constants.dart';
import '../../core/themes/colors.dart';
import 'add_invoice_bloc.dart';
import 'add_invoice_events.dart';
import 'add_invoice_states.dart';
import 'package:screen_loader/screen_loader.dart';

class AddInvoice extends StatefulWidget {
  const AddInvoice({
    this.isOperation = false,
    this.isEditing = false,
    this.name,
    this.balance,
    this.id,
    Key? key,
  }) : super(key: key);

  final bool isOperation;
  final bool isEditing;
  final String? name;
  final String? balance;
  final String? id;
  @override
  _AddInvoiceState createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> with ScreenLoader {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerName = TextEditingController(text: "");
  final TextEditingController _controllerBalance =
      TextEditingController(text: "");

  final _phoneFormKey = GlobalKey<FormState>();
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TextEditingController _phoneController =
      TextEditingController(text: "");

  final _secureFormKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController(text: "");
  final TextEditingController _passworfController =
      TextEditingController(text: "");
  MaskTextInputFormatter codeMaskFormatter = MaskTextInputFormatter(
    mask: '####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
  void initState() {
    super.initState();
    if (widget.name != null) _controllerName.text = widget.name!;
    if (widget.balance != null) _controllerBalance.text = widget.balance!;
  }

  @override
  loadingBgBlur() => 10.0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddInvoiceBloc, AddInvoiceState>(
      listener: (context, state) {
        if (state is BillCreateState) {
          if (widget.isOperation) {
            Map<String, dynamic> _map = <String, dynamic>{};

            _map["successes"] = true;
            if (state.bill != null) {
              _map["bill"] = state.bill;
            }

            Navigator.pop(context, _map);
          } else {
            Navigator.pop(context, true);
          }
        }
        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is SecureEntryState) {
          Navigator.pop(context);
          _showBottom(context, "Выберите банк", [
            Form(
              key: _secureFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFieldWidget(
                    obscureText: true,
                    filteringTextInputFormatter: <TextInputFormatter>[
                      codeMaskFormatter
                    ],
                    textAlign: TextAlign.center,
                    autofocus: true,
                    textInputType: TextInputType.number,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.neutralText),
                    labelText: textString_8,
                    fillColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.secondaryBackground),
                    validation: (String? value) {
                      if (value?.length != 4) {
                        return 'Пожалуйста введите код правильно';
                      }
                      return null;
                    },
                    controller: _codeController,
                  ),
                  TextFieldWidget(
                    obscureText: true,
                    filteringTextInputFormatter: <TextInputFormatter>[],
                    textAlign: TextAlign.center,
                    autofocus: true,
                    textInputType: TextInputType.emailAddress,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.neutralText),
                    labelText: "Введите пароль",
                    fillColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.secondaryBackground),
                    validation: (String? value) {
                      if (value!.length < 4) {
                        return 'Пожалуйста введите пароль правильно';
                      }
                      return null;
                    },
                    controller: _passworfController,
                  ),
                  ButtonBlue(
                    text: "Войти",
                    onPressed: () {
                      if (_secureFormKey.currentState!.validate()) {
                        context.read<AddInvoiceBloc>().add(
                              BankConnectSubmit(
                                code: _codeController.text,
                              ),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ]);
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          header: widget.isEditing ? "Редактирование\nсчета" : textString_19,
          height: 82,
          leading: true,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: textString_26,
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.titleCard),
                        ),
                        TextFieldWidget(
                            filteringTextInputFormatter: <TextInputFormatter>[
                              FilteringTextInputFormatter.singleLineFormatter
                            ],
                            autofocus: false,
                            textInputType: TextInputType.name,
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.neutralText),
                            labelText: textString_20,
                            fillColor: StyleColorCustom().setStyleByEnum(
                                context, StyleColorEnum.primaryBackground),
                            controller: _controllerName,
                            validation: (value) =>
                                value!.length < 4 ? "Минимум 4 символа" : null),
                        TextWidget(
                          text: textString_21,
                          style: StyleTextCustom()
                              .setStyleByEnum(context, StyleTextEnum.titleCard),
                        ),
                        TextFieldWidget(
                          filteringTextInputFormatter: <TextInputFormatter>[
                            FilteringTextInputFormatter.singleLineFormatter
                          ],
                          autofocus: false,
                          textInputType: TextInputType.number,
                          style: StyleTextCustom().setStyleByEnum(
                              context, StyleTextEnum.neutralText),
                          labelText: textString_22,
                          fillColor: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.primaryBackground),
                          controller: _controllerBalance,
                        ),
                      ],
                    ),
                  ),
                ),
                widget.isEditing || widget.isOperation
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SynchronizationPage(),
                          ),
                        ),
                        behavior: HitTestBehavior.translucent,
                        child: ContainerCustom(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 8.0, top: 2.0),
                                child: Icon(
                                  Icons.credit_card_outlined,
                                  color: StyleColorCustom().setStyleByEnum(
                                      context, StyleColorEnum.colorIcon),
                                ),
                              ),
                              TextWidget(
                                padding: 0,
                                text: textString_23,
                                style: StyleTextCustom().setStyleByEnum(
                                    context, StyleTextEnum.titleCard),
                              )
                            ],
                          ),
                        ),
                      ),
                widget.isEditing || widget.isOperation
                    ? const SizedBox()
                    : TextWidget(
                        align: TextAlign.center,
                        text: textString_24,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard)),
                widget.isEditing || widget.isOperation
                    ? const SizedBox()
                    : TextWidget(
                        align: TextAlign.center,
                        text: textString_25,
                        style: StyleTextCustom()
                            .setStyleByEnum(context, StyleTextEnum.titleCard)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonCancel(
                        text: textString_11,
                        onPressed: () => Navigator.pop(context)),
                    ButtonPink(
                      text: widget.isEditing ? "Сохранить" : textString_27,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.isEditing
                              ? context.read<AddInvoiceBloc>().add(
                                    BillUpdateEvent(
                                      id: widget.id!,
                                      name: _controllerName.text,
                                      balance: _controllerBalance.text,
                                    ),
                                  )
                              : context.read<AddInvoiceBloc>().add(
                                    StartBillCreateEvent(
                                      name: _controllerName.text,
                                      balance: _controllerBalance.text,
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
        ),
      );

  void _showBottom(
    BuildContext _context,
    String title,
    List<Widget> _list,
  ) =>
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: _context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: StyleColorCustom().setStyleByEnum(
                    context, StyleColorEnum.secondaryBackground),
              ),
              padding: const EdgeInsets.all(32),
              height: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextWidget(
                    padding: 0,
                    text: title,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.titleCard),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: _list),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _singleBank({required String title, required Function() onTap}) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
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
                      color: Color(int.parse("0xFFEDEDED")),
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(int.parse("0xFFEDEDED")).withOpacity(.4),
                          Color(int.parse("0xFFEDEDED")),
                        ],
                      ),
                    ),
                    child: Center(
                        // child: svgIcon(
                        //   baseUrl + "api/v1/image/content/" + _cat.icon.name,
                        // ),
                        ),
                  ),
                ),
                TextWidget(
                  padding: 10,
                  text: title,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard),
                  align: TextAlign.center,
                ),
              ],
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
      );
}
