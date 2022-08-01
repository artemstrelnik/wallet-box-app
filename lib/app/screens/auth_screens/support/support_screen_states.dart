import 'package:wallet_box/app/data/net/models/transaction_by_category_id.dart';

abstract class SupprotScreenState {
  const SupprotScreenState();
}

class ListLoadingState extends SupprotScreenState {
  const ListLoadingState();
}

class ListLoadedState extends SupprotScreenState {
  const ListLoadedState();
}

class ListErrorState extends SupprotScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends SupprotScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends SupprotScreenState {
  const ListLoadingOpacityHideState();
}

class ShowMessageState extends SupprotScreenState {
  const ShowMessageState();
}
