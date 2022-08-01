import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_box/app/data/net/interactors/currencies_interactor.dart';
import 'package:wallet_box/app/data/net/interactors/user_by_id_interactor.dart';
import 'package:wallet_box/app/data/net/models/currenci_model.dart';
import 'package:wallet_box/app/data/net/models/my_subscription_variable.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';
import 'package:wallet_box/app/data/net/interactors/subscriptions_interactor.dart';

import 'export_screen_events.dart';
import 'export_screen_states.dart';

class ExportBloc extends Bloc<ExportScreenEvent, ExportScreenState> {
  ExportBloc() : super(const ListLoadingState()) {
    on<ExportCSVFileEvent>(_onExportCSVFile);
  }

  late User _user;

  void _onExportCSVFile(
    ExportCSVFileEvent event,
    Emitter<ExportScreenState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      emit(const ListLoadingOpacityState());

      String? uid = await prefs.getString("wallet_box_uid");
      String? token = await prefs.getString("wallet_box_token");
      if (uid != null && token != null) {
        final String? _isLink = await UserByIdInteractor().csv(
          body: <String, String>{
            "userId": uid,
            "start": event.start.toString().replaceAll(" ", "T") + "Z",
            "end": event.end.toString().replaceAll(" ", "T") + "Z",
          },
          token: token,
        );
        if (_isLink != null && _isLink.isNotEmpty) {
          emit(CsvOpenFile(path: _isLink));
        }
      }
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
