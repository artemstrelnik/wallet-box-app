import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class CurrenciesScreenState {
  const CurrenciesScreenState();
}

class ListLoadingState extends CurrenciesScreenState {
  const ListLoadingState();
}

class ListLoadedState extends CurrenciesScreenState {
  const ListLoadedState();
}

class ListErrorState extends CurrenciesScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends CurrenciesScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends CurrenciesScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateUserInfo extends CurrenciesScreenState {
  const UpdateUserInfo({required this.user});

  final User user;
}
