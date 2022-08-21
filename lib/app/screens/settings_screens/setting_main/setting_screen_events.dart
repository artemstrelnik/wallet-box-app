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
  List<Object> get props => [code, uid];
}

class RemoveUserEvent extends SettingScreenEvent {
  @override
  List<Object> get props => [];
}

class LogoutUserEvent extends SettingScreenEvent {
  @override
  List<Object> get props => [];
}

class UpdateGoogleAuthEvent extends SettingScreenEvent {
  final String? googleId;

  const UpdateGoogleAuthEvent({this.googleId});

  @override
  List<Object> get props => [];
}

class UpdateLoadingEvent extends SettingScreenEvent {
  final bool loading;

  const UpdateLoadingEvent({required this.loading});

  @override
  List<Object?> get props => [loading];
}
