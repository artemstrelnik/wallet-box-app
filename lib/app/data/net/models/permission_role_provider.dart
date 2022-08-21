import 'package:flutter/material.dart';
import 'package:wallet_box/app/data/net/models/user_auth_model.dart';

// class RolePermissionProvider with ChangeNotifier {
//   late List<MyPermissions>? _permissions;

//   List<MyPermissions>? get permissions => _permissions;

//   set setPermissions(List<MyPermissions>? _newPermissions) {
//     _permissions = _newPermissions;
//     notifyListeners();
//   }
// }

class UserNotifierProvider with ChangeNotifier {
  late User? _user;
  bool _isHiddenBills = false;
  bool _isEarnActive = true;
  bool _isLogout = false;

  User? get user => _user;

  bool get isLogout => _isLogout;

  bool get isHiddenBills => _isHiddenBills;

  bool get isEarnActive => _isEarnActive;

  set setUser(User? _human) {
    _user = _human;
    notifyListeners();
  }

  set setLogoutState(bool isLogout) {
    _isLogout = isLogout;
    notifyListeners();
  }

  set setIsHiddenBills(bool isHidden) {
    _isHiddenBills = isHidden;
    notifyListeners();
  }

  set setIsEarnActive(bool isEarnActive) {
    _isEarnActive = isEarnActive;
    notifyListeners();
  }
}

class ShowAlertProvider with ChangeNotifier {
  bool _isVisible = false;
  String? _error;

  bool get isVisible => _isVisible;

  String? get error => _error;

  set setVisible(bool isVisible) {
    _isVisible = isVisible;
    notifyListeners();
  }

  set setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
