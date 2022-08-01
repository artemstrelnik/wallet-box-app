import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_code_bloc.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';

import 'auth_password_bloc.dart';
import 'auth_password_events.dart';
import 'auth_password_states.dart';
import 'package:screen_loader/screen_loader.dart';

class AuthPasswordPage extends StatefulWidget {
  const AuthPasswordPage({Key? key}) : super(key: key);

  @override
  _AuthPasswordCodeState createState() => _AuthPasswordCodeState();
}

class _AuthPasswordCodeState extends State<AuthPasswordPage> with ScreenLoader {
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

  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    context.read<AuthPasswordBloc>().add(
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
    return BlocListener<AuthPasswordBloc, AuthPasswordState>(
      listener: (context, state) {
        if (state is ChangeScreenType) {
          _screenType.value = ScreenType.password;
        }
        if (state is ChangeLoadingState) {
          _loadingState.value = LoadingState.loaded;
        }

        if (state is HomeEntryState) {
          _userProvider.setUser = state.user;
          messaging.getToken().then((value) {
            _updateToken(token: value!);
          });
          messaging.onTokenRefresh.listen((token) async {
            await _updateToken(token: token);
          });

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

  Future<void> _updateToken({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    String firebaseTokenPrefKey = 'firebaseToken';
    final String? currentToken = prefs.getString(firebaseTokenPrefKey);
    if (currentToken != token) {
      // final String deviceId = Platform.isAndroid
      //     ? 'android_${DateTime.now()}'
      //     : 'ios_${DateTime.now()}';
      try {
        context.read<AuthPasswordBloc>().add(
              UpdateUserTokenEvent(token: token!),
            );
        await prefs.setString(firebaseTokenPrefKey, token);
      } catch (e) {
        print(e);
      }
    }
  }

  Widget _scaffold(BuildContext context) {
    return loadableWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 20, right: 20),
          child: ValueListenableBuilder(
            valueListenable: _loadingState,
            builder: (BuildContext context, LoadingState _state, _) => _state ==
                    LoadingState.loaded
                ? Form(
                    key: _formKey,
                    child: ValueListenableBuilder(
                      valueListenable: _screenType,
                      builder: (BuildContext context, ScreenType _type, _) =>
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
                                context, StyleColorEnum.secondaryBackground),
                            validation: (String? value) {
                              if (value!.length < 4) {
                                return 'Пожалуйста введите пароль правильно';
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
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthPasswordBloc>().add(
                                            AuthUserEvent(
                                                code: _controller.text),
                                          );
                                    }
                                  }),
                            ],
                          ),
                          _type == ScreenType.code
                              ? ButtonNoBackground(
                                  text: textString_6,
                                  onPressed: () {
                                    context.read<AuthPasswordBloc>().add(
                                          SmsSubmitEvent(),
                                        );
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (_) => const AuthPhoneCode()));
                                  })
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
    );
  }
}
