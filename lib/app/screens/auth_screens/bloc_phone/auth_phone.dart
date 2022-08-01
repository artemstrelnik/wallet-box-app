import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_email/auth_email_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_email/auth_phone_email.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_phone/auth_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen.dart';
import 'package:wallet_box/app/screens/auth_screens/support/support_screen_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_page.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_page.dart';

import '../bloc_code/auth_phone_code.dart';
import '../bloc_code/auth_code_bloc.dart';
import 'auth_events.dart';
import 'auth_states.dart';
import 'package:screen_loader/screen_loader.dart';

class AuthPhone extends StatefulWidget {
  const AuthPhone({Key? key}) : super(key: key);

  @override
  _AuthPhoneState createState() => _AuthPhoneState();
}

class _AuthPhoneState extends State<AuthPhone> with ScreenLoader {
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is CodeEntryState) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => BlocProvider(
          //       create: (context) => AuthEmailBloc(
          //         phone: state.phone,
          //       ),
          //       child: AuthPhoneEmail(),
          //     ),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AuthCodeBloc(
                  isExists: state.isExists,
                  phone: state.phone,
                  isPassword: state.isExists,
                ),
                child: AuthPhoneCode(),
              ),
            ),
          );
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

  Widget _scaffold(BuildContext context) {
    return loadableWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: Center(
                      child: ConstContext.lightMode(context)
                          ? Image.asset(logoLight)
                          : Image.asset(logoDark),
                    ),
                  ),
                  TextFieldWidget(
                    filteringTextInputFormatter: <TextInputFormatter>[
                      maskFormatter
                    ],
                    autofocus: true,
                    textInputType: TextInputType.phone,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.neutralText),
                    labelText: textString_9,
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
                  TextWidget(
                    text: textString_1,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.neutralText),
                    align: TextAlign.center,
                  ),
                  TextWidget(
                    text: textString_2,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.neutralText),
                    align: TextAlign.center,
                  ),
                  ButtonBlue(
                    text: textString_10,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              AuthCheckRegisterEvent(phone: _controller.text),
                            );
                      }
                    },
                  ),
                  ButtonNoBackground(
                    text: textString_3,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => PasswordRestoreBloc(),
                          child: PasswordRestorePage(),
                        ),
                      ),
                    ),
                  ),
                  ButtonNoBackground(
                    text: textString_4,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => SupprotScreenBloc(),
                            child: SupprotScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
