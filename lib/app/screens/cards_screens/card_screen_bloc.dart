import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/loyalty_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_by_id_interactor.dart';
import 'package:wallet_box/app/data/net/models/loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import 'card_screen_events.dart';
import 'card_screen_states.dart';

class CardScreenBloc extends Bloc<CardScreenEvent, CardScreenState> {
  CardScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
  }

  late User _user;

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<CardScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? uid = await prefs.getString("wallet_box_uid");
      String? token = await prefs.getString("wallet_box_token");

      if (uid != null && token != null) {
        final List<MyLoyaltyData>? _list = await LoyaltyInteractor().getMyCard(
          body: <String, String>{
            "userId": uid,
          },
          token: token,
        );
        emit(UpdateMyLoyalty(list: _list, token: token));
      } else {
        //emit(const StorageEmptyState());
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
