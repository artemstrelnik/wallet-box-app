import 'package:equatable/equatable.dart';

abstract class AuthEmailEvent extends Equatable {
  const AuthEmailEvent();
}

class PageOpenedEvent extends AuthEmailEvent {
  @override
  List<Object> get props => [];
}

class AuthUserEvent extends AuthEmailEvent {
  const AuthUserEvent({required this.code});

  final String code;

  @override
  List<Object> get props => [];
}

class StartUserRegistration extends AuthEmailEvent {
  const StartUserRegistration({required this.email});

  final String email;
  @override
  List<Object> get props => [];
}
