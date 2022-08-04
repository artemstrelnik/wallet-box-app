import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/notification_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_auth_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_registration_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';

import 'auth_password_events.dart';
import 'auth_password_states.dart';

class AuthPasswordBloc extends Bloc<AuthPasswordEvent, AuthPasswordState> {
  AuthPasswordBloc({
    required this.phone,
    this.email,
    this.isPassword = false,
  }) : super(const ListLoadingState()) {
    on<AuthUserEvent>(_onWeatherRequested);
    on<SmsSubmitEvent>(_onSmsSubmitRequested);
    on<UpdateUserTokenEvent>(_onUserTokenUpdate);
  }

  // final FlutterSecureStorage storage = new FlutterSecureStorage();
  final String phone;
  final String? email;
  final bool isPassword;
  late String _checkNumber;

  void _onUserTokenUpdate(
    UpdateUserTokenEvent event,
    Emitter<AuthPasswordState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? uid = prefs.getString("wallet_box_uid");
      final String? token = prefs.getString("wallet_box_token");
      if (uid != null && token != null) {
        NotificationInteractor().saveUserToken(
          body: {"userId": uid, "token": "string"},
          token: event.token,
        );
      }
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    AuthUserEvent event,
    Emitter<AuthPasswordState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());
      // final UserAuthModel? _isUserAuth = await UserAuthInteractor().execute(
      //   body: <String, String>{
      //     "username": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
      //     "password": event.code,
      //   },
      // );
      final bytes = utf8.encode(event.code);
      final base64Str = base64.encode(bytes);
      final UserRegistrationModel? _userRegistration =
          await UserRegistrationInteractor().execute(
        body: <String, String>{
          "username": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          "password": base64Str,
          "walletType": "RUB",
          "email": email!,
          "type": "SYSTEM",
          //"roleName": "forTesting",

          "registerCred": "string",
        },
      );
      emit(const ListLoadingOpacityHideState());
      if (_userRegistration != null && _userRegistration.status == 201) {
        final UserAuthModel? _user = await UserAuthInteractor().execute(body: {
          "username": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          "password": base64Str,
        });

        await prefs.setString("wallet_box_uid", _user!.data!.user.id);
        await prefs.setString("wallet_box_token", _user.data!.token);
        prefs.setBool("not_first_launch", true);
        emit(HomeEntryState(user: _user.data!.user));
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onSmsSubmitRequested(
    SmsSubmitEvent event,
    Emitter<AuthPasswordState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      emit(const ChangeScreenType());
      emit(const ChangeLoadingState());
      emit(const ListLoadingOpacityHideState());

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
