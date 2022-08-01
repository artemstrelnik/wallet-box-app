abstract class SubscriptionScreenEvent {
  const SubscriptionScreenEvent();
}

class PageOpenedEvent extends SubscriptionScreenEvent {}

class LinkSubscriptionPay extends SubscriptionScreenEvent {
  LinkSubscriptionPay({required this.id});

  final String id;
}
