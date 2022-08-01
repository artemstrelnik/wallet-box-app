import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class MyAppState {
  const MyAppState();
}

class ListLoadingState extends MyAppState {
  const ListLoadingState();
}

class ListLoadedState extends MyAppState {
  const ListLoadedState();
}

class ListErrorState extends MyAppState {
  const ListErrorState();
}

class ListLoadingOpacityState extends MyAppState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends MyAppState {
  const ListLoadingOpacityHideState();
}

class StorageNotEmptyState extends MyAppState {
  const StorageNotEmptyState({required this.user});

  final User user;
}

class StorageEmptyState extends MyAppState {
  const StorageEmptyState({this.userExist = false});

  final bool userExist;
}

class LocalAuthState extends MyAppState {
  const LocalAuthState();
}

class TouchAuthState extends MyAppState {
  const TouchAuthState();
}

class UserAuthorizedState extends MyAppState {
  const UserAuthorizedState({required this.user});

  final User user;
}

class UpdateUserProvider extends MyAppState {
  const UpdateUserProvider({required this.user});

  final User user;
}

// class UpdatePermissionsProvider extends MyAppState {
//   const UpdatePermissionsProvider({required this.permissions});

//   final List<MyPermissions> permissions;
// }

class AppAuthState extends MyAppState {
  const AppAuthState();
}

class GoToAuthState extends MyAppState {
  const GoToAuthState();
}

class OpenOperationState extends MyAppState {
  const OpenOperationState({required this.type});

  final OperationType type;
}
