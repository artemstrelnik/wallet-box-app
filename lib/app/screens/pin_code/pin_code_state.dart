

abstract class PinCodeState {
  const PinCodeState();
}

class ListLoadingState extends PinCodeState {
  const ListLoadingState();
}

class ListLoadedState extends PinCodeState {
  const ListLoadedState();
}

class ListErrorState extends PinCodeState {
  const ListErrorState();
}

class ListLoadingOpacityState extends PinCodeState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends PinCodeState {
  const ListLoadingOpacityHideState();
}

class CodesEqualState extends PinCodeState {
  const CodesEqualState();
}

class ClearCodeState extends PinCodeState {
  const ClearCodeState();
}
