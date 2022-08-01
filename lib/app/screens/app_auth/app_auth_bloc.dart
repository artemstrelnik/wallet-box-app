import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/interactors/auth_check_register_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_auth_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_registration_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import '../../data/net/interactors/notification_interactor.dart';
import 'app_auth_events.dart';
import 'app_auth_states.dart';

class AppAuthBloc extends Bloc<AppAuthEvent, AppAuthState> {
  AppAuthBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<CheckUserEvent>(_startCreateUser);
    on<UpdateUserTokenEvent>(_onUserTokenUpdate);
  }

  late User _user;

  void _onUserTokenUpdate(
    UpdateUserTokenEvent event,
    Emitter<AppAuthState> emit,
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
    PageOpenedEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    try {} on dynamic catch (_) {
      rethrow;
    }
  }

  void _startCreateUser(
    CheckUserEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove("wallet_box_uid");
      prefs.remove("wallet_box_token");
      Session().removeToken();
      final bool? _isExists = await AuthCheckRegisterInteractor().checkEmail(
        body: <String, String>{
          "email": event.info!.user!.email!,
        },
      );
      if (_isExists != null && _isExists) {
        final UserAuthModel? _user = await UserAuthInteractor().byEmail(body: {
          "email": event.info!.user!.email!,
          "registerCred": event.info!.user!.uid,
        });
        if (_user != null && _user.data != null) {
          await prefs.setString("wallet_box_uid", _user.data!.user.id);
          await prefs.setString("wallet_box_token", _user.data!.token);
          prefs.setBool("not_first_launch", true);
          emit(HomeEntryState(user: _user.data!.user));
        } else {
          emit(const ShowDialogState());
        }
      } else {
        final password = RandomPasswordGenerator();

        String newPassword = password.randomPassword(
          passwordLength: 8,
          numbers: true,
          uppercase: true,
        );
        final bytes = utf8.encode(newPassword);
        final base64Str = base64.encode(bytes);
        final UserRegistrationModel? _userRegistration =
            await UserRegistrationInteractor().execute(
          body: <String, String>{
            //"username": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "password": base64Str,
            "walletType": "RUB",
            "email": event.info!.user!.email!,
            "type": event.type.toString().split(".").last,
            "registerCred": event.info!.user!.uid,
            //"roleName": "forTesting"
          },
        );
        if (_userRegistration != null && _userRegistration.status == 201) {
          final UserAuthModel? _user =
              await UserAuthInteractor().byEmail(body: {
            "email": event.info!.user!.email!,
            "registerCred": event.info!.user!.uid,
          });

          await prefs.setString("wallet_box_uid", _user!.data!.user.id);
          await prefs.setString("wallet_box_token", _user.data!.token);
          prefs.setBool("not_first_launch", true);
          emit(HomeEntryState(user: _user.data!.user));
        } else {
          emit(const ShowDialogState());
        }
      }
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
