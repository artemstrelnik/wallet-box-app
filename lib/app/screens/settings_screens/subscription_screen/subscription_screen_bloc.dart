import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/net/interactors/subscriptions_interactor.dart';
import 'package:wallet_box/app/data/net/models/groups_list_response.dart';
import 'package:wallet_box/app/data/net/models/subscriptions_responce.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'subscription_screen_events.dart';
import 'subscription_screen_states.dart';

class SubscriptionScreenBloc
    extends Bloc<SubscriptionScreenEvent, SubscriptionScreenState> {
  SubscriptionScreenBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_getSubscriptionsGroups);
    on<LinkSubscriptionPay>(_linkSubscriptionPay);
  }

  late User _user;

  void _linkSubscriptionPay(
    LinkSubscriptionPay event,
    Emitter<SubscriptionScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      String? uid = await prefs.getString("wallet_box_uid");

      if (token != null && uid != null) {
        final String? _link =
            await SubscriptionsInteractor().linkSubscriptionPay(
          token: token,
          body: <String, String>{
            "userId": uid,
            "subscriptionVariantId": event.id,
          },
        );
        if (_link != null && _link.isNotEmpty) {
          emit(GoToPayScreenState(uri: _link));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _getSubscriptionsGroups(
    PageOpenedEvent event,
    Emitter<SubscriptionScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await prefs.getString("wallet_box_token");
      if (token != null) {
        final List<Group>? _responseList = await SubscriptionsInteractor()
            .fullGroupsList(token: token, body: <String, String>{});
        emit(UpdateSubscriptionsList(groups: _responseList));
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  // void _getSubscriptions(
  //   PageOpenedEvent event,
  //   Emitter<SubscriptionScreenState> emit,
  // ) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = await prefs.getString("wallet_box_token");
  //     if (token != null) {
  //       final List<Subscription>? _responseList =
  //           await SubscriptionsInteractor()
  //               .fullList(token: token, body: <String, String>{});
  //       emit(UpdateSubscriptionsList(subscriptions: _responseList));
  //     }
  //     // ignore: nullable_type_in_catch_clause
  //   } on dynamic catch (_) {
  //     rethrow;
  //   }
  // }
}
