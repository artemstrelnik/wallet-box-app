import 'package:equatable/equatable.dart';
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';

abstract class AddCardScreenEvent extends Equatable {
  const AddCardScreenEvent();
}

class PageOpenedEvent extends AddCardScreenEvent {
  @override
  List<Object> get props => [];
}

class UserAuthenticatedEvent extends AddCardScreenEvent {
  const UserAuthenticatedEvent({this.code});

  final String? code;

  @override
  List<Object> get props => [];
}

class ToAuthEvent extends AddCardScreenEvent {
  @override
  List<Object> get props => [];
}

class CreateCardLoyalty extends AddCardScreenEvent {
  const CreateCardLoyalty({
    required this.blankId,
    required this.number,
    this.name,
    this.type,
    this.isCustom = false,
    this.path,
    this.isHands = false,
  });

  final String blankId;
  final String number;
  final String? name;
  final BarcodeType? type;
  final bool isCustom;
  final String? path;
  final bool isHands;

  @override
  List<Object> get props => [];
}

class RemoveCardLoyalty extends AddCardScreenEvent {
  const RemoveCardLoyalty({
    required this.blankId,
  });

  final String blankId;

  @override
  List<Object> get props => [];
}
