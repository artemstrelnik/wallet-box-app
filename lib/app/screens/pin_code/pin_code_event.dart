import 'package:equatable/equatable.dart';

abstract class PinCodeEvent extends Equatable {
  const PinCodeEvent();
}

class PageOpenedEvent extends PinCodeEvent {
  @override
  List<Object> get props => [];
}

class CodeEnteredEvent extends PinCodeEvent {
  const CodeEnteredEvent({required this.code, required this.pinCode});

  final String code;
  final String pinCode;

  @override
  List<Object> get props => [];
}
