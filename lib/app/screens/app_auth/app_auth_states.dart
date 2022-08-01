import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class AppAuthState {
  const AppAuthState();
}

class ListLoadingState extends AppAuthState {
  const ListLoadingState();
}

class ListLoadedState extends AppAuthState {
  const ListLoadedState();
}

class ListErrorState extends AppAuthState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AppAuthState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AppAuthState {
  const ListLoadingOpacityHideState();
}

class HomeEntryState extends AppAuthState {
  const HomeEntryState({
    required this.user,
  });

  final User user;
}

class ShowDialogState extends AppAuthState {
  const ShowDialogState();
}
