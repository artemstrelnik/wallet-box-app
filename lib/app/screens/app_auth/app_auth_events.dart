

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallet_box/app/data/enum.dart';

abstract class AppAuthEvent {
  const AppAuthEvent();
}

class PageOpenedEvent extends AppAuthEvent {}

class CheckUserEvent extends AppAuthEvent {
  const CheckUserEvent({this.googleUser, this.type, this.appleUser});

  final GoogleSignInAccount? googleUser;
  final UserType? type;
  final UserCredential? appleUser;
}

class UpdateUserTokenEvent extends AppAuthEvent {
  const UpdateUserTokenEvent({required this.token});

  final String token;

  @override
  List<Object> get props => [];
}
