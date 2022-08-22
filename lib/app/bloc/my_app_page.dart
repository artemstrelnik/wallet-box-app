import 'dart:async';
import 'dart:math';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';

//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_links/app_links.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/core/themes/themes.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:wallet_box/app/screens/add_invoice_screens/add_invoice_bloc.dart';
import 'package:wallet_box/app/screens/app_auth/app_auth_bloc.dart';
import 'package:wallet_box/app/screens/app_auth/app_auth_page.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_code_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_code/auth_phone_code.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_phone/auth_bloc.dart';
import 'package:wallet_box/app/screens/auth_screens/bloc_phone/auth_phone.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen.dart';
import 'package:wallet_box/app/screens/home_screen/home_screen_bloc.dart';
import 'package:wallet_box/app/screens/pin_code/pin_code_bloc.dart';
import 'package:wallet_box/app/screens/pin_code/pin_code_page.dart';
import 'package:wallet_box/app/screens/settings_screens/subscription_screen/subscription_screen.dart';
import 'package:wallet_box/app/screens/settings_screens/subscription_screen/subscription_screen_bloc.dart';
import 'package:wallet_box/app/screens/splash_screens/splash_screen.dart';
import 'package:wallet_box/app/screens/synchronization/synchronization_page.dart';
import 'package:workmanager/workmanager.dart';

import 'my_app_bloc.dart';
import 'my_app_events.dart';
import 'my_app_states.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

enum _UserState {
  pin_code,
  authorized,
  not_authorized,
  splash,
  new_authorized,
  password
}

// Used for Background Updates using Workmanager Plugin
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'widget_app',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

// Called when Doing Background Work initiated from Widget
void backgroundCallback(Uri? data) async {
  print(data);

  if (data!.host == 'titleclicked') {
    final greetings = [
      'Hello',
      'Hallo',
      'Bonjour',
      'Hola',
      'Ciao',
      '哈洛',
      '안녕하세요',
      'xin chào'
    ];
    final selectedGreeting = greetings[Random().nextInt(greetings.length)];

    await HomeWidget.saveWidgetData<String>('title', selectedGreeting);
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;

  late UserNotifierProvider _userProvider;

  // late RolePermissionProvider _permissionsProvider;
  late ShowAlertProvider _showAlertProvider;

  final ValueNotifier<_UserState> _initApp =
      ValueNotifier<_UserState>(_UserState.splash);

  @override
  void initState() {
    super.initState();
    _showAlertProvider = Provider.of<ShowAlertProvider>(
      context,
      listen: false,
    );
    Session().setAlertProvider(alert: _showAlertProvider);

    auth.isDeviceSupported().then(
          (bool isSupported) => _supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        );
    context.read<MyAppBloc>().add(PageOpenedEvent());

    WidgetsBinding.instance.addObserver(this);

    initDeepLinks();

    HomeWidget.setAppGroupId('group.walletbox.app');
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      showDialog(
        context: context,
        builder: (buildContext) => AlertDialog(
          title: Text('App started from HomeScreenWidget'),
          content: Text('Here is the URI: $uri'),
        ),
      );
    }
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    // if (appLink != null) {
    //   print('getInitialAppLink: $appLink');
    //   openAppLink(appLink);
    // }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      final String _url = uri.toString();
      if (_url.contains("/api/v1/tochka/auth-hook?code=") ||
          _url.contains("/addOperation")) {
        openAppLink(uri);
      }
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.query);
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'чтобы войти в приложение',
      );
      if (authenticated) {
        context.read<MyAppBloc>().add(
              UserAuthenticatedEvent(),
            );
      }
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return;
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
  }

  Future<ThemeData> _themeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? _isDark = (prefs.getBool('isDark'));
    final initTheme = (_isDark != null
            ? _isDark
            : WidgetsBinding.instance.window.platformBrightness ==
                Brightness.dark)
        ? CustomThemes.darkTheme(context)
        : CustomThemes.lightTheme(context);

    if (_isDark == null) {
      prefs.setBool("isDark",
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    }

    return Future.value(initTheme);
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserNotifierProvider>(
      context,
      listen: false,
    );
    // _permissionsProvider = Provider.of<RolePermissionProvider>(
    //   context,
    //   listen: false,
    // );
    _showAlertProvider.addListener(() {
      if (_showAlertProvider.isVisible) {
        showCupertinoDialog<void>(
          context: _navigatorKey.currentContext!,
          builder: (BuildContext context) => CupertinoAlertDialog(
            content:
                Text("Этот функционал не доступен пользователям подписки Lite"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () {
                  _showAlertProvider.setVisible = false;
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Приобрести'),
                onPressed: () {
                  _showAlertProvider.setVisible = false;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => SubscriptionScreenBloc(),
                        child: SubscriptionScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
      if (_showAlertProvider.isVisible) {
        showCupertinoDialog<void>(
          context: _navigatorKey.currentContext!,
          builder: (BuildContext context) => CupertinoAlertDialog(
            content:
                Text("Этот функционал не доступен пользователям подписки Lite"),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () {
                  _showAlertProvider.setVisible = false;
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Приобрести'),
                onPressed: () {
                  _showAlertProvider.setVisible = false;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => SubscriptionScreenBloc(),
                        child: SubscriptionScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
      if (_showAlertProvider.error != null) {
        showCupertinoDialog<void>(
          context: _navigatorKey.currentContext!,
          builder: (BuildContext context) => CupertinoAlertDialog(
            content: Text(_showAlertProvider.error!),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Понятно'),
                onPressed: () {
                  Navigator.pop(context);
                  _showAlertProvider.setError = null;
                },
              ),
            ],
          ),
        );
      }
    });
    return BlocListener<MyAppBloc, MyAppState>(
      listener: (context, state) {
        if (state is UserAuthorizedState) {
          _userProvider.setUser = state.user;
          _initApp.value = _UserState.authorized;
        }
        if (state is LocalAuthState) {
          _initApp.value = _UserState.pin_code;
        }
        if (state is TouchAuthState) {
          _authenticate();
        }
        if (state is StorageEmptyState) {
          _initApp.value =
              state.userExist ? _UserState.password : _UserState.new_authorized;
        }
        if (state is UpdateUserProvider) {
          _userProvider.setUser = state.user;
        }
        // if (state is UpdatePermissionsProvider) {
        //   _permissionsProvider.setPermissions = state.permissions;
        // }
        if (state is AppAuthState) {
          _initApp.value = _UserState.new_authorized;
        }
        if (state is GoToAuthState) {
          _initApp.value = _UserState.not_authorized;
        }
        if (state is OpenOperationState) {
          Navigator.pushAndRemoveUntil(
            _navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => HomeScreenBloc(),
                child: HomeScreen(type: state.type),
              ),
            ),
            (route) => false,
          );
        }
      },
      child: FutureBuilder<ThemeData>(
        future: _themeColor(),
        builder: (
          BuildContext context,
          AsyncSnapshot<ThemeData> snapshot,
        ) =>
            (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData)
                ? _scaffold(context, snapshot.data!)
                : Container(),
      ),
    );
  }

  Widget _scaffold(BuildContext context, ThemeData initTheme) =>
      GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: WillPopScope(
          onWillPop: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            return true;
          },
          child: ThemeProvider(
            initTheme: initTheme,
            builder: (_, myTheme) => DevicePreview(
              enabled: false,
              builder: (context) => MaterialApp(
                navigatorKey: _navigatorKey,
                useInheritedMediaQuery: true,
                locale: DevicePreview.locale(context),
                builder: DevicePreview.appBuilder,
                onGenerateRoute: (RouteSettings settings) {
                  //Widget routeWidget = MikhailovskyApp();
                  final routeName = settings.name;
                  if (routeName != null) {
                    if (routeName.startsWith('code')) {
                      final String? _code = routeName.substring(
                        routeName.indexOf('=') + 1,
                      );
                      if (_code != null && _code.isNotEmpty) {
                        return MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => AddInvoiceBloc(),
                            child: SingleBankPage(
                              bank: BankTypes.tochka,
                              code: _code,
                            ),
                          ),
                          //settings: settings,
                          //fullscreenDialog: true,
                        );
                      }
                    }
                    if (routeName.startsWith('type')) {
                      final String? _value = routeName.substring(
                        routeName.indexOf('=') + 1,
                      );
                      context.read<MyAppBloc>().add(
                            OpenOperationEvent(
                              type: OperationType.values
                                  .where((e) => e.name == _value)
                                  .first,
                            ),
                          );
                    }
                  }
                },
                initialRoute: "/",
                routes: {},
                theme: myTheme,
                debugShowCheckedModeBanner: false,
                home: ValueListenableBuilder(
                  valueListenable: _initApp,
                  builder: (BuildContext context, _UserState _state, _) {
                    switch (_state) {
                      case _UserState.password:
                        return BlocProvider(
                          create: (context) => AuthCodeBloc(
                            phone: _userProvider.user!.username ?? "",
                            isExists: true,
                            isPassword: true,
                          ),
                          child: const AuthPhoneCode(),
                        );
                      case _UserState.not_authorized:
                        return BlocProvider(
                          create: (context) => AuthBloc(),
                          child: const AuthPhone(),
                        );
                      case _UserState.authorized:
                        return BlocProvider(
                          create: (context) => HomeScreenBloc(),
                          child: const HomeScreen(),
                        );
                      case _UserState.pin_code:
                        return BlocProvider(
                          create: (context) => PinCodeBloc(),
                          child: const PinCodePage(isStart: true),
                        );
                      case _UserState.new_authorized:
                        return BlocProvider(
                          create: (context) => AppAuthBloc(),
                          child: AppAuthPage(),
                        );
                      default:
                        return const SplashScreen();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
