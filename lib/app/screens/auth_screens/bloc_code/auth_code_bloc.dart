import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/sms_submit_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_auth_interactor.dart';
import 'package:wallet_box/app/data/net/models/sms_submit_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

import 'auth_code_events.dart';
import 'auth_code_states.dart';

class AuthCodeBloc extends Bloc<AuthCodeEvent, AuthCodeState> {
  AuthCodeBloc({
    required this.isExists,
    required this.phone,
    this.isPassword = false,
    this.isRestore = false,
  }) : super(const ListLoadingState()) {
    on<AuthUserEvent>(_onWeatherRequested);
    on<SmsSubmitEvent>(_onSmsSubmitRequested);
  }

  // final FlutterSecureStorage storage = new FlutterSecureStorage();
  final bool isExists;
  final String phone;
  final bool isPassword;
  final bool isRestore;
  late String _checkNumber;

  void _onWeatherRequested(
    AuthUserEvent event,
    Emitter<AuthCodeState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());
      if (isPassword && isRestore == false) {
        final bytes = utf8.encode(event.code);
        final base64Str = base64.encode(bytes);
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
          } else if (_isUserAuth.status == 400) {
            emit(ShowMessageState(message: "Неверный пароль"));
          }
        }
      } else if (isExists) {
        final UserAuthModel? _smsResultData =
            await UserAuthInteractor().smsExecute(
          body: <String, String>{
            "id": _checkNumber,
            "code": event.code,
          },
        );
        emit(const ListLoadingOpacityHideState());
        if (_smsResultData != null) {
          if (_smsResultData.status == 200) {
            if (isRestore == false) {
              await prefs.setString(
                  "wallet_box_uid", _smsResultData.data!.user.id);
              await prefs.setString(
                  "wallet_box_token", _smsResultData.data!.token);
              emit(HomeEntryState(user: _smsResultData.data!.user));
            } else {
              emit(ChangePasswordScreen(
                phone: phone.replaceAll(RegExp(r"\s+\b|\b\s"), ""),
                uid: _smsResultData.data!.user.id,
                token: _smsResultData.data!.token,
              ));
            }
            prefs.setBool("not_first_launch", true);
          } else {
            emit(ShowMessageState(message: "Неверный код"));
          }
        } else {
          emit(ShowMessageState(message: "Неверный код"));
        }
      } else {
        final SmsSubmitResultModel? _smsSubmitResultData =
            await SmsSubmitInteractor().smsSubmitResult(
          body: <String, String>{
            "id": _checkNumber,
            "code": event.code,
          },
        );
        emit(const ListLoadingOpacityHideState());
        if (_smsSubmitResultData != null) {
          if (_smsSubmitResultData.status == 200 && _smsSubmitResultData.data) {
            emit(EmailEntryState(
                phone: phone.replaceAll(RegExp(r"\s+\b|\b\s"), "")));
          }
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onSmsSubmitRequested(
    SmsSubmitEvent event,
    Emitter<AuthCodeState> emit,
  ) async {
    try {
      //emit(const ListLoadingOpacityState());
      if (isPassword && isRestore == false) {
        emit(const ChangeScreenType());
        emit(const ChangeLoadingState());
        //emit(const ListLoadingOpacityHideState());
      } else {
        final SmsSubmitModel? _smsSubmitData =
            await SmsSubmitInteractor().smsSubmit(
          body: <String, String>{
            "phone": phone.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          },
        );
        emit(const ChangeLoadingState());
        emit(const StartTimerState());
        //emit(const ListLoadingOpacityHideState());
        if (_smsSubmitData != null) {
          if (_smsSubmitData.status == 200) {
            _checkNumber = _smsSubmitData.data.id;
          }
        }
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
