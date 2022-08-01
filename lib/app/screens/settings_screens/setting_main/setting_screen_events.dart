import 'package:equatable/equatable.dart';

abstract class SettingScreenEvent extends Equatable {
  const SettingScreenEvent();
}

class PageOpenedEvent extends SettingScreenEvent {
  @override
  List<Object> get props => [];
}

class UserUpdateInfoEvent extends SettingScreenEvent {
  const UserUpdateInfoEvent({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object> get props => [];
}

class UserUpdatePinCodeEvent extends SettingScreenEvent {
  const UserUpdatePinCodeEvent();

  @override
  List<Object> get props => [];
}

class UserRemovePinCodeEvent extends SettingScreenEvent {
  const UserRemovePinCodeEvent();

  @override
  List<Object> get props => [];
}

class StartPinCodeUpdateEvent extends SettingScreenEvent {
  const StartPinCodeUpdateEvent({required this.code, required this.uid});

  final String code;
  final String uid;

  @override
  List<Object> get props => [];
}

class RemoveUserEvent extends SettingScreenEvent {
  @override
  List<Object> get props => [];
}

class LogoutUserEvent extends SettingScreenEvent {
  @override
  List<Object> get props => [];
}
