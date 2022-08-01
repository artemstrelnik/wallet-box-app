import 'package:equatable/equatable.dart';

abstract class BudgetScreenEvent extends Equatable {
  const BudgetScreenEvent();
}

class PageOpenedEvent extends BudgetScreenEvent {
  PageOpenedEvent({this.prev, this.next});

  final bool? next;
  final bool? prev;
  @override
  List<Object> get props => [];
}
