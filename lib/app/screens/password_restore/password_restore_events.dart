import 'package:equatable/equatable.dart';

abstract class PasswordRestoreEvent extends Equatable {
  const PasswordRestoreEvent();
}

class PageOpenedEvent extends PasswordRestoreEvent {
  @override
  List<Object> get props => [];
}

class AuthCheckRegisterEvent extends PasswordRestoreEvent {
  const AuthCheckRegisterEvent({required this.phone});

  final String phone;

  @override
  List<Object> get props => [];
}
