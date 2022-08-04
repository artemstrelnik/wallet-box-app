import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

import 'support_screen_events.dart';
import 'support_screen_states.dart';

class SupprotScreenBloc extends Bloc<SupprotScreenEvent, SupprotScreenState> {
  SupprotScreenBloc() : super(const ListLoadingState()) {
    on<StartCreateTicket>(_onTicketCreate);
  }

  late User _user;

  void _onTicketCreate(
    StartCreateTicket event,
    Emitter<SupprotScreenState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final bool? _isSended = await TecketsInteractor().send(body: event.body);
      emit(const ListLoadingOpacityHideState());
      if (_isSended != null && _isSended) {
        emit(const ShowMessageState());
      }
    } on dynamic catch (_) {
      rethrow;
    }
  }
}

class TecketsInteractor {
  Future<bool?> send({required Map<String, String> body}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var response = await Session().generalRequest(
        body: body,
        url: "/api/v1/help/",
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (ex) {
      return null;
    }
  }
}
