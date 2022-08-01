import 'package:equatable/equatable.dart';

abstract class DeleteDataEvent extends Equatable {
  const DeleteDataEvent();
}

class PageOpenedEvent extends DeleteDataEvent {
  @override
  List<Object> get props => [];
}

class CleanUserData extends DeleteDataEvent {
  const CleanUserData(
      {required this.start, required this.end, required this.uid});

  final String start;
  final String end;
  final String uid;

  @override
  List<Object> get props => [];
}
