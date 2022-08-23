import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/src/provider.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/bloc/my_app_bloc.dart';
import 'package:wallet_box/app/bloc/my_app_page.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/constants/string.dart';
import 'package:wallet_box/app/core/generals_widgets/animation_list.dart';
import 'package:wallet_box/app/core/generals_widgets/container.dart';
import 'package:wallet_box/app/core/generals_widgets/dialog.dart';
import 'package:wallet_box/app/core/generals_widgets/scaffold_app_bar.dart';
import 'package:wallet_box/app/core/generals_widgets/text.dart';
import 'package:wallet_box/app/core/generals_widgets/text_field.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/core/themes/themes.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import 'package:wallet_box/app/data/net/models/my_subscription_variable.dart';
import 'package:wallet_box/app/screens/settings_screens/currencies_screens/currencies_screens.dart';
import 'package:wallet_box/app/screens/settings_screens/currencies_screens/currencies_screens_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/delete_data/delete_data.dart';
import 'package:wallet_box/app/screens/settings_screens/delete_data/delete_data_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/export_screen/export_screen_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/export_screen/export_screens.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_bloc.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_events.dart';
import 'package:wallet_box/app/screens/settings_screens/setting_main/setting_screen_states.dart';
import 'package:wallet_box/app/screens/settings_screens/subscription_screen/subscription_screen.dart';
import 'package:wallet_box/app/screens/settings_screens/subscription_screen/subscription_screen_bloc.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:intl/intl.dart';

enum _ScreenState {
  loading,
  loaded,
  error,
}

enum _EditState {
  disabled,
  enabled,
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final ValueNotifier<_ScreenState> _initSettingApp =
      ValueNotifier<_ScreenState>(_ScreenState.loading);
  final ValueNotifier<LoadingState> _subscriptionState =
      ValueNotifier<LoadingState>(LoadingState.loading);
  final ValueNotifier<MySubscription?> _mySubscriptionState =
      ValueNotifier<MySubscription?>(null);
  final _formKey = GlobalKey<FormState>();
  final password = RandomPasswordGenerator();

  final ValueNotifier<bool> _googleNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _pinCodeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _touchIDNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _noificationsNotifier = ValueNotifier<bool>(false);
  final TextEditingController _controller = TextEditingController(text: "");
  MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
    mask: '####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _phoneFormKey = GlobalKey<FormState>();
  MaskTextInputFormatter _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7-###-###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final TextEditingController _phoneController =
      TextEditingController(text: "");
  final ValueNotifier<_EditState> _phoneEditState =
      ValueNotifier<_EditState>(_EditState.disabled);

  final _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final ValueNotifier<_EditState> _emailEditState =
      ValueNotifier<_EditState>(_EditState.disabled);

  late List<Currency> _currencies;
  final ValueNotifier<Currency?> _currencyNotifier =
      ValueNotifier<Currency?>(null);

  @override
  void initState() {
    super.initState();
    context.read<SettingScreenBloc>().add(
          PageOpenedEvent(),
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

    Provider.of<UserNotifierProvider>(context).addListener(() {
      if (_userProvider.user != null) {
        _currencyNotifier.value = _currencies
            .where((e) => e.walletSystemName == _userProvider.user!.walletType)
            .first;
      }
    });

    return BlocListener<SettingScreenBloc, SettingScreenState>(
      listener: (context, state) {
        if (state is GoToStartScreen) {
          _userProvider.setUser = null;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => MyAppBloc(),
                child: MyApp(),
              ),
            ),
            (route) => false,
          );
        }
        if (state is UpdateCurrenciesList) {
          _currencies = state.list;
        }
        if (state is ListLoadingOpacityState) {
          startLoading();
        }
        if (state is ListLoadingOpacityHideState) {
          stopLoading();
        }
        if (state is OpenSettingState) {
          _userProvider.setUser = state.user;
          _touchIDNotifier.value = state.user.touchID;
          _pinCodeNotifier.value = state.user.pinCode.isNotEmpty;
          _phoneController.text =
              _phoneMaskFormatter.maskText(state.user.username ?? "");
          _googleNotifier.value = state.user.googleLink;
          _emailController.text = state.user.email.address ?? "";
          //_noificationsNotifier.value = state.user.notificationsEnable;
          _currencyNotifier.value = _currencies
              .where((e) => e.walletSystemName == state.user.walletType)
              .first;

          _initSettingApp.value = _ScreenState.loaded;
        }
        if (state is StartPinCodeChangeState) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ConstContext.lightMode(context)
                      ? CustomColors.lightPrimaryBackground
                      : CustomColors.darkPrimaryBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: OverflowBox(
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        TextFieldWidget(
                          filteringTextInputFormatter: <TextInputFormatter>[
                            maskFormatter
                          ],
                          autofocus: true,
                          textAlign: TextAlign.center,
                          textInputType: TextInputType.phone,
                          style: StyleTextCustom().setStyleByEnum(
                              context, StyleTextEnum.neutralText),
                          labelText: "Введите пин-код",
                          fillColor: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.secondaryBackground),
                          validation: (String? value) {
                            if (value?.length != 4) {
                              return 'Пожалуйста введите код правильно';
                            }
                            return null;
                          },
                          controller: _controller,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _pinCodeNotifier.value = false;
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Отмена",
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.neutralText),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SettingScreenBloc>().add(
                                          StartPinCodeUpdateEvent(
                                            code: _controller.text,
                                            uid: _userProvider.user!.id,
                                          ),
                                        );
                                  }
                                },
                                child: Text(
                                  "Применить",
                                  style: StyleTextCustom().setStyleByEnum(
                                      context, StyleTextEnum.neutralText),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                width: 250,
                height: 150,
                alignment: Alignment.center,
              ),
            ),
          );
        }
        if (state is StopPinCodeChangeState) {
          _controller.text = "";
          Navigator.pop(context);
        }
        if (state is ToAuthPage) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => MyAppBloc(),
                child: MyApp(),
              ),
            ),
            (route) => false,
          );
        }
        if (state is UpdateSubscriptionState) {
          if (state.sub != null) {
            _mySubscriptionState.value = state.sub;
            _subscriptionState.value = LoadingState.loaded;
          } else {
            _subscriptionState.value = LoadingState.empty;
          }
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    return loadableWidget(
      child: ScaffoldAppBarCustom(
        header: textString_28,
        leading: true,
        body: ValueListenableBuilder(
          valueListenable: _initSettingApp,
          builder: (BuildContext context, _ScreenState _state, _) {
            switch (_state) {
              case _ScreenState.loaded:
                return _listSettings();
              default:
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  _subscriptionWidget() => ValueListenableBuilder(
        valueListenable: _subscriptionState,
        builder: (BuildContext context, LoadingState _state, _) =>
            GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => SubscriptionScreenBloc(),
                child: SubscriptionScreen(),
              ),
            ),
          ),
          child: ContainerCustom(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _mySubscriptionWidget(_state),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: SizedBox(
                    height: 40,
                    child: ConstContext.lightMode(context)
                        ? Image.asset(logoLight)
                        : Image.asset(logoDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  List<Widget> _mySubscriptionWidget(LoadingState _state) {
    switch (_state) {
      case LoadingState.empty:
        return [
          TextWidget(
            padding: 0,
            text:
                "Ведите учет максимально\nэффективно, откройте доступ\nко всем функциям",
            style: StyleTextCustom()
                .setStyleByEnum(context, StyleTextEnum.bodyCard),
          ),
          TextWidget(
              padding: 0,
              text: "Приобрести подписку",
              style: StyleTextCustom()
                  .setStyleByEnum(context, StyleTextEnum.titleCard)),
        ];
      case LoadingState.loaded:
        return [
          ValueListenableBuilder(
            valueListenable: _mySubscriptionState,
            builder: (BuildContext context, MySubscription? _my, _) {
              var date = DateTime.parse(_my!.endDate);
              final DateFormat dateFormat = DateFormat('dd.MM.yyyy', "ru");
              final _date = dateFormat.format(date);
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                      padding: 0,
                      text: _my.variant.name,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                  TextWidget(
                      padding: 0,
                      text: "Действует до " + _date,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.titleCard)),
                ],
              );
            },
          ),
        ];
      default:
        return [CircularProgressIndicator()];
    }
  }

  Widget _listSettings() {
    return Form(
      key: _formKey,
      child: AnimationLimiter(
        child: ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: [
            CustomAnimationList(position: 0, child: _subscriptionWidget()),
            CustomAnimationList(position: 1, child: _phoneEditWidget()),
            CustomAnimationList(position: 2, child: _emailEditWidget()),
            CustomAnimationList(position: 3, child: _logInGoogleWidget()),
            CustomAnimationList(position: 4, child: _notificationsWidget()),
            CustomAnimationList(position: 5, child: _themeWidget()),
            CustomAnimationList(
                position: 6,
                child: ValueListenableBuilder(
                  valueListenable: _pinCodeNotifier,
                  builder: (BuildContext context, bool _pinCodeState, _) =>
                      ContainerCustom(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                          child: Icon(
                            Icons.lock_outline,
                            color: StyleColorCustom().setStyleByEnum(
                                context, StyleColorEnum.colorIcon),
                          ),
                        ),
                        Expanded(
                          child: TextWidget(
                              padding: 0,
                              text: textString_35,
                              style: StyleTextCustom().setStyleByEnum(
                                  context, StyleTextEnum.bodyCard)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CupertinoSwitch(
                            activeColor: CustomColors.pink,
                            trackColor: StyleColorCustom().setStyleByEnum(
                                context,
                                StyleColorEnum.cupertinoSwitchTrackColor),
                            thumbColor: StyleColorCustom().setStyleByEnum(
                                context,
                                StyleColorEnum.cupertinoSwitchThumbColor),
                            value: _pinCodeState,
                            onChanged: (bool value) {
                              _pinCodeNotifier.value = value;
                              if (value) {
                                context.read<SettingScreenBloc>().add(
                                      UserUpdatePinCodeEvent(),
                                    );
                              } else {
                                context.read<SettingScreenBloc>().add(
                                      UserRemovePinCodeEvent(),
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            CustomAnimationList(position: 7, child: _touchWidget()),
            CustomAnimationList(position: 8, child: _currencyWidget()),
            CustomAnimationList(
                position: 9,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BlocProvider(
                                create: (context) => ExportBloc(),
                                child: ExportScreen(),
                              ))),
                  child: ContainerCustom(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                          child: Icon(
                            Icons.arrow_circle_down_outlined,
                            color: StyleColorCustom().setStyleByEnum(
                                context, StyleColorEnum.colorIcon),
                          ),
                        ),
                        Expanded(
                          child: TextWidget(
                              padding: 0,
                              text: textString_39,
                              style: StyleTextCustom().setStyleByEnum(
                                  context, StyleTextEnum.bodyCard)),
                        ),
                      ],
                    ),
                  ),
                )),
            CustomAnimationList(position: 10, child: _clearWidget()),
            CustomAnimationList(position: 11, child: _removeUser()),
            CustomAnimationList(position: 12, child: _logout()),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _phoneEditWidget() => ValueListenableBuilder(
        valueListenable: _phoneEditState,
        builder: (BuildContext context, _EditState _state, _) => Form(
          key: _phoneFormKey,
          child: ContainerCustom(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: Icon(
                    Icons.phone_outlined,
                    color: StyleColorCustom()
                        .setStyleByEnum(context, StyleColorEnum.colorIcon),
                  ),
                ),
                Expanded(
                  child: TextFieldWidget(
                    readOnly: _state != _EditState.enabled,
                    filteringTextInputFormatter: <TextInputFormatter>[
                      _phoneMaskFormatter
                    ],
                    autofocus: _state != _EditState.enabled,
                    textInputType: TextInputType.phone,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    labelText: textString_9,
                    fillColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.secondaryBackground),
                    validation: (String? value) {
                      String pattern = r'(^(?:\+7)?[0-9-]{14}$)';
                      RegExp regExp = new RegExp(pattern);
                      if (value?.length == 0) {
                        return 'Пожалуйста введите номер телефона';
                      } else if (!regExp.hasMatch(value!)) {
                        return 'Пожалуйста введите номер телефона правильно';
                      }
                      return null;
                    },
                    controller: _phoneController,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    paddingTop: EdgeInsets.zero,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Icon(
                      _state == _EditState.enabled
                          ? Icons.save
                          : Icons.edit_outlined,
                      color: StyleColorCustom()
                          .setStyleByEnum(context, StyleColorEnum.colorIcon),
                    ),
                    onTap: () {
                      _phoneEditState.value =
                          _EditState.values.where((e) => e != _state).first;
                      if (_phoneEditState.value == _EditState.disabled) {
                        if (_phoneFormKey.currentState!.validate()) {
                          context.read<SettingScreenBloc>().add(
                                UserUpdateInfoEvent(
                                  data: <String, dynamic>{
                                    "username": _phoneController.text
                                        .split("-")
                                        .join(""),
                                  },
                                ),
                              );
                        } else {
                          _emailEditState.value = _EditState.enabled;
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _emailEditWidget() => ValueListenableBuilder(
        valueListenable: _emailEditState,
        builder: (BuildContext context, _EditState _state, _) => Form(
          key: _emailFormKey,
          child: ContainerCustom(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: Icon(
                    Icons.phone_outlined,
                    color: StyleColorCustom()
                        .setStyleByEnum(context, StyleColorEnum.colorIcon),
                  ),
                ),
                Expanded(
                  child: TextFieldWidget(
                    readOnly: _state != _EditState.enabled,
                    autofocus: _state != _EditState.enabled,
                    textInputType: TextInputType.emailAddress,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard),
                    labelText: "E-mail",
                    fillColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.secondaryBackground),
                    filteringTextInputFormatter: <TextInputFormatter>[
                      FilteringTextInputFormatter.singleLineFormatter
                    ],
                    validation: (String? email) {
                      if (RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email ?? "")) {
                        return null;
                      }
                      return 'Пожалуйста укажите E-mail правильно';
                    },
                    controller: _emailController,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    paddingTop: EdgeInsets.zero,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Icon(
                      _state == _EditState.enabled
                          ? Icons.save
                          : Icons.edit_outlined,
                      color: StyleColorCustom()
                          .setStyleByEnum(context, StyleColorEnum.colorIcon),
                    ),
                    onTap: () {
                      if (_userProvider.user!.type != UserType.SYSTEM) return;
                      _emailEditState.value =
                          _EditState.values.where((e) => e != _state).first;
                      if (_emailEditState.value == _EditState.disabled) {
                        if (_emailFormKey.currentState!.validate()) {
                          context.read<SettingScreenBloc>().add(
                                UserUpdateInfoEvent(
                                  data: <String, dynamic>{
                                    "email": _emailController.text,
                                  },
                                ),
                              );
                        } else {
                          _emailEditState.value = _EditState.enabled;
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _touchWidget() => ValueListenableBuilder(
        valueListenable: _touchIDNotifier,
        builder: (BuildContext context, bool _touchIDState, _) =>
            ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Icon(
                  Icons.fingerprint,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: textString_36,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CupertinoSwitch(
                  activeColor: CustomColors.pink,
                  trackColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.cupertinoSwitchTrackColor),
                  thumbColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.cupertinoSwitchThumbColor),
                  value: _touchIDState,
                  onChanged: (bool value) {
                    _touchIDNotifier.value = value;
                    context.read<SettingScreenBloc>().add(
                          UserUpdateInfoEvent(
                            data: <String, dynamic>{
                              // "username": _userProvider.user.username,
                              //"password": password.randomPassword(),
                              // "walletType": _userProvider.user.walletType,
                              // "email": _userProvider.user.email,
                              // "type": _userProvider.user.type,
                              // "roleName": _userProvider.user.role.name,
                              // "notificationsEnable": true,
                              // "plannedIncome": 0,
                              // "faceId": false,
                              "touchId": value,
                            },
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _logInGoogleWidget() => ValueListenableBuilder(
        valueListenable: _googleNotifier,
        builder: (BuildContext context, bool _stateGoogle, _) =>
            ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Icon(
                  Icons.email_outlined,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: textString_91,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CupertinoSwitch(
                  activeColor: _userProvider.user?.type.name != "GOOGLE"
                      ? CustomColors.pink
                      : CustomColors.pink.withOpacity(0.5),
                  trackColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.cupertinoSwitchTrackColor),
                  thumbColor: _userProvider.user?.type.name != "GOOGLE"
                      ? StyleColorCustom().setStyleByEnum(
                          context,
                          StyleColorEnum.cupertinoSwitchThumbColor,
                        )
                      : Colors.white.withOpacity(0.5),
                  value: _userProvider.user?.type.name == "GOOGLE"
                      ? true
                      : _stateGoogle,
                  onChanged: (bool value) async {
                    final _bloc = context.read<SettingScreenBloc>();
                    GoogleSignInAccount? _userInfo;
                    if (_userProvider.user?.type.name != "GOOGLE") {
                      if (value) {
                        _bloc.add(UpdateLoadingEvent(loading: true));
                        _userInfo = await signInWithGoogle();
                        _bloc.add(UpdateLoadingEvent(loading: false));
                      }
                      _bloc.add(UpdateGoogleAuthEvent(googleId: _userInfo?.id));
                    }
                    _googleNotifier.value = value;
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _notificationsWidget() => ValueListenableBuilder(
        valueListenable: _noificationsNotifier,
        builder: (BuildContext context, bool _state, _) => ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Icon(
                  Icons.notifications_outlined,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: textString_33,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CupertinoSwitch(
                  activeColor: CustomColors.pink,
                  trackColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.cupertinoSwitchTrackColor),
                  thumbColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.cupertinoSwitchThumbColor),
                  value: _state,
                  onChanged: (bool value) {
                    _noificationsNotifier.value = value;
                    context.read<SettingScreenBloc>().add(
                          UserUpdateInfoEvent(
                            data: <String, dynamic>{
                              "notificationsEnable": value,
                            },
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _currencyWidget() => ValueListenableBuilder(
        valueListenable: _currencyNotifier,
        builder: (BuildContext context, Currency? _item, _) => GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider(
                        create: (context) => CurrenciesScreenBloc(),
                        child: CurrenciesScreen(
                          list: _currencies,
                          selected: _currencyNotifier.value!,
                        ),
                      ))),
          child: ContainerCustom(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: Icon(
                    Icons.attach_money_outlined,
                    color: StyleColorCustom()
                        .setStyleByEnum(context, StyleColorEnum.colorIcon),
                  ),
                ),
                Expanded(
                  child: TextWidget(
                      padding: 0,
                      text: textString_37,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                  child: TextWidget(
                      padding: 0,
                      text: _item == null ? "" : _item.walletDisplayName,
                      style: StyleTextCustom()
                          .setStyleByEnum(context, StyleTextEnum.bodyCard)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _clearWidget() => GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                      create: (context) => DeleteDataBloc(),
                      child: DeleteDataScreen(),
                    ))),
        child: ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Icon(
                  Icons.highlight_remove_outlined,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: textString_40,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
            ],
          ),
        ),
      );

  Widget _removeUser() => GestureDetector(
        onTap: () => context.read<SettingScreenBloc>().add(
              RemoveUserEvent(),
            ),
        child: ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                child: Icon(
                  Icons.delete_forever,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: textString_41,
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
            ],
          ),
        ),
        behavior: HitTestBehavior.translucent,
      );

  Widget _logout() => GestureDetector(
        onTap: () => context.read<SettingScreenBloc>().add(
              LogoutUserEvent(),
            ),
        child: ContainerCustom(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1.0, right: 8.0, top: 0),
                child: Icon(
                  Icons.logout,
                  color: StyleColorCustom()
                      .setStyleByEnum(context, StyleColorEnum.colorIcon),
                ),
              ),
              Expanded(
                child: TextWidget(
                    padding: 0,
                    text: "Выйти",
                    style: StyleTextCustom()
                        .setStyleByEnum(context, StyleTextEnum.bodyCard)),
              ),
            ],
          ),
        ),
        behavior: HitTestBehavior.translucent,
      );

  Widget _themeWidget() => ContainerCustom(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 2.0),
              child: Icon(
                Icons.nightlight_outlined,
                color: StyleColorCustom()
                    .setStyleByEnum(context, StyleColorEnum.colorIcon),
              ),
            ),
            Expanded(
              child: TextWidget(
                  padding: 0,
                  text: textString_34,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.bodyCard)),
            ),
            ThemeSwitcher(
              builder: (context) {
                var brightness =
                    ThemeModelInheritedNotifier.of(context).theme.brightness;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CupertinoSwitch(
                    activeColor: CustomColors.pink,
                    trackColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.cupertinoSwitchTrackColor),
                    thumbColor: StyleColorCustom().setStyleByEnum(
                        context, StyleColorEnum.cupertinoSwitchThumbColor),
                    value: brightness != Brightness.light,
                    onChanged: (bool value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      var brightness = ThemeModelInheritedNotifier.of(context)
                          .theme
                          .brightness;
                      ThemeSwitcher.of(context).changeTheme(
                        theme: brightness == Brightness.light
                            ? CustomThemes.darkTheme(context)
                            : CustomThemes.lightTheme(context),
                        isReversed:
                            brightness == Brightness.dark ? true : false,
                      );

                      prefs.setBool("isDark",
                          brightness == Brightness.light ? true : false);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      Logger().i("Login google");
      // Trigger the authentication flow
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      Logger().i(googleUser.toString());

      // Create a new credential
      final OAuthCredential? credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      if (credential != null) {
        return googleUser;
      }
      return null;
    } on PlatformException catch (e) {
      late String errorMessage;
      if (e.code == GoogleSignIn.kNetworkError) {
        errorMessage =
            "A network error (such as timeout, interrupted connection or unreachable host) has occurred.";
      } else {
        errorMessage = "Unable to sign in, please try again!";
      }
      await CustomDialog.dialogError(
        context: context,
        title: "Error registering with Google",
        message: errorMessage,
      );
    } catch (e) {
      await CustomDialog.dialogError(
        context: context,
        title: "Error registering with Google",
        message: "Unable to sign in, please try again!",
      );
    }
  }
}
