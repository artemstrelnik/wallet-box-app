import 'package:equatable/equatable.dart';
import 'package:wallet_box/app/data/enum.dart';

abstract class MyAppEvent extends Equatable {
  const MyAppEvent();
}

class PageOpenedEvent extends MyAppEvent {
  @override
  List<Object> get props => [];
}

class UserAuthenticatedEvent extends MyAppEvent {
  const UserAuthenticatedEvent({this.code});

  final String? code;

  @override
  List<Object> get props => [];
}

class ToAuthEvent extends MyAppEvent {
  @override
  List<Object> get props => [];
}

class UpdateUserTokenEvent extends MyAppEvent {
  const UpdateUserTokenEvent({required this.token});

  final String token;
  @override
  List<Object> get props => [];
}

class OpenOperationEvent extends MyAppEvent {
  const OpenOperationEvent({required this.type});

  final OperationType type;
  @override
  List<Object> get props => [];
}
