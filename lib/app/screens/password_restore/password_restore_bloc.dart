import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_box/app/data/net/interactors/auth_check_register_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'password_restore_events.dart';
import 'password_restore_states.dart';

class PasswordRestoreBloc
    extends Bloc<PasswordRestoreEvent, PasswordRestoreState> {
  PasswordRestoreBloc() : super(const ListLoadingState()) {
    on<AuthCheckRegisterEvent>(_onWeatherRequested);
  }

  late User _user;
  // final FlutterSecureStorage storage = new FlutterSecureStorage();

  void _onWeatherRequested(
    AuthCheckRegisterEvent event,
    Emitter<PasswordRestoreState> emit,
  ) async {
    try {
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
