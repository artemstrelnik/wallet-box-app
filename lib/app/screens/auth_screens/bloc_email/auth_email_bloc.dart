import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/auth_check_register_interactor.dart';

import 'auth_email_events.dart';
import 'auth_email_states.dart';

class AuthEmailBloc extends Bloc<AuthEmailEvent, AuthEmailState> {
  AuthEmailBloc({
    required this.phone,
  }) : super(const ListLoadingState()) {
    on<StartUserRegistration>(_onStartUserRegistrationRequested);
  }

  final String phone;
  final password = RandomPasswordGenerator();

  void _onStartUserRegistrationRequested(
    StartUserRegistration event,
    Emitter<AuthEmailState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());
      final bool? _isUserAuth = await AuthCheckRegisterInteractor()
          .checkRegisterEmail(email: event.email);
      emit(const ListLoadingOpacityHideState());
      if (_isUserAuth != null) {
        if (!_isUserAuth) {
          emit(GoToPasswordPage(
            phone: phone,
            email: event.email,
          ));
        } else {
          emit(const ShowMessageState(message: "Email уже зарегистрирован"));
        }
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
