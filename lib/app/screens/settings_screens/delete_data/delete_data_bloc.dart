import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_box/app/data/net/interactors/user_by_id_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'delete_data_events.dart';
import 'delete_data_states.dart';

class DeleteDataBloc extends Bloc<DeleteDataEvent, DeleteDataState> {
  DeleteDataBloc() : super(const ListLoadingState()) {
    on<CleanUserData>(_cleanUserData);
  }

  late User _user;
  // final FlutterSecureStorage storage = new FlutterSecureStorage();

  void _cleanUserData(
    CleanUserData event,
    Emitter<DeleteDataState> emit,
  ) async {
    try {
      emit(const ListLoadingOpacityState());
      final bool? isClean = await UserByIdInteractor().cleanData(
        body: <String, String>{
          "userId": event.uid,
          "start": event.start,
          "end": event.end,
        },
      );
      emit(const ListLoadingOpacityHideState());
      emit(ShowMessage(
          title: isClean != null && isClean ? "Успех" : "Упс",
          message: isClean != null && isClean
              ? "Данные очищены"
              : "Произошла ошибка"));

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
