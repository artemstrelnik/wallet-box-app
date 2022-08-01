import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/loyalty_interactor.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'add_card_screen_events.dart';
import 'add_card_screen_states.dart';

class AddCardScreenBloc extends Bloc<AddCardScreenEvent, AddCardScreenState> {
  AddCardScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<CreateCardLoyalty>(_createCardLoyalty);
  }

  late User _user;

  void _createCardLoyalty(
    CreateCardLoyalty event,
    Emitter<AddCardScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");

      if (token != null && uid != null) {
        final String? _isCreate = await LoyaltyInteractor().createCard(
          token: token,
          body: <String, String>{
            "blankId": event.blankId,
            "userId": uid,
            "data": event.type != null
                ? event.number + "||" + event.type.toString().split(".").last
                : event.number,
          },
        );
        if (event.path != null &&
            event.path!.isNotEmpty &&
            _isCreate != null &&
            _isCreate.isNotEmpty) {
          final bool? _isLoaded = await LoyaltyInteractor().customImage(
            token: token,
            body: <String, String>{
              "cardId": _isCreate,
              "path": event.path!,
            },
          );
        }
        emit(CreateCardState(
          isCreate: _isCreate != null && _isCreate.isNotEmpty,
          isCustom: event.isCustom,
          isHands: event.isHands,
        ));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<AddCardScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");

      if (token != null) {
        final List<Loyalty>? _list = await LoyaltyInteractor().blankList(
          token: token,
          body: <String, String>{},
        );
        emit(UpdateListLoyalty(list: _list, token: token));
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
