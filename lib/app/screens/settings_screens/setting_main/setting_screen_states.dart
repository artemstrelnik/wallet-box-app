import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import 'package:wallet_box/app/data/net/models/my_subscription_variable.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class SettingScreenState {
  const SettingScreenState();
}

class ListLoadingState extends SettingScreenState {
  const ListLoadingState();
}

class ListLoadedState extends SettingScreenState {
  const ListLoadedState();
}

class ListErrorState extends SettingScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends SettingScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends SettingScreenState {
  const ListLoadingOpacityHideState();
}

class OpenSettingState extends SettingScreenState {
  const OpenSettingState({required this.user});

  final User user;
}

class StartPinCodeChangeState extends SettingScreenState {
  const StartPinCodeChangeState();
}

class StopPinCodeChangeState extends SettingScreenState {
  const StopPinCodeChangeState();
}

class UpdateCurrenciesList extends SettingScreenState {
  const UpdateCurrenciesList({required this.list});

  final List<Currency> list;
}

class ToAuthPage extends SettingScreenState {}

class GoToStartScreen extends SettingScreenState {}

class UpdateSubscriptionState extends SettingScreenState {
  const UpdateSubscriptionState({required this.sub});

  final MySubscription? sub;
}
