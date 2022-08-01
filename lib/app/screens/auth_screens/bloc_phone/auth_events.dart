import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class PageOpenedEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthCheckRegisterEvent extends AuthEvent {
  const AuthCheckRegisterEvent({required this.phone});

  final String phone;

  @override
  List<Object> get props => [];
}
