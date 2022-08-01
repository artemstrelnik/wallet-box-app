import 'package:equatable/equatable.dart';

abstract class CardScreenEvent extends Equatable {
  const CardScreenEvent();
}

class PageOpenedEvent extends CardScreenEvent {
  @override
  List<Object> get props => [];
}

class UserAuthenticatedEvent extends CardScreenEvent {
  const UserAuthenticatedEvent({this.code});

  final String? code;

  @override
  List<Object> get props => [];
}

class ToAuthEvent extends CardScreenEvent {
  @override
  List<Object> get props => [];
}
