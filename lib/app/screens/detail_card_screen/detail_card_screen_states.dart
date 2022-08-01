import 'package:wallet_box/app/data/net/models/my_loyalty_response_model.dart';

abstract class DetailCardScreenState {
  const DetailCardScreenState();
}

class ListLoadingState extends DetailCardScreenState {
  const ListLoadingState();
}

class ListLoadedState extends DetailCardScreenState {
  const ListLoadedState();
}

class ListErrorState extends DetailCardScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends DetailCardScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends DetailCardScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateCardLoyalty extends DetailCardScreenState {
  const UpdateCardLoyalty({this.card, required this.token});

  final MyLoyaltyData? card;
  final String token;
}
