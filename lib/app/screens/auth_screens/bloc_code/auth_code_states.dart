import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class AuthCodeState {
  const AuthCodeState();
}

class ListLoadingState extends AuthCodeState {
  const ListLoadingState();
}

class ListLoadedState extends AuthCodeState {
  const ListLoadedState();
}

class ListErrorState extends AuthCodeState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AuthCodeState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AuthCodeState {
  const ListLoadingOpacityHideState();
}

class CodeEntryState extends AuthCodeState {
  const CodeEntryState({
    required this.phone,
    required this.isExists,
  });

  final String phone;
  final bool isExists;
}

class HomeEntryState extends AuthCodeState {
  const HomeEntryState({
    required this.user,
  });

  final User user;
}

class EmailEntryState extends AuthCodeState {
  const EmailEntryState({
    required this.phone,
  });

  final String phone;
}

class ChangePasswordScreen extends AuthCodeState {
  const ChangePasswordScreen({
    required this.phone,
    required this.uid,
    required this.token,
  });

  final String phone;
  final String uid;
  final String token;
}

class ChangeScreenType extends AuthCodeState {
  const ChangeScreenType();
}

class ChangeLoadingState extends AuthCodeState {
  const ChangeLoadingState();
}

class ShowMessageState extends AuthCodeState {
  const ShowMessageState({required this.message, this.title});

  final String? title;
  final String message;
}

class TestMessageState extends AuthCodeState {
  const TestMessageState({required this.message, this.title});

  final String? title;
  final String message;
}

class StartTimerState extends AuthCodeState {
  const StartTimerState();
}
