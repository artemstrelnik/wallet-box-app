import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String SplashPath = '/splash';
const String LoginPath = '/login';
const String CreateAccountPath = '/createAccount';
const String ListItemsPath = '/listItems';
const String DetailsPath = '/details';
const String CartPath = '/cart';
const String CheckoutPath = '/checkout';
const String SettingsPath = '/settings';

enum Pages {
  Splash,
  Login,
  CreateAccount,
  List,
  Details,
  Cart,
  Checkout,
  Settings
}

enum PageState { none, addPage, addAll, addWidget, pop, replace, replaceAll }

class PageAction {
  PageAction({
    this.state = PageState.none,
    this.page,
    this.pages,
    this.widget,
  });

  PageState state;
  PageConfiguration? page;
  List<PageConfiguration>? pages;
  Widget? widget;
}

class PageConfiguration {
  PageConfiguration({
    required this.key,
    required this.path,
    required this.uiPage,
    this.currentPageAction,
  });

  final String key;
  final String path;
  final Pages uiPage;
  PageAction? currentPageAction;
}

PageConfiguration SplashPageConfig = PageConfiguration(
    key: 'Splash',
    path: SplashPath,
    uiPage: Pages.Splash,
    currentPageAction: null);
PageConfiguration LoginPageConfig = PageConfiguration(
    key: 'Login',
    path: LoginPath,
    uiPage: Pages.Login,
    currentPageAction: null);
PageConfiguration CreateAccountPageConfig = PageConfiguration(
    key: 'CreateAccount',
    path: CreateAccountPath,
    uiPage: Pages.CreateAccount,
    currentPageAction: null);
PageConfiguration ListItemsPageConfig = PageConfiguration(
    key: 'ListItems', path: ListItemsPath, uiPage: Pages.List);
PageConfiguration DetailsPageConfig = PageConfiguration(
    key: 'Details',
    path: DetailsPath,
    uiPage: Pages.Details,
    currentPageAction: null);
PageConfiguration CartPageConfig = PageConfiguration(
    key: 'Cart', path: CartPath, uiPage: Pages.Cart, currentPageAction: null);
PageConfiguration CheckoutPageConfig = PageConfiguration(
    key: 'Checkout',
    path: CheckoutPath,
    uiPage: Pages.Checkout,
    currentPageAction: null);
PageConfiguration SettingsPageConfig = PageConfiguration(
    key: 'Settings',
    path: SettingsPath,
    uiPage: Pages.Settings,
    currentPageAction: null);

class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;
  final cartItems = [];
  late String emailAddress;
  late String password;
  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;
  set currentAction(PageAction action) {
    _currentAction = action;
    notifyListeners();
  }

  AppState() {
    getLoggedInState();
  }

  void resetCurrentAction() {
    _currentAction = PageAction();
  }

  void addToCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  void setSplashFinished() {
    _splashFinished = true;
    if (_loggedIn) {
      _currentAction =
          PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    } else {
      _currentAction =
          PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    }
    notifyListeners();
  }

  void login() {
    _loggedIn = true;
    saveLoginState(loggedIn);
    _currentAction =
        PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    saveLoginState(loggedIn);
    _currentAction =
        PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    notifyListeners();
  }

  void saveLoginState(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(LoggedInKey, loggedIn);
  }

  void getLoggedInState() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = true;
    //prefs.getBool(LoggedInKey);
    if (_loggedIn == null) {
      _loggedIn = false;
    }
  }
}
