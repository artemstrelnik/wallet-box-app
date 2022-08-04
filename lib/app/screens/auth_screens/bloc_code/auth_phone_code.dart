import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_code_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/widgets/text_dialog.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';
import 'package:wallet_box/app/screens/password_restore_final/password_restore_final_bloc.dart';
import 'package:wallet_box/app/screens/password_restore_final/password_restore_final_page.dart';

import '../bloc_email/auth_email_bloc.dart';
import '../bloc_email/auth_phone_email.dart';
import 'auth_code_events.dart';
import 'auth_code_states.dart';

class AuthPhoneCode extends StatefulWidget {
  const AuthPhoneCode({Key? key}) : super(key: key);

  @override
  _AuthPhoneCodeState createState() => _AuthPhoneCodeState();
}

class _AuthPhoneCodeState extends State<AuthPhoneCode> with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController(text: "");
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final ValueNotifier<ScreenType> _screenType =
      ValueNotifier<ScreenType>(ScreenType.code);
  final ValueNotifier<LoadingState> _loadingState =
      ValueNotifier<LoadingState>(LoadingState.loading);
  final ValueNotifier<int> _lock = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    context.read<AuthCodeBloc>().add(
          SmsSubmitEvent(),
        );
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
    return BlocListener<AuthCodeBloc, AuthCodeState>(
      listener: (context, state) {
        if (state is ChangePasswordScreen) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => PasswordRestoreFinalBloc(
                  phone: state.phone,
                  token: state.token,
                  uid: state.uid,
                ),
                child: PasswordRestoreFinalPage(),
              ),
            ),
          );
        }
        if (state is ChangeScreenType) {
          _screenType.value = ScreenType.password;
        }
        if (state is ChangeLoadingState) {
          _loadingState.value = LoadingState.loaded;
        }

        if (state is ShowMessageState) {
          showMyDialog(context, title: state.title, message: state.message);
        }

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
        if (state is EmailEntryState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AuthEmailBloc(
                  phone: state.phone,
                ),
                child: AuthPhoneEmail(),
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
        if (state is StartTimerState) {
          Timer.periodic(
            const Duration(seconds: 1),
            (timer) {
              if (timer.tick == 60) timer.cancel();
              _lock.value = 60 - timer.tick;
            },
          );
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
            child: ValueListenableBuilder(
              valueListenable: _loadingState,
              builder: (BuildContext context, LoadingState _state, _) =>
                  _state == LoadingState.loaded
                      ? Form(
                          key: _formKey,
                          child: ValueListenableBuilder(
                            valueListenable: _screenType,
                            builder:
                                (BuildContext context, ScreenType _type, _) =>
                                    Column(
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
                                  obscureText: true,
                                  // autocorrect: false,
                                  // enableSuggestions: false,
                                  filteringTextInputFormatter:
                                      _type == ScreenType.code
                                          ? <TextInputFormatter>[maskFormatter]
                                          : <TextInputFormatter>[],
                                  textAlign: TextAlign.center,
                                  autofocus: true,
                                  textInputType: _type == ScreenType.code
                                      ? TextInputType.number
                                      : TextInputType.emailAddress,
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.neutralText),
                                  labelText: _type == ScreenType.code
                                      ? textString_8
                                      : "Введите пароль",
                                  fillColor: StyleColorCustom().setStyleByEnum(
                                      context,
                                      StyleColorEnum.secondaryBackground),
                                  validation: (String? value) {
                                    if (_type == ScreenType.code) {
                                      if (value?.length != 4) {
                                        return 'Пожалуйста введите код правильно';
                                      }
                                    } else {
                                      if (value!.length < 4) {
                                        return 'Пожалуйста введите пароль правильно';
                                      }
                                    }

                                    return null;
                                  },
                                  controller: _controller,
                                ),
                                TextWidget(
                                  text: _type.helpTitle(),
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.neutralText),
                                  align: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment: _type == ScreenType.code
                                      ? MainAxisAlignment.spaceEvenly
                                      : MainAxisAlignment.center,
                                  children: [
                                    _type == ScreenType.code
                                        ? ButtonCancel(
                                            text: textString_11,
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })
                                        : Container(),
                                    ButtonBlue(
                                        text: textString_10,
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthCodeBloc>().add(
                                                  AuthUserEvent(
                                                      code: _controller.text),
                                                );
                                          }
                                        }),
                                  ],
                                ),
                                _type == ScreenType.code
                                    ? ValueListenableBuilder(
                                        valueListenable: _lock,
                                        builder: (BuildContext context,
                                                int _state, _) =>
                                            Column(
                                          children: [
                                            _state != 0
                                                ? TextWidget(
                                                    align: TextAlign.center,
                                                    padding: 20,
                                                    text:
                                                        "Повторная отправка кода\nбудет доступная через - " +
                                                            _state.toString(),
                                                    style: StyleTextCustom()
                                                        .setStyleByEnum(
                                                            context,
                                                            StyleTextEnum
                                                                .afterInput),
                                                  )
                                                : const SizedBox(),
                                            Opacity(
                                              opacity: _state == 0 ? 1.0 : .5,
                                              child: ButtonNoBackground(
                                                  text: textString_6,
                                                  onPressed: () {
                                                    return _state == 0
                                                        ? context
                                                            .read<
                                                                AuthCodeBloc>()
                                                            .add(
                                                              SmsSubmitEvent(),
                                                            )
                                                        : null;
                                                    // Navigator.push(context,
                                                    //     MaterialPageRoute(builder: (_) => const AuthPhoneCode()));
                                                  }),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
