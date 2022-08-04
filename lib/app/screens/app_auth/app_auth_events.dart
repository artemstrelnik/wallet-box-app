import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet_box/app/data/enum.dart';

abstract class AppAuthEvent {
  const AppAuthEvent();
}

class PageOpenedEvent extends AppAuthEvent {}

class CheckUserEvent extends AppAuthEvent {
  const CheckUserEvent({this.info, this.type});
  final UserCredential? info;
  final UserType? type;
}

class UpdateUserTokenEvent extends AppAuthEvent {
  const UpdateUserTokenEvent({required this.token});

  final String token;
  @override
  List<Object> get props => [];
}
