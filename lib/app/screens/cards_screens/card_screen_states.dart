import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class CardScreenState {
  const CardScreenState();
}

class ListLoadingState extends CardScreenState {
  const ListLoadingState();
}

class ListLoadedState extends CardScreenState {
  const ListLoadedState();
}

class ListErrorState extends CardScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends CardScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends CardScreenState {
  const ListLoadingOpacityHideState();
}

class StorageNotEmptyState extends CardScreenState {
  const StorageNotEmptyState({required this.user});

  final User user;
}

class StorageEmptyState extends CardScreenState {
  const StorageEmptyState({this.userExist = false});

  final bool userExist;
}

class LocalAuthState extends CardScreenState {
  const LocalAuthState();
}

class TouchAuthState extends CardScreenState {
  const TouchAuthState();
}

class UserAuthorizedState extends CardScreenState {
  const UserAuthorizedState({required this.user});

  final User user;
}

class UpdateUserProvider extends CardScreenState {
  const UpdateUserProvider({required this.user});

  final User user;
}

class AppAuthState extends CardScreenState {
  const AppAuthState();
}

class GoToAuthState extends CardScreenState {
  const GoToAuthState();
}

class UpdateMyLoyalty extends CardScreenState {
  const UpdateMyLoyalty({this.list, required this.token});

  final List<MyLoyaltyData>? list;
  final String token;
}
