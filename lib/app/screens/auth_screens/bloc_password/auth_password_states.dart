import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class AuthPasswordState {
  const AuthPasswordState();
}

class ListLoadingState extends AuthPasswordState {
  const ListLoadingState();
}

class ListLoadedState extends AuthPasswordState {
  const ListLoadedState();
}

class ListErrorState extends AuthPasswordState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AuthPasswordState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AuthPasswordState {
  const ListLoadingOpacityHideState();
}

class CodeEntryState extends AuthPasswordState {
  const CodeEntryState({
    required this.phone,
    required this.isExists,
  });

  final String phone;
  final bool isExists;
}

class HomeEntryState extends AuthPasswordState {
  const HomeEntryState({
    required this.user,
  });

  final User user;
}

class EmailEntryState extends AuthPasswordState {
  const EmailEntryState({
    required this.phone,
  });

  final String phone;
}

class ChangeScreenType extends AuthPasswordState {
  const ChangeScreenType();
}

class ChangeLoadingState extends AuthPasswordState {
  const ChangeLoadingState();
}
