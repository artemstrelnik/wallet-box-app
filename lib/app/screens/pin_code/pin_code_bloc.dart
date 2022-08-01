import 'package:flutter_bloc/flutter_bloc.dart';

import 'pin_code_event.dart';
import 'pin_code_state.dart';

class PinCodeBloc extends Bloc<PinCodeEvent, PinCodeState> {
  PinCodeBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<CodeEnteredEvent>(_startUserAuth);
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<PinCodeState> emit,
  ) async {
    try {
      emit(const ListLoadingState());
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _startUserAuth(
    CodeEnteredEvent event,
    Emitter<PinCodeState> emit,
  ) async {
    try {
      if (event.code == event.pinCode) {
        emit(const CodesEqualState());
      } else {
        emit(const ClearCodeState());
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
