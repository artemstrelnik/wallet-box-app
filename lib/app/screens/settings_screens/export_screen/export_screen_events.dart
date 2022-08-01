import 'package:equatable/equatable.dart';

abstract class ExportScreenEvent {
  const ExportScreenEvent();
}

class PageOpenedEvent extends ExportScreenEvent {}

class ExportCSVFileEvent extends ExportScreenEvent {
  ExportCSVFileEvent({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}
