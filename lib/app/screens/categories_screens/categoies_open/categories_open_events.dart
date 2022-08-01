abstract class CategoriesOpenEvent {
  const CategoriesOpenEvent();
}

class PageOpenedEvent extends CategoriesOpenEvent {
  PageOpenedEvent({this.prev, this.next});

  final bool? next;
  final bool? prev;
}

class RemoveTransaction extends CategoriesOpenEvent {
  const RemoveTransaction({required this.transaction});

  final String? transaction;
}
