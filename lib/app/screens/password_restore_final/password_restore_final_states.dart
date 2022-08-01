import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class PasswordRestoreFinalState {
  const PasswordRestoreFinalState();
}

class ListLoadingState extends PasswordRestoreFinalState {
  const ListLoadingState();
}

class ListLoadedState extends PasswordRestoreFinalState {
  const ListLoadedState();
}

class ListErrorState extends PasswordRestoreFinalState {
  const ListErrorState();
}

class ListLoadingOpacityState extends PasswordRestoreFinalState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends PasswordRestoreFinalState {
  const ListLoadingOpacityHideState();
}

class HomeEntryState extends PasswordRestoreFinalState {
  const HomeEntryState({
    required this.user,
  });

  final User user;
}
