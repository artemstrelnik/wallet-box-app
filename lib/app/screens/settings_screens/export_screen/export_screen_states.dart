abstract class ExportScreenState {
  const ExportScreenState();
}

class ListLoadingState extends ExportScreenState {
  const ListLoadingState();
}

class ListLoadedState extends ExportScreenState {
  const ListLoadedState();
}

class ListErrorState extends ExportScreenState {
  const ListErrorState();
}

class ListLoadingOpacityState extends ExportScreenState {
  const ListLoadingOpacityState();
}

class ListLoadingOpacityHideState extends ExportScreenState {
  const ListLoadingOpacityHideState();
}

class CsvOpenFile extends ExportScreenState {
  const CsvOpenFile({required this.path});

  final String path;
}
