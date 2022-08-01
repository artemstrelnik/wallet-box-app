import 'package:equatable/equatable.dart';

abstract class SupprotScreenEvent {
  const SupprotScreenEvent();
}

class PageOpenedEvent extends SupprotScreenEvent {
  const PageOpenedEvent();
}

class StartCreateTicket extends SupprotScreenEvent {
  const StartCreateTicket({required this.body});

  final Map<String, String> body;
}
