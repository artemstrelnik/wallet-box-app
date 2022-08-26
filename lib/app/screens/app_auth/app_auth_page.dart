import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wallet_box/app/core/constants/constants.dart';
import 'package:wallet_box/app/core/generals_widgets/dialog.dart';
import 'package:wallet_box/app/core/generals_widgets/down_to_up_animation.dart';
import 'package:wallet_box/app/core/styles/style_color_custom.dart';
import 'package:wallet_box/app/core/styles/style_text_custom.dart';
import 'package:wallet_box/app/core/themes/colors.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_bloc.dart';
import 'package:wallet_box/app/screens/password_restore/password_restore_page.dart';

import '../../core/generals_widgets/up_to_down_animation.dart';
import 'app_auth_bloc.dart';
import 'app_auth_events.dart';
import 'app_auth_states.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AuthPageProvider(),
      builder: (context, _) => BlocListener<AppAuthBloc, AppAuthState>(
        listener: (context, state) {
          if (state is ShowDialogState) {
            context.read<AuthPageProvider>().updateLoading(false);
            showCupertinoDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  content: const Text(
                    "Пользователь с таким телефоном или email уже существует или занят",
                  ),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      child: const Text('Ок'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
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

            context.read<AuthPageProvider>().updateLoading(false);

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
      ),
    );
  }

  Widget _scaffold(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (context.watch<AuthPageProvider>().loading) {
            return false;
          }
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            minimum: const EdgeInsets.only(left: 16, right: 16),
            child: Consumer<AuthPageProvider>(
              builder: (context, provider, _) => Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UpToDown(
                        delay: Platform.isIOS ? 1 : 1.2,
                        child: Padding(
                          padding: const EdgeInsets.all(80.0),
                          child: Center(
                            child: ConstContext.lightMode(context)
                                ? Image.asset(logoLight)
                                : Image.asset(logoDark),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Consumer<AuthPageProvider>(
                        builder: (context, provider, _) => provider.loading
                            ? SizedBox.shrink()
                            : Column(
                                children: [
                                  (Platform.isIOS)
                                      ? DownToUp(
                                          delay: 1,
                                          child: _customButton(
                                            "Войти через Apple",
                                            icon: SvgPicture.asset(
                                                AssetsPath.apple),
                                            textStyle: StyleTextCustom()
                                                .setStyleByEnum(
                                                    context,
                                                    StyleTextEnum
                                                        .appleButtonStyleReverse),
                                            backgroundColor: StyleColorCustom()
                                                .setStyleByEnum(
                                                    context,
                                                    StyleColorEnum
                                                        .appleButtonColors),
                                            onTap: () async {
                                              context
                                                  .read<AuthPageProvider>()
                                                  .updateLoading(true);
                                              final UserCredential _userInfo =
                                                  await signInWithApple();
                                              context.read<AppAuthBloc>().add(
                                                    CheckUserEvent(
                                                      appleUser: _userInfo,
                                                      type: UserType.APPLE,
                                                    ),
                                                  );
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                                  DownToUp(
                                    delay: 1.5,
                                    child: _customButton(
                                      "Войти через Google",
                                      icon: SvgPicture.asset(AssetsPath.google),
                                      textStyle: StyleTextCustom()
                                          .setStyleByEnum(context,
                                              StyleTextEnum.appleButtonStyle)
                                          .copyWith(
                                              color: CustomColors
                                                  .lightPrimaryText),
                                      backgroundColor:
                                          CustomColors.googleButton,
                                      onTap: () async {
                                        final provider =
                                            context.read<AuthPageProvider>();
                                        provider.updateLoading(true);
                                        context
                                            .read<AppAuthBloc>()
                                            .add(PageOpenedEvent());
                                        final GoogleSignInAccount? _userInfo =
                                            await signInWithGoogle(provider);

                                        if (_userInfo != null) {
                                          context.read<AppAuthBloc>().add(
                                                CheckUserEvent(
                                                  googleUser: _userInfo,
                                                  type: UserType.GOOGLE,
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                  ),
                                  DownToUp(
                                    delay: 2,
                                    child: _customButton(
                                      "Войти по логину",
                                      textStyle: StyleTextCustom()
                                          .setStyleByEnum(context,
                                              StyleTextEnum.appleButtonStyle),
                                      backgroundColor: StyleColorCustom()
                                          .setStyleByEnum(context,
                                              StyleColorEnum.appleButtonColors),
                                      border: true,
                                      onTap: () =>
                                          Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) =>
                                                HomeScreenBloc(),
                                            child: const HomeScreen(),
                                          ),
                                        ),
                                        (route) => false,
                                      ),
                                      //     Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (_) => BlocProvider(
                                      //       create: (context) => AuthBloc(),
                                      //       child: const AuthPhone(),
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                  ),
                                  DownToUp(
                                    delay: 2.5,
                                    child: _customButton(
                                      "Забыли пароль?",
                                      textStyle: StyleTextCustom()
                                          .setStyleByEnum(context,
                                              StyleTextEnum.appleButtonStyle)
                                          .copyWith(
                                              color: CustomColors.dotPinCode),
                                      backgroundColor: Colors.transparent,
                                      top: 24,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) =>
                                                PasswordRestoreBloc(),
                                            child: PasswordRestorePage(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50)
                                ],
                              ),
                      ),
                    ],
                  ),
                  provider.loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
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
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = await OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<GoogleSignInAccount?> signInWithGoogle(
      AuthPageProvider provider) async {
    try {
      // Trigger the authentication flow
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final OAuthCredential? credential = await GoogleAuthProvider.credential(
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
      ).then((value) => provider.updateLoading(false));
    } catch (e) {
      await CustomDialog.dialogError(
        context: context,
        title: "Error registering with Google",
        message: "Unable to sign in, please try again!",
      ).then((value) => provider.updateLoading(false));
    }
    return null;
  }
}

class AuthPageProvider extends ChangeNotifier {
  bool loading = false;

  updateLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
