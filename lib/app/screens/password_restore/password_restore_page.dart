import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_code_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_phone_code.dart';

import 'password_restore_bloc.dart';
import 'password_restore_events.dart';
import 'password_restore_states.dart';

class PasswordRestorePage extends StatefulWidget {
  @override
  _PasswordRestorePageState createState() => _PasswordRestorePageState();
}

class _PasswordRestorePageState extends State<PasswordRestorePage> {
  late UserNotifierProvider _userProvider;
  final _formKey = GlobalKey<FormState>();
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '+7 ### ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TextEditingController _controller = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<PasswordRestoreBloc, PasswordRestoreState>(
      listener: (context, state) {
        if (state is CodeEntryState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AuthCodeBloc(
                  isExists: state.isExists,
                  phone: state.phone,
                  isPassword: state.isExists,
                  isRestore: true,
                ),
                child: const AuthPhoneCode(),
              ),
            ),
          );
        }
      },
      child: _scaffold(context),
    );
  }

  Future<void> _showMyDialog(context,
      {required String message,
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

  Widget _scaffold(BuildContext context) => ScaffoldAppBarCustom(
        header: "Восстановление\nдоступа",
        leading: true,
        height: 82,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(
                text:
                    "Введите номер телефона, которые вы укаазали при регистрации. После проверки вы сможете поменять пароль.", //Новый пароль мы отправим на почту
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.neutralText),
                align: TextAlign.left,
              ),
              TextFieldWidget(
                filteringTextInputFormatter: <TextInputFormatter>[
                  maskFormatter
                ],
                paddingTop: const EdgeInsets.only(top: 32),
                textAlign: TextAlign.center,
                autofocus: true,
                textInputType: TextInputType.number,
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.neutralText),
                labelText: "Номер телефона",
                fillColor: StyleColorCustom().setStyleByEnum(
                    context, StyleColorEnum.secondaryBackground),
                validation: (String? value) {
                  String pattern = r'(^(?:\+7)?[0-9\s]{14}$)';
                  RegExp regExp = new RegExp(pattern);
                  if (value?.length == 0) {
                    return 'Пожалуйста введите номер телефона';
                  } else if (!regExp.hasMatch(value!)) {
                    return 'Пожалуйста введите номер телефона правильно';
                  }
                  return null;
                },
                controller: _controller,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonBlue(
                      text: textString_10,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<PasswordRestoreBloc>().add(
                                AuthCheckRegisterEvent(phone: _controller.text),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
