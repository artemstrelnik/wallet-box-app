import 'package:wallet_box/app/data/net/models/groups_list_response.dart';
import 'package:wallet_box/app/data/net/models/subscriptions_responce.dart';

abstract class SubscriptionScreenState {
  const SubscriptionScreenState();
}

class ListLoadingState extends SubscriptionScreenState {
  const ListLoadingState();
}

class ListLoadedState extends SubscriptionScreenState {
  const ListLoadedState();
}

class ListErrorState extends SubscriptionScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends SubscriptionScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends SubscriptionScreenState {
  const ListLoadingOpacityHideState();
}

class UpdateSubscriptionsList extends SubscriptionScreenState {
  const UpdateSubscriptionsList({required this.groups});

  final List<Group>? groups;
}

class GoToPayScreenState extends SubscriptionScreenState {
  const GoToPayScreenState({required this.uri});

  final String uri;
}
