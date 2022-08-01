import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_box/app/data/net/interactors/user_update_info_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import 'currencies_screens_events.dart';
import 'currencies_screens_states.dart';

class CurrenciesScreenBloc
    extends Bloc<CurrenciesScreenEvent, CurrenciesScreenState> {
  CurrenciesScreenBloc() : super(const ListLoadingState()) {
    on<UserUpdateInfoEvent>(_onUserUpdateInfo);
  }

  // final FlutterSecureStorage storage = new FlutterSecureStorage();

  void _onUserUpdateInfo(
    UserUpdateInfoEvent event,
    Emitter<CurrenciesScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final UserRegistrationModel? _afterUpdate =
          await UserUpdateInfoInteractor().execute(
        body: event.data,
        uid: event.user.id,
      );
      emit(const ListLoadingOpacityHideState());
      if (_afterUpdate != null && _afterUpdate.status == 200) {
        emit(UpdateUserInfo(user: _afterUpdate.data));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
