import 'package:barcode/barcode.dart';

import 'loyalty_response_model.dart';
import 'user_auth_model.dart';

class MyLoyaltyResponseModel {
  MyLoyaltyResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final List<MyLoyaltyData> data;
  late final String message;

  MyLoyaltyResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        List.from(json['data']).map((e) => MyLoyaltyData.fromJson(e)).toList();
    message = json['message'];
  }
}

class CreatedLoyaltyResponseModel {
  CreatedLoyaltyResponseModel({
    required this.status,
    required this.data,
  });
  late final int status;
  late final MyLoyaltyData data;

  CreatedLoyaltyResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = MyLoyaltyData.fromJson(json['data']);
  }
}

class MyLoyaltyData {
  MyLoyaltyData({
    required this.id,
    required this.blank,
    required this.data,
    this.customImage,
  });
  late final String id;
  late final Loyalty blank;
  late final String data;
  late final CustomImage? customImage;

  MyLoyaltyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    blank = Loyalty.fromJson(json['blank']);
    data = json['data'];
    customImage = json['customImage'] != null
        ? CustomImage.fromJson(json['customImage'])
        : null;
  }
}

class MySingleLoyaltyResponseModel {
  MySingleLoyaltyResponseModel({
    required this.status,
    required this.data,
    required this.message,
  });
  late final int status;
  late final MyLoyaltyData data;
  late final String message;

  MySingleLoyaltyResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = MyLoyaltyData.fromJson(json['data']);
    message = json['message'];
  }
}

class MyCardDataModel {
  MyCardDataModel({
    required this.number,
    required this.type,
    required this.name,
  });
  late final String number;
  late final Barcode type;
  late final String name;

  MyCardDataModel.fromJson(Map<String, dynamic> json) {
    number = json['status'];
    type = json['type'] != null && (json['type'] as String).isNotEmpty
        ? Barcode.fromType(BarcodeType.values
            .where((element) => element
                .toString()
                .toLowerCase()
                .contains(json['type'].toLowerCase()))
            .first)
        : Barcode.code128(escapes: true);
    name = json['name'];
  }
}

class CustomImage {
  CustomImage({
    required this.id,
    required this.path,
  });
  late final String id;
  late final String path;

  CustomImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['path'] = path;
    return _data;
  }
}
