abstract class DeleteDataState {
  const DeleteDataState();
}

class ListLoadingState extends DeleteDataState {
  const ListLoadingState();
}

class ListLoadedState extends DeleteDataState {
  const ListLoadedState();
}

class ListErrorState extends DeleteDataState {
  const ListErrorState();
}

class ListLoadingOpacityState extends DeleteDataState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends DeleteDataState {
  const ListLoadingOpacityHideState();
}

class ShowMessage extends DeleteDataState {
  const ShowMessage({required this.title, required this.message});

  final String title;
  final String message;
}
