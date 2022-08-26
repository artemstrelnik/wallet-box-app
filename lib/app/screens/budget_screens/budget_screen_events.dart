import 'package:equatable/equatable.dart';

abstract class BudgetScreenEvent extends Equatable {
  const BudgetScreenEvent();

  List<Object> get props => [];
}

class PageOpenedEvent extends BudgetScreenEvent {
  PageOpenedEvent({this.prev, this.next});

  final bool? next;
  final bool? prev;
}

class UpdateSpendEarnEvent extends BudgetScreenEvent {
  final int? plannedSpend;
  final int? plannedEarn;

  UpdateSpendEarnEvent({this.plannedSpend, this.plannedEarn});
}
