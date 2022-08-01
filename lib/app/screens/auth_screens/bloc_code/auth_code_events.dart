import 'package:equatable/equatable.dart';

abstract class AuthCodeEvent extends Equatable {
  const AuthCodeEvent();
}

class PageOpenedEvent extends AuthCodeEvent {
  @override
  List<Object> get props => [];
}

class AuthUserEvent extends AuthCodeEvent {
  const AuthUserEvent({required this.code});

  final String code;

  @override
  List<Object> get props => [];
}

class SmsSubmitEvent extends AuthCodeEvent {
  @override
  List<Object> get props => [];
}
