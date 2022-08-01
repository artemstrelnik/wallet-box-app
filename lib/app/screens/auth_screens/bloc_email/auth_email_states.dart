import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class AuthEmailState {
  const AuthEmailState();
}

class ListLoadingState extends AuthEmailState {
  const ListLoadingState();
}

class ListLoadedState extends AuthEmailState {
  const ListLoadedState();
}

class ListErrorState extends AuthEmailState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AuthEmailState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AuthEmailState {
  const ListLoadingOpacityHideState();
}

class CodeEntryState extends AuthEmailState {
  const CodeEntryState({
    required this.phone,
    required this.isExists,
  });

  final String phone;
  final bool isExists;
}

class GoToPasswordPage extends AuthEmailState {
  const GoToPasswordPage({
    required this.phone,
    required this.email,
  });

  final String phone;
  final String email;
}

class HomeEntryState extends AuthEmailState {
  const HomeEntryState({
    required this.user,
  });

  final User user;
}

class EmailEntryState extends AuthEmailState {
  const EmailEntryState({
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;
}

class ShowMessageState extends AuthEmailState {
  const ShowMessageState({required this.message, this.title});

  final String? title;
  final String message;
}
