import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen_events.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen_states.dart';

class SupprotScreen extends StatefulWidget {
  const SupprotScreen({Key? key}) : super(key: key);
  @override
  _SupprotScreenState createState() => _SupprotScreenState();
}

class _SupprotScreenState extends State<SupprotScreen> with ScreenLoader {
  final _formKey = GlobalKey<FormState>();
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TextEditingController _controller = TextEditingController(text: "");
  final TextEditingController _controllerEmail =
      TextEditingController(text: "");
  final TextEditingController _controllerText = TextEditingController(text: "");

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
    return BlocListener<SupprotScreenBloc, SupprotScreenState>(
      listener: (context, state) {
        if (state is ShowMessageState) {
          _showMyDialog(
            context,
            title: "Успех",
            message: "Обращение успешно отправлено!",
          );
          _controller.text = "";
          _controllerEmail.text = "";
          _controllerText.text = "";
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

  Future<void> _showMyDialog(
    context, {
    required String title,
    required String message,
  }) async {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('Ок'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _scaffold(BuildContext context) => loadableWidget(
        child: ScaffoldAppBarCustom(
          header: textString_18,
          leading: true,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextWidget(
                            text: textString_14,
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.titleCard),
                          ),
                        ),
                        TextFieldWidget(
                          filteringTextInputFormatter: <TextInputFormatter>[
                            maskFormatter
                          ],
                          icon: Icons.phone_outlined,
                          colorIcon: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.colorIcon),
                          autofocus: false,
                          textInputType: TextInputType.number,
                          style: StyleTextCustom().setStyleByEnum(
                              context, StyleTextEnum.neutralText),
                          labelText: textString_9,
                          fillColor: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.secondaryBackground),
                          validation: (String? value) {
                            String pattern = r'(^(?:\+7)?[0-9\s]{14}$)';
                            RegExp regExp = RegExp(pattern);
                            if (value?.length == 0) {
                              return 'Пожалуйста введите номер телефона';
                            } else if (!regExp.hasMatch(value!)) {
                              return 'Пожалуйста введите номер телефона правильно';
                            }
                            return null;
                          },
                          controller: _controller,
                        ),
                      ],
                    ),
                  ),
                  ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextWidget(
                            text: textString_15,
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.titleCard),
                          ),
                        ),
                        TextFieldWidget(
                          icon: Icons.email_outlined,
                          colorIcon: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.colorIcon),
                          filteringTextInputFormatter: <TextInputFormatter>[
                            FilteringTextInputFormatter.singleLineFormatter
                          ],
                          autofocus: false,
                          textInputType: TextInputType.emailAddress,
                          style: StyleTextCustom().setStyleByEnum(
                              context, StyleTextEnum.neutralText),
                          labelText: textString_12,
                          fillColor: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.secondaryBackground),
                          controller: _controllerEmail,
                          validation: (String? email) {
                            if (RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-\/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(email ?? "")) {
                              return null;
                            }
                            return 'Пожалуйста укажите E-mail правильно';
                          },
                        ),
                      ],
                    ),
                  ),
                  ContainerCustom(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextWidget(
                            text: textString_16,
                            style: StyleTextCustom().setStyleByEnum(
                                context, StyleTextEnum.titleCard),
                          ),
                        ),
                        TextFieldWidget(
                          autofocus: false,
                          textInputType: TextInputType.multiline,
                          style: StyleTextCustom().setStyleByEnum(
                              context, StyleTextEnum.neutralText),
                          labelText: textString_17,
                          fillColor: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.secondaryBackground),
                          validation: (String? text) {
                            if (text!.length < 4) {
                              return 'Пожалуйста заполните текст обращения';
                            }
                            return null;
                          },
                          controller: _controllerText,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonCancel(
                          text: textString_11,
                          onPressed: () => Navigator.pop(context)),
                      ButtonBlue(
                        text: textString_13,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<SupprotScreenBloc>().add(
                                  StartCreateTicket(body: {
                                    "phone": _controller.text
                                        .replaceAll(RegExp(r"\s+\b|\b\s"), ""),
                                    "email": _controllerEmail.text,
                                    "content": _controllerText.text,
                                  }),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
