abstract class PasswordRestoreState {
  const PasswordRestoreState();
}

class ListLoadingState extends PasswordRestoreState {
  const ListLoadingState();
}

class ListLoadedState extends PasswordRestoreState {
  const ListLoadedState();
}

class ListErrorState extends PasswordRestoreState {
  const ListErrorState();
}

class ListLoadingOpacityState extends PasswordRestoreState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends PasswordRestoreState {
  const ListLoadingOpacityHideState();
}

class CodeEntryState extends PasswordRestoreState {
  const CodeEntryState({
    required this.phone,
    required this.isExists,
  });

  final String phone;
  final bool isExists;
}

class UserNotFound extends PasswordRestoreState {
  const UserNotFound({
    required this.phone,
  });

  final String phone;
}
