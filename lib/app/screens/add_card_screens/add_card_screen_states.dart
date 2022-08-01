import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class AddCardScreenState {
  const AddCardScreenState();
}

class ListLoadingState extends AddCardScreenState {
  const ListLoadingState();
}

class ListLoadedState extends AddCardScreenState {
  const ListLoadedState();
}

class ListErrorState extends AddCardScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AddCardScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AddCardScreenState {
  const ListLoadingOpacityHideState();
}

class StorageNotEmptyState extends AddCardScreenState {
  const StorageNotEmptyState({required this.user});

  final User user;
}

class StorageEmptyState extends AddCardScreenState {
  const StorageEmptyState({this.userExist = false});

  final bool userExist;
}

class LocalAuthState extends AddCardScreenState {
  const LocalAuthState();
}

class TouchAuthState extends AddCardScreenState {
  const TouchAuthState();
}

class UserAuthorizedState extends AddCardScreenState {
  const UserAuthorizedState({required this.user});

  final User user;
}

class UpdateUserProvider extends AddCardScreenState {
  const UpdateUserProvider({required this.user});

  final User user;
}

class AppAuthState extends AddCardScreenState {
  const AppAuthState();
}

class GoToAuthState extends AddCardScreenState {
  const GoToAuthState();
}

class UpdateListLoyalty extends AddCardScreenState {
  const UpdateListLoyalty({this.list, required this.token});

  final List<Loyalty>? list;
  final String token;
}

class CreateCardState extends AddCardScreenState {
  const CreateCardState({
    this.isCreate,
    required this.isCustom,
    this.isHands = false,
  });

  final bool? isCreate;
  final bool isCustom;
  final bool isHands;
}
