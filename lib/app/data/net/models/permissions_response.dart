class RolePermissonsResponse {
  RolePermissonsResponse({
    required this.status,
    required this.data,
  });
  late final int status;
  late final List<SinglePermission> data;

  RolePermissonsResponse.fromJson(Map<String, dynamic> json) {
    var _data = status = json['status'];
    data = List.from(json['data'])
        .map((e) => SinglePermission.fromJson(e))
        .toList();
  }
}

class SinglePermission {
  SinglePermission({
    required this.id,
    required this.permission,
    required this.role,
    required this.authority,
  });
  late final String id;
  late final String permission;
  late final _Role role;
  late final String authority;

  SinglePermission.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    permission = json['permission'];
    role = _Role.fromJson(json['role']);
    authority = json['authority'];
  }
}

class _Role {
  _Role({
    required this.id,
    required this.name,
    required this.autoApply,
    required this.roleAfterBuy,
    required this.roleAfterBuyExpiration,
    required this.roleForBlocked,
    required this.admin,
  });
  late final String id;
  late final String name;
  late final bool autoApply;
  late final bool roleAfterBuy;
  late final bool roleAfterBuyExpiration;
  late final bool roleForBlocked;
  late final bool admin;

  _Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    autoApply = json['autoApply'];
    roleAfterBuy = json['roleAfterBuy'];
    roleAfterBuyExpiration = json['roleAfterBuyExpiration'];
    roleForBlocked = json['roleForBlocked'];
    admin = json['admin'];
  }
}
