class SmsSubmitModel {
  SmsSubmitModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final _Data data;
  late final String message;

  SmsSubmitModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = _Data.fromJson(json['data']);
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = data.toJson();
    _data['message'] = message;
    return _data;
  }
}

class _Data {
  _Data({
    required this.id,
  });
  late final String id;

  _Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    return _data;
  }
}

class SmsSubmitResultModel {
  SmsSubmitResultModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final bool data;
  late final String message;

  SmsSubmitResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'];
    message = json['message'];
  }
}
