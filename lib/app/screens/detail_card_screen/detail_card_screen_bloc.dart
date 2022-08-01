import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/loyalty_interactor.dart';
import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'detail_card_screen_events.dart';
import 'detail_card_screen_states.dart';

class DetailCardScreenBloc
    extends Bloc<DetailCardScreenEvent, DetailCardScreenState> {
  DetailCardScreenBloc({required this.cardId})
      : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<DeleteEvent>(_onDelete);
  }

  late User _user;
  late String cardId;

  void _onDelete(
    DeleteEvent event,
    Emitter<DetailCardScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("wallet_box_token");

      if (token != null) {
        final bool? _state = await LoyaltyInteractor().deleteById(
          body: <String, String>{
            "cardId": cardId,
          },
          token: token,
        );
        if (_state != null && _state) {
          emit(const ListLoadingOpacityHideState());
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<DetailCardScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");

      if (token != null) {
        final MyLoyaltyData? _card = await LoyaltyInteractor().getCardById(
          body: <String, String>{
            "cardId": cardId,
          },
          token: token,
        );
        emit(UpdateCardLoyalty(card: _card, token: token));
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
