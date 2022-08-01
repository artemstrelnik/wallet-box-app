abstract class DetailCardScreenEvent {
  const DetailCardScreenEvent();
}

class PageOpenedEvent extends DetailCardScreenEvent {}

class DeleteEvent extends DetailCardScreenEvent {
  const DeleteEvent({this.id});

  final String? id;
}

class UserAuthenticatedEvent extends DetailCardScreenEvent {
  const UserAuthenticatedEvent({this.code});

  final String? code;
}

class ToAuthEvent extends DetailCardScreenEvent {}
