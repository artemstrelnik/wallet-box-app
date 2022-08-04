import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/api.dart';
import 'package:wallet_box/app/data/net/interactors/user_by_id_interactor.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';
import 'package:wallet_box/app/data/net/models/user_registration_model.dart';

import 'my_app_events.dart';
import 'my_app_states.dart';

class MyAppBloc extends Bloc<MyAppEvent, MyAppState> {
  MyAppBloc() : super(const ListLoadingState()) {
    on<PageOpenedEvent>(_onWeatherRequested);
    on<UserAuthenticatedEvent>(_setProviderAndEntryHome);
    on<OpenOperationEvent>(_onOpenHandOperation);
  }

  late User _user;

  void _onOpenHandOperation(
    OpenOperationEvent event,
    Emitter<MyAppState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? uid = prefs.getString("wallet_box_uid");
      final String? token = prefs.getString("wallet_box_token");
      Logger().i("uid => $uid  token => $token");

      if (uid != null && token != null) {
        final UserRegistrationModel? _isUserAuth =
            await UserByIdInteractor().execute(
          body: <String, String>{
            "id": uid,
          },
          token: token,
        );
        if (_isUserAuth != null && _isUserAuth.status == 200) {
          _user = _isUserAuth.data;

          emit(OpenOperationState(type: event.type));
        } else {
          prefs.remove("wallet_box_uid");
          prefs.remove("wallet_box_token");
          Session().removeToken();
          emit(const StorageEmptyState());
        }
      } else {
        prefs.remove("wallet_box_uid");
        prefs.remove("wallet_box_token");
        Session().removeToken();
        emit(const AppAuthState());
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _onWeatherRequested(
    PageOpenedEvent event,
    Emitter<MyAppState> emit,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? not_first_launch = prefs.getBool("not_first_launch");
      Logger().i(not_first_launch.toString());
      if (not_first_launch == null) {
        prefs.remove("wallet_box_uid");
        prefs.remove("wallet_box_token");
        Session().removeToken();
      }

      final String? uid = prefs.getString("wallet_box_uid");
      final String? token = prefs.getString("wallet_box_token");

      if (not_first_launch != null) {
        if (uid != null && token != null) {
          final UserRegistrationModel? _isUserAuth =
              await UserByIdInteractor().execute(
            body: <String, String>{
              "id": uid,
            },
            token: token,
          );
          if (_isUserAuth != null && _isUserAuth.status == 200) {
            _user = _isUserAuth.data;

            emit(UpdateUserProvider(user: _user));

            // final RolePermissonsResponse? _permissions =
            //     await UserByIdInteractor().permissionsForRole(
            //   body: <String, String>{
            //     "roleId": _user.role.id,
            //   },
            //   token: token,
            // );
            // final List<MyPermissions> list = <MyPermissions>[];
            // if (_permissions != null) {
            //   await Future.forEach(_permissions.data,
            //       (SinglePermission _permission) async {
            //     if (MyPermissions.values
            //         .where((p) => p.name == _permission.permission)
            //         .isNotEmpty) {
            //       list.add(MyPermissions.values
            //           .where((p) => p.name == _permission.permission)
            //           .first);
            //     }
            //   });
            // }
            // emit(UpdatePermissionsProvider(permissions: list));

            if (_isUserAuth.data.type != UserType.SYSTEM) {
              emit(const StorageEmptyState());
            } else if (_isUserAuth.data.pinCode.isEmpty) {
              emit(const StorageEmptyState(userExist: true));
            } else {
              emit(const LocalAuthState());
            }
            if (_isUserAuth.data.touchID != false) {
              emit(const TouchAuthState());
            }
          } else {
            prefs.remove("wallet_box_uid");
            prefs.remove("wallet_box_token");
            Session().removeToken();
            emit(const StorageEmptyState());
          }
        } else {
          emit(const StorageEmptyState());
        }
      } else {
        prefs.remove("wallet_box_uid");
        prefs.remove("wallet_box_token");
        Session().removeToken();
        emit(const AppAuthState());
      }

      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }

  void _setProviderAndEntryHome(
    UserAuthenticatedEvent event,
    Emitter<MyAppState> emit,
  ) async {
    try {
      if (event.code != null) {}
      emit(UserAuthorizedState(user: _user));
      // ignore: nullable_type_in_catch_clause
    } on dynamic catch (_) {
      rethrow;
    }
  }
}
