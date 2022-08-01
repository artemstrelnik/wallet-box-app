import 'package:equatable/equatable.dart';

abstract class PasswordRestoreFinalEvent extends Equatable {
  const PasswordRestoreFinalEvent();
}

class PageOpenedEvent extends PasswordRestoreFinalEvent {
  @override
  List<Object> get props => [];
}

class AuthUserEvent extends PasswordRestoreFinalEvent {
  const AuthUserEvent({required this.code});

  final String code;

  @override
  List<Object> get props => [];
}
