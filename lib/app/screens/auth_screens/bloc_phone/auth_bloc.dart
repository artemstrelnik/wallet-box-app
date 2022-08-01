import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/interactors/auth_check_register_interactor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_events.dart';
import 'auth_states.dart';

enum AppStartState {
  loading,
  update,
  loaded,
  error,
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const ListLoadingState()) {
    on<AuthCheckRegisterEvent>(_onWeatherRequested);
  }

  void _onWeatherRequested(
    AuthCheckRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove("wallet_box_uid");
      prefs.remove("wallet_box_token");
      Session().removeToken();
      //emit(const ListLoadingOpacityState());
      final bool? _isExists = await AuthCheckRegisterInteractor().execute(
        phone: event.phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
      );
      //emit(const ListLoadingOpacityHideState());
      if (_isExists != null) {
        emit(CodeEntryState(phone: event.phone, isExists: _isExists));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
