import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/user_auth_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_update_info_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import 'password_restore_final_events.dart';
import 'password_restore_final_states.dart';

class PasswordRestoreFinalBloc
    extends Bloc<PasswordRestoreFinalEvent, PasswordRestoreFinalState> {
  PasswordRestoreFinalBloc({
    required this.uid,
    required this.phone,
    required this.token,
  }) : super(const ListLoadingState()) {
    on<AuthUserEvent>(_onWeatherRequested);
  }

  final String phone;
  final String token;
  final String uid;
  late User _user;

  void _onWeatherRequested(
    AuthUserEvent event,
    Emitter<PasswordRestoreFinalState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());

      final bytes = utf8.encode(event.code);
      final base64Str = base64.encode(bytes);

      final UserRegistrationModel? _afterUpdate =
          await UserUpdateInfoInteractor().execute(
        body: {"password": base64Str},
        uid: uid,
      );
      if (_afterUpdate != null && _afterUpdate.status == 200) {
        final UserAuthModel? _isUserAuth = await UserAuthInteractor().execute(
          body: <String, String>{
            "username": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "password": base64Str,
          },
        );
        emit(const ListLoadingOpacityHideState());

        if (_isUserAuth != null) {
          if (_isUserAuth.status == 200) {
            await prefs.setString("wallet_box_uid", _isUserAuth.data!.user.id);
            await prefs.setString("wallet_box_token", _isUserAuth.data!.token);
            emit(HomeEntryState(user: _isUserAuth.data!.user));
            prefs.setBool("not_first_launch", true);
          }
        }
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
