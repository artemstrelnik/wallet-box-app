import 'package:wallet_box/app/data/enum.dart';
import 'package:wallet_box/app/data/net/models/bills_response.dart';
import 'package:wallet_box/app/data/net/models/categories_responce.dart';
import 'package:wallet_box/app/data/net/models/permission_role_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class AddOperationScreenEvent {
  const AddOperationScreenEvent();
}

class PageOpenedEvent extends AddOperationScreenEvent {
  const PageOpenedEvent({required this.userInfo});

  final UserNotifierProvider userInfo;
}

class UpdateSelectedCategory extends AddOperationScreenEvent {
  const UpdateSelectedCategory({this.category});

  final OperationCategory? category;
}

class UpdateSelectedBill extends AddOperationScreenEvent {
  const UpdateSelectedBill({required this.bill});

  final Bill bill;
}

class UpdateDateTimeEvent extends AddOperationScreenEvent {
  const UpdateDateTimeEvent({required this.date});

  final DateTime date;
}

class UpdateAddressEvent extends AddOperationScreenEvent {
  const UpdateAddressEvent({required this.address});

  final SearchItem address;
}

class CreateOperationEvent extends AddOperationScreenEvent {
  const CreateOperationEvent({
    required this.desc,
    required this.sum,
    required this.type,
  });

  final String desc;
  final String sum;
  final TransactionTypes type;
}

class UpdateOperationEvent extends AddOperationScreenEvent {
  const UpdateOperationEvent({
    required this.desc,
    required this.sum,
    required this.type,
    required this.id,
  });

  final String id;
  final String desc;
  final String sum;
  final TransactionTypes type;
}

class UpdateBankOperationEvent extends AddOperationScreenEvent {
  const UpdateBankOperationEvent({
    required this.id,
    required this.bankName,
  });

  final String id;
  final BankTypes bankName;
}

class GoToMapPage extends AddOperationScreenEvent {
  const GoToMapPage();
}

class GetMessageIdEvent extends AddOperationScreenEvent {
  const GetMessageIdEvent({required this.codeString});

  final Map<String, dynamic>? codeString;
}


