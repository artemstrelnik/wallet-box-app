import 'package:equatable/equatable.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

abstract class CurrenciesScreenEvent extends Equatable {
  const CurrenciesScreenEvent();
}

class PageOpenedEvent extends CurrenciesScreenEvent {
  @override
  List<Object> get props => [];
}

class UserUpdateInfoEvent extends CurrenciesScreenEvent {
  const UserUpdateInfoEvent({required this.data, required this.user});

  final Map<String, dynamic> data;
  final User user;

  @override
  List<Object> get props => [];
}
