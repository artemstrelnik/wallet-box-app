import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';

import 'password_restore_final_bloc.dart';
import 'password_restore_final_events.dart';
import 'password_restore_final_states.dart';

class PasswordRestoreFinalPage extends StatefulWidget {
  @override
  _PasswordRestoreFinalPageState createState() =>
      _PasswordRestoreFinalPageState();
}

class _PasswordRestoreFinalPageState extends State<PasswordRestoreFinalPage> {
  late UserNotifierProvider _userProvider;
  final _formKey = GlobalKey<FormState>();
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
    return BlocListener<PasswordRestoreFinalBloc, PasswordRestoreFinalState>(
      listener: (context, state) {
        if (state is HomeEntryState) {
          _userProvider.setUser = state.user;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => HomeScreenBloc(),
                child: const HomeScreen(),
              ),
            ),
            (route) => false,
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
        header: "Восстановление\nпароля",
        leading: true,
        height: 82,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(
                text:
                    "Введите новый пароль, чтобы восстановить доступ к учетной записи.",
                style: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.neutralText),
                align: TextAlign.left,
              ),
              TextFieldWidget(
                filteringTextInputFormatter: <TextInputFormatter>[],
                paddingTop: const EdgeInsets.only(top: 32),
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
                          context.read<PasswordRestoreFinalBloc>().add(
                                AuthUserEvent(code: _controller.text),
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
