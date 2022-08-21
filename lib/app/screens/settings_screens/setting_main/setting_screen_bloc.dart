import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/interactors/currencies_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/pin_code_update_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_auth_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_by_id_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_update_info_interactor.dart';
import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import 'package:wallet_box/app/data/net/models/groups_list_response.dart';
import 'package:wallet_box/app/data/net/models/my_subscription_variable.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import 'package:wallet_box/app/data/net/interactors/subscriptions_interactor.dart';

import 'setting_screen_events.dart';
import 'setting_screen_states.dart';

class SettingScreenBloc extends Bloc<SettingScreenEvent, SettingScreenState> {
  SettingScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onOpenSettings);
    on<UserUpdateInfoEvent>(_onUserUpdateInfo);
    on<UserUpdatePinCodeEvent>(_onUserUpdatePinCode);
    on<StartPinCodeUpdateEvent>(_onStartPinCodeUpdateEvent);
    on<UserRemovePinCodeEvent>(_removePinCode);
    on<UpdateGoogleAuthEvent>(_onUpdateGoogleAuth);
    on<UpdateLoadingEvent>(_onUpdateLoading);
    on<RemoveUserEvent>(_removeUser);
    on<LogoutUserEvent>(_logoutUser);
  }

  void _logoutUser(
    LogoutUserEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("wallet_box_uid");
      prefs.remove("wallet_box_token");
      prefs.remove("not_first_launch");
      Session().removeToken();
      emit(GoToStartScreen());

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _removeUser(
    RemoveUserEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = await prefs.getString("wallet_box_uid");
      emit(const ListLoadingOpacityState());
      final bool? _isRemoved = await UserAuthInteractor().remove(
        body: <String, String>{},
      );

      emit(const ListLoadingOpacityHideState());
      if (_isRemoved != null && _isRemoved) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("wallet_box_uid");
        prefs.remove("wallet_box_token");
        prefs.remove("firebaseToken");

        Session().removeToken();
        emit(GoToStartScreen());
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _removePinCode(
    UserRemovePinCodeEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = await prefs.getString("wallet_box_uid");
      emit(const ListLoadingOpacityState());
      final UserRegistrationModel? _isUser =
          await PinCodeUpdateInteractor().remove(
        body: <String, String>{"userId": uid!},
      );
      if (_isUser != null && _isUser.status == 200) {
        _user = _isUser.data;
        emit(const ListLoadingOpacityHideState());
        emit(OpenSettingState(user: _isUser.data));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onStartPinCodeUpdateEvent(
    StartPinCodeUpdateEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final UserRegistrationModel? _isUserAuth =
          await PinCodeUpdateInteractor().execute(
        body: <String, String>{"code": event.code, "userId": event.uid},
      );
      if (_isUserAuth != null && _isUserAuth.status == 200) {
        _user = _isUserAuth.data;
        emit(const ListLoadingOpacityHideState());
        emit(const StopPinCodeChangeState());
        emit(OpenSettingState(user: _isUserAuth.data));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUserUpdatePinCode(
    UserUpdatePinCodeEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    emit(const StartPinCodeChangeState());
  }

  // final storage = new FlutterSecureStorage();
  late User _user;

  void _onOpenSettings(
    PageOpenedEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());

      final List<Currency>? _currenciesList =
          await CurrenciesInteractor().execute();
      if (_currenciesList != null) {
        emit(UpdateCurrenciesList(list: _currenciesList));
      }

      String? uid = await prefs.getString("wallet_box_uid");
      String? token = await prefs.getString("wallet_box_token");
      if (uid != null && token != null) {
        // получаем юзера по ид
        final UserRegistrationModel? _isUserAuth =
            await UserByIdInteractor().execute(
          body: <String, String>{
            "id": uid,
          },
          token: token,
        );
        if (_isUserAuth != null && _isUserAuth.status == 200) {
          _user = _isUserAuth.data;
          emit(const ListLoadingOpacityHideState());
          emit(OpenSettingState(user: _isUserAuth.data));

          final MySubscription? _mySubscription =
              await SubscriptionsInteractor()
                  .getMySubscription(token: token, body: <String, String>{
            "userId": uid,
          });
          emit(UpdateSubscriptionState(sub: _mySubscription));
        }
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUserUpdateInfo(
    UserUpdateInfoEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final UserRegistrationModel? _afterUpdate =
          await UserUpdateInfoInteractor().execute(
        body: event.data,
        uid: _user.id,
      );
      emit(const ListLoadingOpacityHideState());
      if (_afterUpdate != null && _afterUpdate.status == 200) {
        emit(OpenSettingState(user: _afterUpdate.data));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  Future<void> _onUpdateGoogleAuth(
    UpdateGoogleAuthEvent event,
    Emitter<SettingScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      UserRegistrationModel? _afterUpdate;
      _afterUpdate =
          await UserUpdateInfoInteractor().updateAuth(event.googleId);
      emit(const ListLoadingOpacityHideState());
      if (_afterUpdate != null && _afterUpdate.status == 200) {
        emit(OpenSettingState(user: _afterUpdate.data));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onUpdateLoading(
    UpdateLoadingEvent event,
    Emitter<SettingScreenState> emit,
  ) {
    if (event.loading) {
      emit(const ListLoadingOpacityState());
    } else {
      emit(const ListLoadingOpacityHideState());
    }
  }
}
