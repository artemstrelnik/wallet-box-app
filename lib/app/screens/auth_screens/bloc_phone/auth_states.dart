abstract class AuthState {
  const AuthState();
}

class ListLoadingState extends AuthState {
  const ListLoadingState();
}

class ListLoadedState extends AuthState {
  const ListLoadedState();
}

class ListErrorState extends AuthState {
  const ListErrorState();
}

class ListLoadingOpacityState extends AuthState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends AuthState {
  const ListLoadingOpacityHideState();
}

class CodeEntryState extends AuthState {
  const CodeEntryState({
    required this.phone,
    required this.isExists,
  });

  final String phone;
  final bool isExists;
}
