import 'package:equatable/equatable.dart';

abstract class AuthPasswordEvent extends Equatable {
  const AuthPasswordEvent();
}

class PageOpenedEvent extends AuthPasswordEvent {
  @override
  List<Object> get props => [];
}

class AuthUserEvent extends AuthPasswordEvent {
  const AuthUserEvent({required this.code});

  final String code;

  @override
  List<Object> get props => [];
}

class SmsSubmitEvent extends AuthPasswordEvent {
  @override
  List<Object> get props => [];
}

class UpdateUserTokenEvent extends AuthPasswordEvent {
  const UpdateUserTokenEvent({required this.token});

  final String token;
  @override
  List<Object> get props => [];
}
