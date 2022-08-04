
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/widgets/text_dialog.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_email/auth_email_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_email/auth_email_states.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_password/auth_password_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_password/auth_password_code.dart';

import 'auth_email_events.dart';

class AuthPhoneEmail extends StatefulWidget {
  const AuthPhoneEmail({Key? key}) : super(key: key);
  @override
  _AuthPhoneEmailState createState() => _AuthPhoneEmailState();
}

class _AuthPhoneEmailState extends State<AuthPhoneEmail> with ScreenLoader {
  late UserNotifierProvider _userProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController(text: "");

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
    return BlocListener<AuthEmailBloc, AuthEmailState>(
      listener: (context, state) {
        if (state is ShowMessageState) {
          showMyDialog(context, title: state.title, message: state.message);
        }
        if (state is GoToPasswordPage) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AuthPasswordBloc(
                  phone: state.phone,
                  email: state.email,
                ),
                child: AuthPasswordPage(),
              ),
            ),
          );
        }
        // if (state is HomeEntryState) {
        //   _userProvider.setUser = state.user;
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => BlocProvider(
        //         create: (context) => HomeScreenBloc(),
        //         child: HomeScreen(),
        //       ),
        //     ),
        //   );
        // }

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

  _scaffold(BuildContext context) {
    return loadableWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 20, right: 20),
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
                          : Image.asset(logoDark)),
                ),
                TextFieldWidget(
                  controller: _controller,
                  filteringTextInputFormatter: <TextInputFormatter>[
                    FilteringTextInputFormatter.singleLineFormatter
                  ],
                  autofocus: true,
                  textInputType: TextInputType.emailAddress,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.neutralText),
                  labelText: textString_12,
                  fillColor: StyleColorCustom().setStyleByEnum(
                      context, StyleColorEnum.secondaryBackground),
                  validation: (String? email) {
                    if (RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-\/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(email ?? "")) {
                      return null;
                    }
                    return 'Пожалуйста укажите E-mail правильно';
                  },
                ),
                TextWidget(
                  text: textString_7,
                  style: StyleTextCustom()
                      .setStyleByEnum(context, StyleTextEnum.neutralText),
                  align: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonCancel(
                        text: textString_11,
                        onPressed: () => Navigator.pop(context)),
                    ButtonBlue(
                      text: textString_10,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthEmailBloc>().add(
                                StartUserRegistration(email: _controller.text),
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
      ),
    );
  }
}
