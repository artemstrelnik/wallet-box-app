import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_phone/auth_phone.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_phone/auth_bloc.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_page.dart';

import 'app_auth_bloc.dart';
import 'app_auth_events.dart';
import 'app_auth_states.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppAuthPage extends StatefulWidget {
  @override
  _AppAuthPageState createState() => _AppAuthPageState();
}

class _AppAuthPageState extends State<AppAuthPage> with WidgetsBindingObserver {
  late UserNotifierProvider _userProvider;
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    context.read<AppAuthBloc>().add(
          PageOpenedEvent(),
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
        context.read<AppAuthBloc>().add(
              UpdateUserTokenEvent(token: token!),
            );
        await prefs.setString(firebaseTokenPrefKey, token);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    return BlocListener<AppAuthBloc, AppAuthState>(
      listener: (context, state) {
        if (state is ShowDialogState) {
          showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              content: const Text(
                  "Пользователь с таким телефоном или email уже существует или занят"),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: const Text('Ок'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
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
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 16, right: 16),
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
              Expanded(child: Container()),
              (Platform.isIOS)
                  ? _customButton(
                      "Войти через Apple",
                      icon: SvgPicture.asset(AssetsPath.apple),
                      textStyle: StyleTextCustom().setStyleByEnum(
                          context, StyleTextEnum.appleButtonStyleReverse),
                      backgroundColor: StyleColorCustom().setStyleByEnum(
                          context, StyleColorEnum.appleButtonColors),
                      onTap: () async {
                        final UserCredential _userInfo =
                            await signInWithApple();

                        context.read<AppAuthBloc>().add(
                              CheckUserEvent(
                                  info: _userInfo, type: UserType.APPLE),
                            );
                      },
                    )
                  : SizedBox(),
              _customButton(
                "Войти через Google",
                icon: SvgPicture.asset(AssetsPath.google),
                textStyle: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.appleButtonStyle)
                    .copyWith(color: CustomColors.lightPrimaryText),
                backgroundColor: CustomColors.googleButton,
                onTap: () async {
                  final UserCredential? _userInfo = await signInWithGoogle();
                  if (_userInfo != null) {
                    context.read<AppAuthBloc>().add(
                          CheckUserEvent(
                              info: _userInfo, type: UserType.GOOGLE),
                        );
                  }
                },
              ),
              _customButton(
                "Войти по логину",
                textStyle: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.appleButtonStyle),
                backgroundColor: StyleColorCustom()
                    .setStyleByEnum(context, StyleColorEnum.appleButtonColors),
                border: true,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider(
                              create: (context) => AuthBloc(),
                              child: const AuthPhone(),
                            ))),
              ),
              _customButton(
                "Забыли пароль?",
                textStyle: StyleTextCustom()
                    .setStyleByEnum(context, StyleTextEnum.appleButtonStyle)
                    .copyWith(color: CustomColors.dotPinCode),
                backgroundColor: Colors.transparent,
                top: 24,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider(
                              create: (context) => PasswordRestoreBloc(),
                              child: PasswordRestorePage(),
                            ))),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      );

  Widget _customButton(
    String text, {
    Widget? icon,
    TextStyle? textStyle,
    bool border = false,
    Color? backgroundColor,
    double top = 16,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap ?? () => {},
        child: Container(
          margin: EdgeInsets.only(top: top),
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: border ? Colors.transparent : backgroundColor,
            border: Border.all(color: backgroundColor!),
          ),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon ?? Container(),
                Padding(
                  padding: EdgeInsets.only(left: (icon != null ? 9.0 : 0.0)),
                  child: Text(
                    text,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // Future<void> _handleSignIn() async {
  //   try {
  //     await _googleSignIn.signIn();
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  logout() {}

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn().catchError((error) {
      print('AN ERROR OCCURED');
    });
    print(googleUser);
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    print(googleAuth);
    // Create a new credential
    final OAuthCredential? credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    print(credential);
    if (credential != null) {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return null;
    // Once signed in, return the UserCredential
  }
}
